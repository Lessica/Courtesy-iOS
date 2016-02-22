//
//  Utils.h
//  Courtesy
//
//  Created by Zheng on 2/22/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotificationUtils : NSObject

// Notifications
+ (BOOL)allowNotifications;
+ (UIUserNotificationSettings *)requestForNotifications;

@end
