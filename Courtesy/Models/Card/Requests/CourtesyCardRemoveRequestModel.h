//
//  CourtesyCardRemoveRequestModel.h
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonRequestModel.h"
#import "CourtesyCardModel.h"

typedef enum : NSUInteger {
    CourtesyCardRemoveRequestStandardError = 0,
} CourtesyCardRemoveRequestErrorCode;

@class CourtesyCardRemoveRequestModel;

@protocol CourtesyCardRemoveRequestDelegate <NSObject>
@optional
- (void)cardRemoveRequestSucceed:(CourtesyCardRemoveRequestModel *)sender;
@optional
- (void)cardRemoveRequestFailed:(CourtesyCardRemoveRequestModel *)sender
                      withError:(NSError *)error;

@end

@interface CourtesyCardRemoveRequestModel : CourtesyCommonRequestModel
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) BOOL isHistory;
@property (nonatomic, strong) CourtesyCardModel<Ignore> *card;
@property (nonatomic, weak) id<Ignore, CourtesyCardRemoveRequestDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate;
- (void)sendRequest;

@end
