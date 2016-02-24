//
//  NSString+Encrypt.m
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NSString+Encrypt.h"

@implementation NSString (encrypto)
- (NSData *) base64_decode
{
    return [[NSData alloc] initWithBase64EncodedString:self
                                               options:0];
}

- (NSString *) md5 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data md5];
}

- (NSString *) sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data sha1];
}
@end
