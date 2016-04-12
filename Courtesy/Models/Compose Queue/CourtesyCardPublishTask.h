//
//  CourtesyCardPublishTask.h
//  Courtesy
//
//  Created by Zheng on 4/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CourtesyCardModel.h"

typedef enum : NSUInteger {
    CourtesyCardPublishTaskStatusNone = 0,
    CourtesyCardPublishTaskStatusReady = 1,
    CourtesyCardPublishTaskStatusProcessing = 2,
    CourtesyCardPublishTaskStatusDone = 4,
    CourtesyCardPublishTaskStatusCanceled = 5
} CourtesyCardPublishTaskStatus;

@interface CourtesyCardPublishTask : NSObject
@property (nonatomic, strong, readonly) CourtesyCardModel *card;
@property (nonatomic, assign) CourtesyCardPublishTaskStatus status;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) float currentProgress;
@property (nonatomic, assign) int64_t totalBytes;
@property (nonatomic, assign) int64_t physicalBytes;
@property (nonatomic, assign) int64_t logicalBytes;
@property (nonatomic, assign) int64_t skippedBytes;
@property (nonatomic, assign, readonly) BOOL hasObserver;

- (instancetype)initWithCard:(CourtesyCardModel *)card;

@end
