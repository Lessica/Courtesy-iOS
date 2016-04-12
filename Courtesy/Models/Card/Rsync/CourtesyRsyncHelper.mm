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

#ifdef DEBUG
struct Dummy
{
    int d_i;
    int d_double;
};

class Sink : public Dummy {
private:
    mutable int d_numCalls;
public:
    Sink() : d_numCalls(0) {
        
    }
    int numCalls() const { return d_numCalls; }
    void entryOut(const char * path, bool isDir, int64_t size, int64_t time, const char * symlink) {
        ++d_numCalls;
        CYLog(@"path = %s, size = %lld, time = %lld", path, size, time);
    }
    void statusOut(const char * status) {
        ++d_numCalls;
        CYLog(@"status = %s", status);
    }
};
#endif

- (void)callbackDelegateWithErrorMessage:(NSString *)msg {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:kCourtesyRsyncErrorDomain code:CourtesyRsyncHelperInvalidProperty userInfo:userInfo];
    if (self.delegate && [self.delegate respondsToSelector:@selector(rsyncDidEnd:withError:)]) {
        [self.delegate rsyncDidEnd:self withError:error];
    }
}

- (void)callbackDelegateWithProgress {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rsyncDidStart:)]) {
        [self.delegate rsyncDidStart:self];
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
    return YES;
}

- (void)startRsync {
    if (![self checkProperties]) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(rsyncShouldStart:)]) {
        if (![self.delegate rsyncShouldStart:self]) {
            return;
        }
    }
    
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
    BOOL succeed = NO;
    
    std::string temporaryFile = rsync::PathUtil::join([self.cachesPath UTF8String], [[[NSUUID UUID] UUIDString] UTF8String]);
    std::string remoteDir = std::string([self.remotePath UTF8String]);
    std::string localDir = std::string([self.localPath UTF8String]);
    std::string module = std::string([self.moduleName UTF8String]);
    std::string errMsg;
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(callbackDelegateWithProgress) userInfo:nil repeats:YES];
    if (timer) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    }
    
    try {
        if (self.secure) {
            rsync::SSHIO sshio;
            
            sshio.connect(server, port, user, password, 0, 0);
            rsync::Client client(&sshio, "rsync", 30, &_g_cancelFlag);
            
            client.setDeletionEnabled(true);
            client.setStatsAddresses(&_totalBytes, &_physicalBytes, &_logicalBytes, &_skippedBytes);
#ifdef DEBUG
            client.setSpeedLimits(self.downloadSpeedLimit, self.uploadSpeedLimit);
            Sink sink;
            client.entryOut.connect(&sink, &Sink::entryOut);
            client.statusOut.connect(&sink, &Sink::statusOut);
#endif
            if (self.requestType == CourtesyRsyncHelperRequestTypeUpload) {
                _status = CourtesyRsyncHelperStatusUploading;
                client.upload(localDir.c_str(), remoteDir.c_str());
            } else if (self.requestType == CourtesyRsyncHelperRequestTypeDownload) {
                _status = CourtesyRsyncHelperStatusDownloading;
                client.download(localDir.c_str(), remoteDir.c_str(), temporaryFile.c_str());
            }
        } else {
            rsync::SocketIO io;
            
            io.connect(server, port, user, password, module.c_str());
            rsync::Client client(&io, "rsync", 30, &_g_cancelFlag);
            
            client.setDeletionEnabled(true);
            client.setSpeedLimits(self.downloadSpeedLimit, self.uploadSpeedLimit);
            client.setStatsAddresses(&_totalBytes, &_physicalBytes, &_logicalBytes, &_skippedBytes);
#ifdef DEBUG
            client.setSpeedLimits(self.downloadSpeedLimit, self.uploadSpeedLimit);
            Sink sink;
            client.entryOut.connect(&sink, &Sink::entryOut);
            client.statusOut.connect(&sink, &Sink::statusOut);
#endif
            if (self.requestType == CourtesyRsyncHelperRequestTypeUpload) {
                _status = CourtesyRsyncHelperStatusUploading;
                client.upload(localDir.c_str(), remoteDir.c_str());
            } else if (self.requestType == CourtesyRsyncHelperRequestTypeDownload) {
                _status = CourtesyRsyncHelperStatusDownloading;
                client.download(localDir.c_str(), remoteDir.c_str(), temporaryFile.c_str());
            }
        }
        succeed = YES;
    } catch (rsync::Exception &e) {
        errMsg = e.getMessage();
        LOG_ERROR(RSYNC_ERROR) << "Sync failed: " << e.getMessage() << LOG_END
    }
    
    if (timer) {
        [timer invalidate];
    }
    
    if (self.secure) {
        libssh2_exit();
    }
    
    rsync::SocketUtil::cleanup();
    
    if (succeed) {
        [self callbackDelegateWithSuccess];
    } else if (errMsg.c_str()) {
        [self callbackDelegateWithErrorMessage:[NSString stringWithUTF8String:errMsg.c_str()]];
    } else {
        [self callbackDelegateWithErrorMessage:@"Unknown Error"];
    }
}

- (void)pauseRsync {
    _g_cancelFlag = 1;
}

- (void)dealloc {
    CYLog(@"");
}

@end
