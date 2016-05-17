//
//  CourtesyWeixinAccountModel.h
//  Courtesy
//
//  Created by Zheng on 5/17/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

@interface CourtesyWeixinAccountModel : JSONModel
@property (nonatomic, copy) NSString *openId;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, assign) NSUInteger expirationTime;

@end
