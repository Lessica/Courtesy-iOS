//
//  CourtesyCardPublishTask.m
//  Courtesy
//
//  Created by Zheng on 4/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPublishTask.h"

#define kCourtesyCardPublishQueueIdentifier @"kCourtesyCardPublishQueueIdentifier-%@"
#define kCourtesyCardPublishQueueCacheIdentifier @"kCourtesyCardPublishQueueCacheIdentifier-%@"

@interface CourtesyCardPublishTask () <CourtesyRsyncHelperDelegate>

@end

@implementation CourtesyCardPublishTask

- (BOOL)rsyncShouldStart:(CourtesyRsyncHelper *)helper {
    if (self.status == CourtesyCardPublishTaskStatusNone) {
        dispatch_async_on_main_queue(^{
            self.status = CourtesyCardPublishTaskStatusReady;
            if (self.delegate && [self.delegate respondsToSelector:@selector(publishTaskDidStart:)]) {
                [self.delegate publishTaskDidStart:self];
            }
        });
        return YES;
    }
    return NO;
}

- (void)rsyncDidStart:(CourtesyRsyncHelper *)helper {
    CYLog(@"totalBytes = %lld, physicalBytes = %lld, logicalBytes = %lld, skippedBytes = %lld", helper.totalBytes, helper.physicalBytes, helper.logicalBytes, helper.skippedBytes);
    dispatch_async_on_main_queue(^{
        self.status = CourtesyCardPublishTaskStatusProcessing;
        if (helper.totalBytes == helper.skippedBytes) {
            self.currentProgress = 1.0;
        } else {
            self.currentProgress = (float)helper.logicalBytes / (helper.totalBytes - helper.skippedBytes);
        }
        self.totalBytes = helper.totalBytes;
        self.physicalBytes = helper.physicalBytes;
        self.logicalBytes = helper.logicalBytes;
        self.skippedBytes = helper.skippedBytes;
    });
}

- (void)rsyncDidEnd:(CourtesyRsyncHelper *)helper
          withError:(NSError *)error {
    dispatch_async_on_main_queue(^{
        if (error) {
            self.error = error;
            self.status = CourtesyCardPublishTaskStatusCanceled;
        } else {
            self.status = CourtesyCardPublishTaskStatusDone;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(publishTaskDidFinished:withError:)]) {
            [self.delegate publishTaskDidFinished:self withError:error];
        }
    });
}

- (instancetype)initWithCard:(CourtesyCardModel *)card {
    if (self = [super init]) {
        _card = card;
        _hasObserver = NO;
        
        CourtesyRsyncHelper *currentHelper = [CourtesyRsyncHelper new];
        currentHelper.secure = NO;
        currentHelper.requestType = CourtesyRsyncHelperRequestTypeUpload;
        currentHelper.host = API_RSYNC_HOST;
        currentHelper.port = API_RSYNC_PORT;
        currentHelper.username = API_RSYNC_USERNAME;
        currentHelper.password = API_RSYNC_PASSWORD;
        currentHelper.moduleName = API_RSYNC_MODULE;
        currentHelper.remotePath = [@"/" stringByAppendingPathComponent:self.card.token];
        currentHelper.localPath = [self.card.card_data savedAttachmentsPath];
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

- (void)startTask {
    NSString *queueIdentifier = [NSString stringWithFormat:kCourtesyCardPublishQueueIdentifier, self.card.token];
    dispatch_queue_t rsyncNewQueue = dispatch_queue_create([queueIdentifier UTF8String], NULL);
    dispatch_async(rsyncNewQueue, ^{
        [_helper startRsync];
    });
}

- (void)stopTask {
    [_helper pauseRsync];
}

- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context {
    if (!_hasObserver) {
        [super addObserver:observer forKeyPath:keyPath options:options context:context];
        _hasObserver = YES;
    }
}

- (void)removeObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath {
    if (_hasObserver) {
        [super removeObserver:observer forKeyPath:keyPath];
        _hasObserver = NO;
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
