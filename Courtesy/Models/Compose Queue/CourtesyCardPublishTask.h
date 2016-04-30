//
//  CourtesyCardPublishTask.h
//  Courtesy
//
//  Created by Zheng on 4/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CourtesyCardModel.h"
#import "CourtesyRsyncHelper.h"

typedef enum : NSUInteger {
    CourtesyCardPublishTaskStatusNone = 0,
    CourtesyCardPublishTaskStatusReady = 1,
    CourtesyCardPublishTaskStatusProcessing = 2,
    CourtesyCardPublishTaskStatusDone = 4,
    CourtesyCardPublishTaskStatusCanceled = 5,
    CourtesyCardPublishTaskStatusPending = 6,
    CourtesyCardPublishTaskStatusAcknowledging = 7
} CourtesyCardPublishTaskStatus;

@class CourtesyCardPublishTask;

@protocol CourtesyCardPublishTaskDelegate <NSObject>
@optional
- (void)publishTaskDidStart:(CourtesyCardPublishTask *)task;
@optional
- (void)publishTaskDidFinished:(CourtesyCardPublishTask *)task withError:(NSError *)error;

@end

@interface CourtesyCardPublishTask : NSObject
@property (nonatomic, strong, readonly) CourtesyCardModel *card;
@property (nonatomic, strong, readonly) CourtesyRsyncHelper *helper;
@property (nonatomic, weak) id<CourtesyCardPublishTaskDelegate> delegate;

@property (nonatomic, assign) CourtesyCardPublishTaskStatus status;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) float currentProgress;
@property (nonatomic, assign) int64_t totalBytes;
@property (nonatomic, assign) int64_t physicalBytes;
@property (nonatomic, assign) int64_t logicalBytes;
@property (nonatomic, assign) int64_t skippedBytes;

- (instancetype)initWithCard:(CourtesyCardModel *)card;
- (void)startTaskWithQuery:(BOOL)query;
- (void)stopTask;

@end
