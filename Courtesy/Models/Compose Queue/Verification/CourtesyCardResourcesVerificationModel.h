//
//  CourtesyCardResourcesVerificationModel.h
//  Courtesy
//
//  Created by Zheng on 4/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonRequestModel.h"
#import "CourtesyCardModel.h"
#import "CourtesyCardResourceModel.h"

@interface CourtesyCardResourcesVerificationModel : CourtesyCommonRequestModel
@property (nonatomic, copy) NSString *card_token;
@property (nonatomic, assign) NSUInteger synced_at;
@property (nonatomic, strong) NSArray <CourtesyCardResourceModel> *statics;

- (instancetype)initWithCard:(CourtesyCardModel *)card;
- (void)generateVerificationInfo;

@end
