//
//  FileUtils.h
//  Courtesy
//
//  Created by Zheng on 2/22/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCFileManager.h"

@interface FileUtils : NSObject

// Caches
+ (NSError *)cleanCache;
+ (NSString *)cachePath;
+ (NSString *)formattedCacheSize;
+ (NSString *)totalDiskSpace;
+ (NSString *)freeDiskSpace;

@end
