//
//  CourtesyAccountModel.h
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAccountProfileModel.h"

@interface CourtesyAccountModel : NSObject

@property (nonatomic, assign) NSUInteger userId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, assign) NSUInteger registered_at;
@property (nonatomic, assign) NSUInteger last_login_at;
@property (nonatomic, assign) NSUInteger card_count;
@property (nonatomic, copy) NSString *cookies;
@property (nonatomic, strong) CourtesyAccountProfileModel *profile;

@end
