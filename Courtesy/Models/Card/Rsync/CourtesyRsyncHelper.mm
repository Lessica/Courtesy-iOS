//
//  CourtesyRsyncHelper.mm
//  Courtesy
//
//  Created by Zheng on 4/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#define kCourtesyRsyncErrorDomain @"com.darwin.courtesy-rsync"

#import "CourtesyRsyncHelper.h"
#import "FCFileManager.h"

#include "rsync_client.h"
#include "rsync_entry.h"
#include "rsync_file.h"
#include "rsync_log.h"
#include "rsync_pathutil.h"
#include "rsync_socketutil.h"
#include "rsync_sshio.h"
#include "rsync_socketio.h"

#include <libssh2.h>
#include <openssl/md5.h>

#include <string>
#include <vector>
#include <set>

#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <sstream>

@implementation CourtesyRsyncHelper

- (void)callbackDelegateWithErrorMessage:(NSString *)msg {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg                                                                      forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:kCourtesyRsyncErrorDomain code:CourtesyRsyncHelperInvalidProperty userInfo:userInfo];
    if (self.delegate && [self.delegate respondsToSelector:@selector(rsyncDidEnd:withError:)]) {
        [self.delegate rsyncDidEnd:self withError:error];
    }
}

- (void)callbackDelegateWithSuccess {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rsyncDidEnd:withError:)]) {
        [self.delegate rsyncDidEnd:self withError:nil];
    }
}

- (BOOL)checkProperties {
    if (
        self.requestType != CourtesyRsyncHelperRequestTypeUpload &&
        self.requestType != CourtesyRsyncHelperRequestTypeDownload
        ) {
        [self callbackDelegateWithErrorMessage:@"Invalid Request Type."];
        return NO;
    }
    if (!self.host) {
        [self callbackDelegateWithErrorMessage:@"Empty Host."];
        return NO;
    }
    if (self.port == 0) {
        [self callbackDelegateWithErrorMessage:@"Invalid Port."];
        return NO;
    }
    if (!self.username) {
        [self callbackDelegateWithErrorMessage:@"Empty Username."];
        return NO;
    }
    if (!self.password) {
        [self callbackDelegateWithErrorMessage:@"Empty Password."];
        return NO;
    }
    if (!self.moduleName) {
        [self callbackDelegateWithErrorMessage:@"Empty Module Name."];
        return NO;
    }
    if (!self.remotePath) {
        [self callbackDelegateWithErrorMessage:@"Empty Remote Path."];
        return NO;
    }
    NSURL *remoteURL = [NSURL URLWithString:self.remotePath];
    if (!remoteURL) {
        [self callbackDelegateWithErrorMessage:@"Invalid Remote Path."];
        return NO;
    }
    if (!self.localPath) {
        [self callbackDelegateWithErrorMessage:@"Empty Local Path."];
        return NO;
    }
    NSURL *localURL = [NSURL fileURLWithPath:self.localPath];
    if (!localURL) {
        [self callbackDelegateWithErrorMessage:@"Invalid Local Path."];
        return NO;
    }
    BOOL existsLocalPath = [FCFileManager isReadableItemAtPath:self.localPath];
    if (!existsLocalPath) {
        [self callbackDelegateWithErrorMessage:@"Local Path is not readable."];
        return NO;
    }
    NSURL *cachesURL = [NSURL fileURLWithPath:self.cachesPath];
    if (!cachesURL) {
        [self callbackDelegateWithErrorMessage:@"Invalid Caches Path."];
        return NO;
    }
    BOOL existsCachesPath = [FCFileManager isReadableItemAtPath:self.cachesPath];
    if (!existsCachesPath) {
        [self callbackDelegateWithErrorMessage:@"Caches Path is not readable."];
        return NO;
    }
    return YES;
}

- (void)startRsync {
    if (![self checkProperties]) {
        return;
    }
    
    [self addObserver:self
           forKeyPath:@"totalBytes"
              options:NSKeyValueObservingOptionNew
              context:nil];
    [self addObserver:self
           forKeyPath:@"physicalBytes"
              options:NSKeyValueObservingOptionNew
              context:nil];
    [self addObserver:self
           forKeyPath:@"logicalBytes"
              options:NSKeyValueObservingOptionNew
              context:nil];
    [self addObserver:self
           forKeyPath:@"skippedBytes"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    rsync::SocketUtil::startup();
    rsync::Log::setLevel(rsync::Log::Debug);
    
    if (self.secure) {
        int rc = libssh2_init(0);
        if (rc != 0) {
            LOG_ERROR(LIBSSH2_INIT) << "libssh2 initialization failed: " << rc << LOG_END
            return;
        }
    }
    
    const char *server = [self.host UTF8String];
    const char *user = [self.username UTF8String];
    const char *password = [self.password UTF8String];
    int port = (int)self.port;
    
    std::string temporaryFile = rsync::PathUtil::join([self.cachesPath UTF8String], [[[NSUUID UUID] UUIDString] UTF8String]);
    std::string remoteDir = std::string([self.remotePath UTF8String]);
    std::string localDir = std::string([self.localPath UTF8String]);
    std::string module = std::string([self.moduleName UTF8String]);
    
    try {
        if (self.secure) {
            rsync::SSHIO sshio;
            
            sshio.connect(server, port, user, password, 0, 0);
            rsync::Client client(&sshio, "rsync", 30, &_g_cancelFlag);
            
            client.setSpeedLimits(self.downloadSpeedLimit, self.uploadSpeedLimit);
            client.setStatsAddresses(&_totalBytes, &_physicalBytes, &_logicalBytes, &_skippedBytes);
            
            if (self.requestType == CourtesyRsyncHelperRequestTypeUpload) {
                _status = CourtesyRsyncHelperStatusUploading;
                client.upload(localDir.c_str(), remoteDir.c_str());
            } else if (self.requestType == CourtesyRsyncHelperRequestTypeDownload) {
                _status = CourtesyRsyncHelperStatusDownloading;
                client.download(localDir.c_str(), remoteDir.c_str(), temporaryFile.c_str());
            }
            
            [self callbackDelegateWithSuccess];
        } else {
            rsync::SocketIO io;
            
            io.connect(server, port, user, password, module.c_str());
            rsync::Client client(&io, "rsync", 30, &_g_cancelFlag);
            
            client.setSpeedLimits(self.downloadSpeedLimit, self.uploadSpeedLimit);
            client.setStatsAddresses(&_totalBytes, &_physicalBytes, &_logicalBytes, &_skippedBytes);
            
            if (self.requestType == CourtesyRsyncHelperRequestTypeUpload) {
                _status = CourtesyRsyncHelperStatusUploading;
                client.upload(localDir.c_str(), remoteDir.c_str());
            } else if (self.requestType == CourtesyRsyncHelperRequestTypeDownload) {
                _status = CourtesyRsyncHelperStatusDownloading;
                client.download(localDir.c_str(), remoteDir.c_str(), temporaryFile.c_str());
            }
            
            [self callbackDelegateWithSuccess];
        }
    } catch (rsync::Exception &e) {
        LOG_ERROR(RSYNC_ERROR) << "Sync failed: " << e.getMessage() << LOG_END
    }
    
    [self removeObserver:self
              forKeyPath:@"totalBytes"];
    [self removeObserver:self
              forKeyPath:@"physicalBytes"];
    [self removeObserver:self
              forKeyPath:@"logicalBytes"];
    [self removeObserver:self
              forKeyPath:@"skippedBytes"];
    
    if (self.secure) {
        libssh2_exit();
    }
    
    rsync::SocketUtil::cleanup();
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    CYLog(@"%@", change);
}

- (void)pauseRsync {
    _g_cancelFlag = 1;
}

@end
