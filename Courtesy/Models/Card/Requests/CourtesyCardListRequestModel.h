//
//  CourtesyCardListRequestModel.h
//  Courtesy
//
//  Created by Zheng on 5/2/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardModel.h"
#import "CourtesyCommonRequestModel.h"

typedef enum : NSUInteger {
    CourtesyCardListStandardError = 0,
} CourtesyCardListErrorCode;

@class CourtesyCardListRequestModel;

@protocol CourtesyCardListRequestDelegate <NSObject>
@optional
- (void)cardListRequestSucceed:(CourtesyCardListRequestModel *)model;
@optional
- (void)cardListRequestFailed:(CourtesyCardListRequestModel *)model withError:(NSError *)error;

@end

@interface CourtesyCardListRequestModel : CourtesyCommonRequestModel
@property (nonatomic, assign) NSUInteger user_id;
@property (nonatomic, assign) NSUInteger from;
@property (nonatomic, assign) NSUInteger to;
@property (nonatomic, assign) BOOL history;
@property (nonatomic, strong) NSMutableArray <CourtesyCardModel *> *cards; // Callback Data Source
@property (nonatomic, weak) id<Ignore, CourtesyCardListRequestDelegate> delegate;

- (void)sendAsyncListRequest;
@end
