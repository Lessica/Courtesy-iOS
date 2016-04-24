//
//  CourtesyCardDeleteRequestModel.h
//  Courtesy
//
//  Created by Zheng on 4/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonRequestModel.h"
#import "CourtesyCardModel.h"

typedef enum : NSUInteger {
    CourtesyCardDeleteRequestStandardError = 0,
} CourtesyCardDeleteRequestErrorCode;

@class CourtesyCardDeleteRequestModel;

@protocol CourtesyCardDeleteRequestDelegate <NSObject>

@optional
- (void)cardDeleteRequestSucceed:(CourtesyCardDeleteRequestModel *)sender;
@optional
- (void)cardDeleteRequestFailed:(CourtesyCardDeleteRequestModel *)sender
                      withError:(NSError *)error;

@end

@interface CourtesyCardDeleteRequestModel : CourtesyCommonRequestModel
@property (nonatomic, strong) CourtesyCardModel<Ignore> *card;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, weak) id<Ignore, CourtesyCardDeleteRequestDelegate> delegate;
@property (nonatomic, assign) BOOL toBan;

- (instancetype)initWithDelegate:(id)delegate;
- (BOOL)isRequestingDelete;
- (void)sendRequest;

@end
