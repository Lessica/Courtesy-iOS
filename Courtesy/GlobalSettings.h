//
//  GlobalSettings.h
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAccountModel.h"

@interface GlobalSettings : NSObject

// 单例
+ (id)sharedInstance;

@property (nonatomic, assign) BOOL hasLogin;
@property (nonatomic, strong) CourtesyAccountModel* currentAccount;

@end
