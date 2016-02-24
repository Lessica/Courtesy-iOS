//
//  ExceptionUtils.h
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSException(_name, _reason) [[NSException alloc] initWithName:_name reason:_reason userInfo:nil]
#define kCourtesyInvalidHttpResponse @"kCourtesyInvalidHttpResponse"
#define kCourtesyUnexceptedObject @"kCourtesyUnexceptedObject"
#define kCourtesyUnexceptedStatus @"kCourtesyUnexceptedStatus"

@interface ExceptionUtils : NSObject

@end
