//
//  CourtesyDebug.h
//  Courtesy
//
//  Created by Zheng on 3/9/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#ifndef CourtesyDebug_h
#define CourtesyDebug_h

#ifndef DEBUG
#define NSLog(...);
#else
#import "FLEXManager.h"
#endif

// 日志输出
#ifdef DEBUG
#define CYLog(fmt, ...) NSLog((@"\n[%@:%d]\n%s\n" fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#define CYLog(...);
#endif

#import "CourtesyException.h"

#endif /* CourtesyDebug_h */
