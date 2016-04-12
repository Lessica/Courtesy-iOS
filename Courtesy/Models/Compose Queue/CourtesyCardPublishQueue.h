//
//  CourtesyCardPublishQueue.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CourtesyCardPublishTask.h"

@interface CourtesyCardPublishQueue : NSObject

@property (nonatomic, assign, readonly) NSUInteger totalTasks;
@property (nonatomic, assign, readonly) NSUInteger finishedTasks;

@property (nonatomic, strong, readonly) CourtesyCardPublishTask *currentTask;

+ (id)sharedQueue;
- (void)addCardPublishTask:(CourtesyCardModel *)card;
- (CourtesyCardPublishTask *)publishTaskInPublishQueueWithCard:(CourtesyCardModel *)card;
- (void)removeCardPublishTask:(CourtesyCardModel *)card;
- (void)removeAllTasks;

@end
