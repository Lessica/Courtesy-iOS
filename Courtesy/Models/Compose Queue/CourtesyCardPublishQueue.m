//
//  CourtesyCardPublishQueue.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPublishQueue.h"
#import "FCFileManager.h"

@interface CourtesyCardPublishQueue () <CourtesyCardPublishTaskDelegate>
@property (nonatomic, strong) NSMutableArray <CourtesyCardPublishTask *> *cardQueue;

@end

@implementation CourtesyCardPublishQueue {
    NSUInteger maxQueueSize;
}

#pragma mark - CourtesyCardPublishTaskDelegate

- (void)publishTaskDidStart:(CourtesyCardPublishTask *)task {
    NSString *type = @"发布";
    if (task.card.hasPublished) {
        type = @"编辑";
    }
    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"开始%@卡片 - %@", type, task.card.local_template.mainTitle]
                                   dismissAfter:kStatusBarNotificationTime
                                      styleName:JDStatusBarStyleDefault];
}

- (void)publishTaskDidFinished:(CourtesyCardPublishTask *)task withError:(NSError *)error {
    if ([self countOfTasksInPublishQueue] == 0) {
        NSUInteger currentSize = maxQueueSize;
        if (error == nil) {
            if (currentSize != 0) {
                [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%lu 张卡片同步成功", (unsigned long)currentSize]
                                           dismissAfter:kStatusBarNotificationTime
                                              styleName:JDStatusBarStyleSuccess];
            }
        } else {
            [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"卡片同步失败 - %@", [error localizedDescription]]
                                       dismissAfter:kStatusBarNotificationTime
                                          styleName:JDStatusBarStyleError];
        }
        maxQueueSize = 0;
    }
    // 清理状态
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
    _currentTask.delegate = self;
    [_currentTask startTaskWithQuery:YES];
}

- (void)addCardPublishTask:(CourtesyCardModel *)card {
    NSAssert(card != nil, @"Add Card Publish Task With Nil Value!");
    [self removeCompletedTasks];
    if ([self publishTaskInPublishQueueWithCard:card]) {
        CYLog(@"Card was in queue.");
        return;
    }
    CourtesyCardPublishTask *newTask = [[CourtesyCardPublishTask alloc] initWithCard:card];
    [self.cardQueue addObject:newTask];
    maxQueueSize++;
    if (!_currentTask) {
        [self startQueue];
    }
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
    if (card == _currentTask.card) {
        [_currentTask stopTask];
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
    for (CourtesyCardPublishTask *t in self.cardQueue) {
        t.status = CourtesyCardPublishTaskStatusCanceled;
    }
    if (_currentTask != nil) {
        [_currentTask stopTask];
    }
    maxQueueSize = 0;
    [self removeCompletedTasks];
}

- (void)removeCompletedTasks {
    NSMutableArray *tasksShouldRemoved = [NSMutableArray new];
    for (CourtesyCardPublishTask *t in self.cardQueue) {
        if ((t.status == CourtesyCardPublishTaskStatusDone ||
            t.status == CourtesyCardPublishTaskStatusCanceled)
            ) {
            [tasksShouldRemoved addObject:t];
        }
    }
    for (CourtesyCardPublishTask *r in tasksShouldRemoved) {
        [self.cardQueue removeObject:r];
    }
}

@end
