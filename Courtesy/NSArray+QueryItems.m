//
//  NSArray+QueryItems.m
//  Courtesy
//
//  Created by Zheng on 2/28/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NSArray+QueryItems.h"

@implementation NSArray (QueryItems)

- (NSString *)valueForQueryKey:(NSString *)key
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[self filteredArrayUsingPredicate:predicate] firstObject];
    return queryItem.value;
}

@end
