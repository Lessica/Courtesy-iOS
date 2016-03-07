//
//  NSDictionary+Subscript.m
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NSDictionary+Subscript.h"

@implementation NSDictionary (Subscript)

- (BOOL)hasKey:(NSString *)key {
    if (![self objectForKey:key]) {
        return NO;
    }
    id obj = [self objectForKey:key];
    
    return ![obj isEqual:[NSNull null]];
}

@end
