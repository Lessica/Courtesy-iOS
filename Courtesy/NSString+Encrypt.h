//
//  NSString+Encrypt.h
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+Encrypt.h"

@interface NSString (encrypto)
- (NSData *) base64_decode;
- (NSString *) md5;
- (NSString *) sha1;
@end
