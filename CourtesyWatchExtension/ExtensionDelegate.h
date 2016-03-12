//
//  ExtensionDelegate.h
//  watch Extension
//
//  Created by Zheng on 3/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "MMWormhole.h"

@interface ExtensionDelegate : NSObject <WKExtensionDelegate>
@property (nonatomic, strong) NSUserDefaults *sharedUserDefaults;
@property (nonatomic, strong) MMWormhole *sharedWormhole;

+ (instancetype)sharedDelegate;

@end
