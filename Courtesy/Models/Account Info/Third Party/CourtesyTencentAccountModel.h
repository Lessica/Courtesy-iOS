//
//  CourtesyTencentAccountModel.h
//  Courtesy
//
//  Created by Zheng on 4/29/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

@interface CourtesyTencentAccountModel : JSONModel
@property (nonatomic, copy) NSString *openId;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, assign) NSUInteger expirationTime;

@end
