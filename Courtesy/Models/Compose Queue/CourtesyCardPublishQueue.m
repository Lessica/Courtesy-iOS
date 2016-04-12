//
//  CourtesyCardPublishQueue.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPublishQueue.h"
#import "CourtesyRsyncHelper.h"
#import "FCFileManager.h"

#define kCourtesyCardPublishQueueIdentifier @"kCourtesyCardPublishQueueIdentifier-%@"
#define kCourtesyCardPublishQueueCacheIdentifier @"kCourtesyCardPublishQueueCacheIdentifier-%@"

@interface CourtesyCardPublishQueue () <CourtesyRsyncHelperDelegate>
@property (nonatomic, strong) NSMutableArray <CourtesyCardPublishTask *> *cardQueue;

@end

@implementation CourtesyCardPublishQueue {
    NSUInteger maxQueueSize;
    CourtesyRsyncHelper *currentHelper;
}

- (BOOL)rsyncShouldStart:(CourtesyRsyncHelper *)helper {
    NSAssert(self.currentTask != nil, @"Card Publish Task was deallocated while rsync helper was still registered with it!");
    if (self.currentTask.status == CourtesyCardPublishTaskStatusNone) {
        self.currentTask.status = CourtesyCardPublishTaskStatusReady;
        return YES;
    }
    return NO;
}

- (void)rsyncDidStart:(CourtesyRsyncHelper *)helper {
    CYLog(@"totalBytes = %lld, physicalBytes = %lld, logicalBytes = %lld, skippedBytes = %lld", helper.totalBytes, helper.physicalBytes, helper.logicalBytes, helper.skippedBytes);
    NSAssert(self.currentTask != nil, @"Card Publish Task was deallocated while rsync helper was still registered with it!");
    self.currentTask.status = CourtesyCardPublishTaskStatusProcessing;
    self.currentTask.currentProgress = (float)helper.logicalBytes / helper.totalBytes;
    self.currentTask.totalBytes = helper.totalBytes;
    self.currentTask.physicalBytes = helper.physicalBytes;
    self.currentTask.logicalBytes = helper.logicalBytes;
    self.currentTask.skippedBytes = helper.skippedBytes;
}

- (void)rsyncDidEnd:(CourtesyRsyncHelper *)helper withError:(NSError *)error {
    NSAssert(self.currentTask != nil, @"Card Publish Task was deallocated while rsync helper was still registered with it!");
    if (error) {
        CYLog(@"%@", error);
        self.currentTask.error = error;
        self.currentTask.status = CourtesyCardPublishTaskStatusCanceled;
        dispatch_async_on_main_queue(^{
            [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"卡片上传失败 - %@", [error localizedDescription]]
                                       dismissAfter:kStatusBarNotificationTime
                                          styleName:JDStatusBarStyleError];
        });
    } else {
        if ([self countOfTasksInPublishQueue] > 1) {
            
        } else {
            NSUInteger currentSize = maxQueueSize;
            dispatch_async_on_main_queue(^{
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%lu 张卡片上传成功", (unsigned long)currentSize]
                                           dismissAfter:kStatusBarNotificationTime
                                              styleName:JDStatusBarStyleSuccess];
            });
            maxQueueSize = 0;
        }
        self.currentTask.status = CourtesyCardPublishTaskStatusDone;
    }
    // 清理状态
    currentHelper = nil;
    _currentTask = nil;
    [self removeCompletedTasks];
    // 开始下一个
    [self startQueue];
}

+ (id)sharedQueue {
    static CourtesyCardPublishQueue *sharedQueue = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedQueue = [[self alloc] init];
    });
    return sharedQueue;
}

- (instancetype)init {
    if (self = [super init]) {
        // 初始化
        self.cardQueue = [NSMutableArray new];
        _currentTask = nil;
        currentHelper = nil;
        maxQueueSize = 0;
    }
    return self;
}

- (void)startQueue {
    if (_currentTask) {
        CYLog(@"Has task in queue.");
        return;
    }
    _currentTask = [self firstWaitingTask];
    if (!_currentTask) {
        return;
    }
    NSString *queueIdentifier = [NSString stringWithFormat:kCourtesyCardPublishQueueIdentifier, self.currentTask.card.token];
    dispatch_queue_t rsyncNewQueue = dispatch_queue_create([queueIdentifier UTF8String], NULL);
    dispatch_async(rsyncNewQueue, ^{
        currentHelper = [CourtesyRsyncHelper new];
        currentHelper.secure = NO;
        currentHelper.requestType = CourtesyRsyncHelperRequestTypeUpload;
        currentHelper.host = API_RSYNC_HOST;
        currentHelper.port = API_RSYNC_PORT;
        currentHelper.username = API_RSYNC_USERNAME;
        currentHelper.password = API_RSYNC_PASSWORD;
        currentHelper.moduleName = API_RSYNC_MODULE;
        currentHelper.remotePath = [@"/" stringByAppendingPathComponent:self.currentTask.card.token];
        currentHelper.localPath = [self.currentTask.card.card_data savedAttachmentsPath];
        currentHelper.cachesPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:kCourtesyCardPublishQueueCacheIdentifier, self.currentTask.card.token]];
#ifdef DEBUG
        currentHelper.uploadSpeedLimit = 1024.0;
        currentHelper.downloadSpeedLimit = 1024.0;
#endif
        currentHelper.delegate = self;
        [currentHelper startRsync];
    });
}

- (void)addCardPublishTask:(CourtesyCardModel *)card {
    NSAssert(card != nil, @"Add Card Publish Task With Nil Value!");
    if ([self taskInPublishQueueWithCard:card]) {
        CYLog(@"Card was in queue.");
        return;
    }
    CourtesyCardPublishTask *newTask = [[CourtesyCardPublishTask alloc] initWithCard:card];
    [self.cardQueue addObject:newTask];
    maxQueueSize++;
    if (!self.currentTask) {
        [self startQueue];
    }
    [self removeCompletedTasks];
}

- (CourtesyCardPublishTask *)firstWaitingTask {
    for (CourtesyCardPublishTask *t in self.cardQueue) {
        if (t.status == CourtesyCardPublishTaskStatusNone) {
            return t;
        }
    }
    return nil;
}

- (NSUInteger)countOfTasksInPublishQueue {
    NSUInteger count = 0;
    for (CourtesyCardPublishTask *t in self.cardQueue) {
        if (t.status != CourtesyCardPublishTaskStatusDone &&
            t.status != CourtesyCardPublishTaskStatusCanceled) {
            count++;
        }
    }
    return count;
}

- (CourtesyCardPublishTask *)taskInPublishQueueWithCard:(CourtesyCardModel *)card {
    NSAssert(card != nil, @"Check Card Publish Task With Nil Value!");
    for (CourtesyCardPublishTask *t in self.cardQueue) {
        if (t.card == card) {
            return t;
        }
    }
    return nil;
}

- (CourtesyCardPublishTask *)publishTaskInPublishQueueWithCard:(CourtesyCardModel *)card {
    NSAssert(card != nil, @"Check Card Publish Task With Nil Value!");
    for (CourtesyCardPublishTask *t in self.cardQueue) {
        if (t.status != CourtesyCardPublishTaskStatusDone &&
            t.status != CourtesyCardPublishTaskStatusCanceled &&
            t.card == card) {
            return t;
        }
    }
    return nil;
}

- (void)removeCardPublishTask:(CourtesyCardModel *)card {
    NSAssert(card != nil, @"Remove Card Publish Task With Nil Value!");
    if (card == self.currentTask.card) {
        if (currentHelper) {
            [currentHelper pauseRsync];
        }
    } else {
        CourtesyCardPublishTask *task = [self publishTaskInPublishQueueWithCard:card];
        if (task) {
            task.status = CourtesyCardPublishTaskStatusCanceled;
        }
    }
    maxQueueSize--;
    [self removeCompletedTasks];
}

- (void)removeAllTasks {
    if (self.currentTask != nil) {
        if (currentHelper) {
            [currentHelper pauseRsync];
        }
    }
    for (CourtesyCardPublishTask *t in self.cardQueue) {
        t.status = CourtesyCardPublishTaskStatusCanceled;
    }
    maxQueueSize = 0;
    [self removeCompletedTasks];
}

- (void)removeCompletedTasks {
    NSMutableArray *tasksShouldRemoved = [NSMutableArray new];
    for (CourtesyCardPublishTask *t in self.cardQueue) {
        if ((t.status == CourtesyCardPublishTaskStatusDone ||
            t.status == CourtesyCardPublishTaskStatusCanceled) &&
            t.hasObserver == NO
            ) {
            [tasksShouldRemoved addObject:t];
        }
    }
    for (CourtesyCardPublishTask *r in tasksShouldRemoved) {
        [self.cardQueue removeObject:r];
    }
}

@end
