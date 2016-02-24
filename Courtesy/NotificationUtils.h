//
//  Utils.h
//  Courtesy
//
//  Created by Zheng on 2/22/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define NOTIFICATION_LOGIN_SUCCEED @"kCourtesyLoginSucceed"
#define NOTIFICATION_LOGIN_EXPIRED @"kCourtesyLoginExpired"

@interface NotificationUtils : NSObject

// Notifications
+ (BOOL)allowNotifications;
+ (UIUserNotificationSettings *)requestForNotifications;
+ (void)sendNotification:(NSString *)identifier
              withObject:(id)object
                withInfo:(NSDictionary *)userInfo;
@end
