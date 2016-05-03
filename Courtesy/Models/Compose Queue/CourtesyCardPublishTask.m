//
//  CourtesyCardPublishTask.m
//  Courtesy
//
//  Created by Zheng on 4/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPublishTask.h"
#import "CourtesyCardPublishPendRequest.h"

#define kCourtesyCardPublishQueueIdentifier @"kCourtesyCardPublishQueueIdentifier-%@"
#define kCourtesyCardPublishQueueCacheIdentifier @"kCourtesyCardPublishQueueCacheIdentifier-%@"

@interface CourtesyCardPublishTask () <CourtesyRsyncHelperDelegate, CourtesyCardPublishPendDelegate>
@property (nonatomic, strong) CourtesyCardPublishPendRequest *pendRequest;

@end

@implementation CourtesyCardPublishTask

#pragma mark - Card Publish Status

- (void)setCardPublished:(BOOL)published {
    self.card.hasPublished = published;
    self.card.willPublish = NO;
    self.card.shouldNotify = NO;
    [self.card saveToLocalDatabase];
}

#pragma mark - Task management

- (void)startTaskWithQuery:(BOOL)query {
    CourtesyCardPublishPendRequest *pendRequest = [[CourtesyCardPublishPendRequest alloc] initWithDelegate:self];
    pendRequest.card_info = self.card;
    pendRequest.query = query;
    self.pendRequest = pendRequest;
    // Start Pending Request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [pendRequest sendRequest];
    });
}

- (void)stopTask {
    dispatch_async_on_main_queue(^{
        if (self.status != CourtesyCardPublishTaskStatusCanceled && self.status != CourtesyCardPublishTaskStatusNone) {
            if (self.status == CourtesyCardPublishTaskStatusPending) {
                [_pendRequest stopRequest];
            } else if (self.status == CourtesyCardPublishTaskStatusProcessing) {
                [_helper pauseRsync];
            }
        }
    });
}

#pragma mark - CourtesyCardPublishPendDelegate

- (void)cardPublishPendDidStart:(CourtesyCardPublishPendRequest *)sender {
    dispatch_async_on_main_queue(^{
        if (sender.query) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(publishTaskDidStart:)]) {
                [self.delegate publishTaskDidStart:self];
            }
            if (self.status == CourtesyCardPublishTaskStatusNone || self.status == CourtesyCardPublishTaskStatusCanceled) {
                self.status = CourtesyCardPublishTaskStatusPending;
            }
        } else {
            if (self.status == CourtesyCardPublishTaskStatusProcessing || self.status == CourtesyCardPublishTaskStatusReady) { // 防止因为同步过快而无法通知结束
                self.status = CourtesyCardPublishTaskStatusAcknowledging;
            }
        }
    });
}

- (void)cardPublishPendSucceed:(CourtesyCardPublishPendRequest *)sender {
    if (sender.query) {
        if (self.status == CourtesyCardPublishTaskStatusPending) {
            // Start Rsync Helper
            NSString *queueIdentifier = [NSString stringWithFormat:kCourtesyCardPublishQueueIdentifier, self.card.token];
            dispatch_queue_t rsyncNewQueue = dispatch_queue_create([queueIdentifier UTF8String], NULL);
            dispatch_async(rsyncNewQueue, ^{
                [_helper startRsync];
            });
        }
    } else {
        if (self.status == CourtesyCardPublishTaskStatusAcknowledging) {
            dispatch_async_on_main_queue(^{
                [self setCardPublished:YES];
                self.status = CourtesyCardPublishTaskStatusDone;
                if (self.delegate && [self.delegate respondsToSelector:@selector(publishTaskDidFinished:withError:)]) {
                    [self.delegate publishTaskDidFinished:self withError:nil];
                }
            });
        }
    }
}

- (void)cardPublishPendFailed:(CourtesyCardPublishPendRequest *)sender
                    withError:(NSError *)error {
    dispatch_async_on_main_queue(^{
        if (error) {
            if ([[error localizedFailureReason] isEqualToString:kCourtesyRepeatedOperation]) {
                [self setCardPublished:YES];
            }
            self.error = error;
            self.status = CourtesyCardPublishTaskStatusCanceled;
        } else {
            [self setCardPublished:YES];
            self.status = CourtesyCardPublishTaskStatusDone;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(publishTaskDidFinished:withError:)]) {
            [self.delegate publishTaskDidFinished:self withError:error];
        }
    });
}

#pragma mark - CourtesyRsyncHelperDelegate

- (BOOL)rsyncShouldStart:(CourtesyRsyncHelper *)helper {
    if (self.status == CourtesyCardPublishTaskStatusPending) {
        dispatch_async_on_main_queue(^{
            self.status = CourtesyCardPublishTaskStatusReady;
        });
        return YES;
    }
    return NO;
}

- (void)rsyncDidStart:(CourtesyRsyncHelper *)helper {
    CYLog(@"totalBytes = %lld, physicalBytes = %lld, logicalBytes = %lld, skippedBytes = %lld", helper.totalBytes, helper.physicalBytes, helper.logicalBytes, helper.skippedBytes);
    dispatch_async_on_main_queue(^{
        if (self.status == CourtesyCardPublishTaskStatusProcessing || self.status == CourtesyCardPublishTaskStatusReady) {
            if (helper.totalBytes == helper.skippedBytes) {
                self.currentProgress = 0.0;
            } else {
                self.currentProgress = (float)helper.logicalBytes / (helper.totalBytes - helper.skippedBytes);
            }
            self.totalBytes = helper.totalBytes;
            self.physicalBytes = helper.physicalBytes;
            self.logicalBytes = helper.logicalBytes;
            self.skippedBytes = helper.skippedBytes;
            self.status = CourtesyCardPublishTaskStatusProcessing;
        }
    });
}

- (void)rsyncDidEnd:(CourtesyRsyncHelper *)helper
          withError:(NSError *)error {
    dispatch_async_on_main_queue(^{
        if (error) {
            self.error = error;
            self.status = CourtesyCardPublishTaskStatusCanceled;
        } else {
            [self startTaskWithQuery:NO];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(publishTaskDidFinished:withError:)]) {
            [self.delegate publishTaskDidFinished:self withError:error];
        }
    });
}

#pragma mark - Init

- (instancetype)initWithCard:(CourtesyCardModel *)card {
    if (self = [super init]) {
        _card = card;
        
        CourtesyRsyncHelper *currentHelper = [CourtesyRsyncHelper new];
        currentHelper.secure = NO;
        currentHelper.requestType = CourtesyRsyncHelperRequestTypeUpload;
        currentHelper.host = API_RSYNC_HOST;
        currentHelper.port = API_RSYNC_PORT;
        currentHelper.username = API_RSYNC_USERNAME;
        currentHelper.password = API_RSYNC_PASSWORD;
        currentHelper.moduleName = API_RSYNC_MODULE;
        currentHelper.remotePath = [@"/" stringByAppendingPathComponent:self.card.token];
        currentHelper.localPath = [self.card.local_template savedAttachmentsPath];
        currentHelper.cachesPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:kCourtesyCardPublishQueueCacheIdentifier, self.card.token]];
#ifdef DEBUG
        currentHelper.uploadSpeedLimit = 64.0;
        currentHelper.downloadSpeedLimit = 64.0;
#endif
        currentHelper.delegate = self;
        
        NSAssert(currentHelper != nil, @"Cannot initialize new rsync helper!");
        _helper = currentHelper;
    }
    return self;
}

#pragma mark - Status Notification

- (void)setStatus:(CourtesyCardPublishTaskStatus)status {
    _status = status;
    if (!_card) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kCourtesyCardComposeQueueUpdated object:_card];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
