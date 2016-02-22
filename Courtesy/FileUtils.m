//
//  FileUtils.m
//  Courtesy
//
//  Created by Zheng on 2/22/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "FileUtils.h"

@implementation FileUtils

+ (NSString *)cachePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (!paths) {
        return nil;
    }
    NSString *path = [paths objectAtIndex:0];
    return path;
}

+ (NSString *)formattedCacheSize {
    return [FCFileManager sizeFormattedOfDirectoryAtPath:[FileUtils cachePath]];
}

+ (NSError *)cleanCache {
    NSError *error = nil;
    [FCFileManager removeFilesInDirectoryAtPath:[FileUtils cachePath] error:&error];
    return error;
}

+ (NSString *)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSNumber *size = [fattributes objectForKey:NSFileSystemSize];
    return [FCFileManager sizeFormatted:size];
}

+ (NSString *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSNumber *size = [fattributes objectForKey:NSFileSystemFreeSize];
    
    return [FCFileManager sizeFormatted:size];
}

@end
