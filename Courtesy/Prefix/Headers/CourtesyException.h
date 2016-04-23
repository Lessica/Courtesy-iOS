//
//  CourtesyException.h
//  Courtesy
//
//  Created by Zheng on 3/9/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#ifndef CourtesyException_h
#define CourtesyException_h

// 处理异常
#define NSException(_name, _reason) ([[NSException alloc] initWithName:_name reason:_reason userInfo:nil])
#define kCourtesyCommonErrorDomain @"com.darwin.courtesy"
#define kCourtesyInvalidHttpResponse @"kCourtesyInvalidHttpResponse"
#define kCourtesyUnexceptedObject @"kCourtesyUnexceptedObject"
#define kCourtesyUnexceptedStatus @"kCourtesyUnexceptedStatus"
#define kCourtesyRepeatedOperation @"kCourtesyRepeatedOperation"
#define kCourtesyForbidden @"kCourtesyForbidden"
#define kCourtesyAllocFailed @"kCourtesyAllocFailed"

#endif /* CourtesyException_h */
