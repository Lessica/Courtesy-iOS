//
//  CourtesyCardEditRequestModel.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonRequestModel.h"
#import "CourtesyCardModel.h"

@interface CourtesyCardEditRequestModel : CourtesyCommonRequestModel
@property (nonatomic, copy) NSString *token;
@property (nonatomic, strong) CourtesyCardModel *card_info;

@end
