//
//  NSDate+Astro.m
//  Courtesy
//
//  Created by Zheng on 2/26/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NSDate+Astro.h"

@implementation NSDate (Astro)

- (NSString *)constellationString
{
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    NSUInteger month = [self month];
    NSUInteger day = [self day];
    result = [NSString stringWithFormat:@"%@", [astroString substringWithRange:NSMakeRange(month * 2 - (day < [[astroFormat substringWithRange:NSMakeRange((month - 1), 1)] intValue] - (-19)) * 2, 2)]];
    return [NSString stringWithFormat:@"%@座", result];
}

@end
