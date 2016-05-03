//
//  CourtesyCardPublicRequestModel.h
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

@class CourtesyCardPublicRequestModel;

@protocol CourtesyCardPublicRequestDelegate <NSObject>

@optional
- (void)cardPublicRequestSucceed:(CourtesyCardPublicRequestModel *)sender;
@optional
- (void)cardPublicRequestFailed:(CourtesyCardPublicRequestModel *)sender
                      withError:(NSError *)error;

@end

@interface CourtesyCardPublicRequestModel : CourtesyCommonRequestModel
@property (nonatomic, strong) CourtesyCardModel<Ignore> *card;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, weak) id<Ignore, CourtesyCardPublicRequestDelegate> delegate;
@property (nonatomic, assign) BOOL toBan;

- (instancetype)initWithDelegate:(id)delegate;
- (BOOL)isRequestingPublic;
- (void)sendRequest;

@end
