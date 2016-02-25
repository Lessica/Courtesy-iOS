//
//  NSNotificationCenter+Action.m
//  Courtesy
//
//  Created by Zheng on 2/25/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NSNotificationCenter+Action.h"

@implementation NSNotificationCenter (Action)

+ (void)sendCTAction:(NSString *)action message:(NSString *)message {
    if (!message) message = @"";
    NSDictionary *infoDict = @{@"action": action, @"message": message};
    NSNotification *notification = [NSNotification notificationWithName:kCourtesyNotificationInfo object:nil userInfo:infoDict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
