//
//  AppStorage.m
//  Courtesy
//
//  Created by Zheng on 3/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppStorage.h"
#define kCourtesyDB @"kCourtesyDB"

@implementation AppStorage

+ (id)sharedInstance {
    static AppStorage *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithName:kCourtesyDB];
    });
    
    return sharedInstance;
}

@end
