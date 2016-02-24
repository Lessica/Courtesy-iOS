//
//  ValidateUtils.m
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "ValidateUtils.h"

@implementation ValidateUtils

+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
