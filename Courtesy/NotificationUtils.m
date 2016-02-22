//
//  Utils.m
//  Courtesy
//
//  Created by Zheng on 2/22/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NotificationUtils.h"

@implementation NotificationUtils

+ (BOOL)allowNotifications {
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone != setting.types) {
        return YES;
    } else {
        return NO;
    }
}

+ (UIUserNotificationSettings *)requestForNotifications {
    UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
    action1.identifier = @"action1_identifier";
    action1.title=@"Accept";
    action1.activationMode = UIUserNotificationActivationModeForeground;
    
    UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
    action2.identifier = @"action2_identifier";
    action2.title=@"Reject";
    action2.activationMode = UIUserNotificationActivationModeBackground;
    action2.authenticationRequired = YES;
    action2.destructive = YES;
    
    UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
    categorys.identifier = @"category1";
    [categorys setActions:@[action1, action2] forContext:(UIUserNotificationActionContextDefault)];
    
    UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert
                                                                                 categories:[NSSet setWithObject:categorys]];
    
    return userSettings;
}

@end
