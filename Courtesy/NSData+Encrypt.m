//
//  NSData+Encrypt.m
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NSData+Encrypt.h"

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (Encrypt)
- (NSString*) sha1
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(self.bytes, (CC_LONG)self.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

-(NSString *) md5
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (CC_LONG)self.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

- (NSString *) base64_encode
{
    return [self base64EncodedStringWithOptions:0];
}
@end
