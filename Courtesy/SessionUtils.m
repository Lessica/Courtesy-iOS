//
//  SessionUtils.m
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "SessionUtils.h"

@implementation SessionUtils

+ (BOOL)hasSessionKey {
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        if ([[cookie domain] isEqualToString:API_DOMAIN] && [[cookie name] isEqualToString:@"sessionid"]) {
            return YES;
        }
    }
    return NO;
}

@end
