//
//  NSData+Encrypt.h
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Encrypt)
- (NSString *) md5;
- (NSString *) sha1;
- (NSString *) base64_encode;
@end
