//
//  NSDate+Compare.m
//  Courtesy
//
//  Created by Zheng on 3/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NSDate+Compare.h"

@implementation NSDate (Compare)
- (NSString *)compareCurrentTime {
    NSTimeInterval  timeInterval = [self timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result = nil;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    } else if((temp = timeInterval / 60) < 60){
        result = [NSString stringWithFormat:@"%ld分钟前", temp];
    } else if((temp = temp / 60) < 24) {
        result = [NSString stringWithFormat:@"%ld小时前", temp];
    } else if((temp = temp / 24) < 30) {
        result = [NSString stringWithFormat:@"%ld天前", temp];
    } else if((temp = temp / 30) < 12) {
        result = [NSString stringWithFormat:@"%ld个月前", temp];
    } else {
        temp = temp / 12;
        result = [NSString stringWithFormat:@"%ld年前", temp];
    }
    return  result;
}

- (BOOL)isTheSameDayWith:(NSDate *)date {
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    if (
        (int)(([date timeIntervalSince1970] + timezoneFix) / (24 * 3600)) -
        (int)(([self timeIntervalSince1970] + timezoneFix) / (24 * 3600))
        == 0)
    {
        return YES;
    }
    return NO;
}

@end
