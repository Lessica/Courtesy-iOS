//
//  CourtesyRsyncHelper.h
//  Courtesy
//
//  Created by Zheng on 4/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

// "libacrosync" is licensed under the RPL License, no commerical use.
// Github: https://github.com/gilbertchen/acrosync-library
// Reference: https://rsync.samba.org/tech_report/

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CourtesyRsyncHelperRequestTypeUpload   = 0,
    CourtesyRsyncHelperRequestTypeDownload = 1,
} CourtesyRsyncHelperRequestType;

typedef enum : NSUInteger {
    CourtesyRsyncHelperInvalidProperty = 0,
} CourtesyRsyncHelperErrorCode;

typedef enum : NSUInteger {
    CourtesyRsyncHelperStatusNone = 0,
    CourtesyRsyncHelperStatusDownloading = 1,
    CourtesyRsyncHelperStatusUploading = 2,
} CourtesyRsyncHelperStatus;

@class CourtesyRsyncHelper;

@protocol CourtesyRsyncHelperDelegate <NSObject>
@optional
- (BOOL)rsyncShouldStart:(CourtesyRsyncHelper *)helper;
@optional
- (void)rsyncDidStart:(CourtesyRsyncHelper *)helper;
@optional
- (void)rsyncDidEnd:(CourtesyRsyncHelper *)helper withError:(NSError *)error;

@end

@interface CourtesyRsyncHelper : NSObject

@property (nonatomic, assign) BOOL secure;
@property (nonatomic, assign) CourtesyRsyncHelperRequestType requestType;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *moduleName;
@property (nonatomic, copy) NSString *remotePath;
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *cachesPath;
@property (nonatomic, weak) id<CourtesyRsyncHelperDelegate> delegate;

@property (nonatomic, assign) int uploadSpeedLimit;
@property (nonatomic, assign) int downloadSpeedLimit;
@property (nonatomic, assign, readonly) int64_t totalBytes;
@property (nonatomic, assign, readonly) int64_t physicalBytes;
@property (nonatomic, assign, readonly) int64_t logicalBytes;
@property (nonatomic, assign, readonly) int64_t skippedBytes;
@property (nonatomic, assign, readonly) int g_cancelFlag;
@property (nonatomic, assign, readonly) CourtesyRsyncHelperStatus status;

- (void)startRsync;
- (void)pauseRsync;

@end
