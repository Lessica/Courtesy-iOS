//
//  GlobalSettings.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "GlobalSettings.h"

@interface GlobalSettings ()

@end

@implementation GlobalSettings

- (instancetype)init {
    if (self = [super init]) {
        // 检查是否有会话
        if ([SessionUtils hasSessionKey]) {
            _hasLogin = YES;
        } else {
            _hasLogin = NO;
        }
        _currentAccount = nil;
    }
    return self;
}

+ (id)sharedInstance {
    static GlobalSettings *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

@end
