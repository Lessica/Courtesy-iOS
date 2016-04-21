//
//  CourtesyCardPublishPendRequest.h
//  Courtesy
//
//  Created by Zheng on 4/18/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonRequestModel.h"
#import "CourtesyCardModel.h"

typedef enum : NSUInteger {
    CourtesyCardPublishPendStandardError = 0,
} CourtesyCardPublishPendErrorCode;

@class CourtesyCardPublishPendRequest;

@protocol CourtesyCardPublishPendDelegate <NSObject>

@optional
- (void)cardPublishPendDidStart:(CourtesyCardPublishPendRequest *)sender;
@optional
- (void)cardPublishPendSucceed:(CourtesyCardPublishPendRequest *)sender;
@optional
- (void)cardPublishPendFailed:(CourtesyCardPublishPendRequest *)sender
                    withError:(NSError *)error;

@end

@interface CourtesyCardPublishPendRequest : CourtesyCommonRequestModel
@property (nonatomic, strong) CourtesyCardModel *card_info;
@property (nonatomic, assign) BOOL query;

@property (nonatomic, weak) id<Ignore, CourtesyCardPublishPendDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate;
- (BOOL)isRequestingPend;
- (void)sendRequest;
- (void)stopRequest;

@end
