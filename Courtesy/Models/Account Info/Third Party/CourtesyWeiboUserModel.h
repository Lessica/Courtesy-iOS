//
//  CourtesyWeiboUserModel.h
//  Courtesy
//
//  Created by Zheng on 5/9/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

@interface CourtesyWeiboUserModel : JSONModel
@property (nonatomic, copy) NSString *openId;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, assign) NSUInteger expirationTime;

@end
