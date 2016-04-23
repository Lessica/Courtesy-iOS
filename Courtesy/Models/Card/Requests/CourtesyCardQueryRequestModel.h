//
//  CourtesyCardQueryRequestModel.h
//  Courtesy
//
//  Created by Zheng on 4/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonRequestModel.h"
#import "CourtesyCardModel.h"

typedef enum : NSUInteger {
    CourtesyCardQueryRequestStandardError = 0,
} CourtesyCardQueryRequestErrorCode;

@class CourtesyCardQueryRequestModel;

@protocol CourtesyCardQueryRequestDelegate <NSObject>
@optional
- (void)cardQueryRequestSucceed:(CourtesyCardQueryRequestModel *)sender;
@optional
- (void)cardQueryRequestFailed:(CourtesyCardQueryRequestModel *)sender
                     withError:(NSError *)error;

@end

@interface CourtesyCardQueryRequestModel : CourtesyCommonRequestModel
@property (nonatomic, copy) NSString *token;
@property (nonatomic, strong) NSDictionary<Ignore> *card_dict;
@property (nonatomic, weak) id<Ignore, CourtesyCardQueryRequestDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate;
- (BOOL)isRequestingQuery;
- (void)sendRequest;

@end
