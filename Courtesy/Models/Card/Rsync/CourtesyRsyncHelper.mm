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

#import "rsync_client.h"
#import "rsync_entry.h"
#import "rsync_file.h"
#import "rsync_log.h"
#import "rsync_pathutil.h"
#import "rsync_socketutil.h"
#import "rsync_sshio.h"
#import "rsync_socketio.h"
#import <libssh2.h>
#import <string>

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

@implementation CourtesyRsyncHelper

- (void)callbackDelegateWithErrorMessage:(NSString *)msg {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : msg};
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

- (void)startRsync {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rsyncShouldStart:)]) {
        if (![self.delegate rsyncShouldStart:self]) {
            return;
        }
    }
    
    rsync::SocketUtil::startup();

#ifdef DEBUG
    rsync::Log::setLevel(rsync::Log::Debug);
#else
    rsync::Log::setLevel(rsync::Log::Fatal);
#endif

    if (self.secure) {
        int rc = libssh2_init(0);
        if (rc != 0) {
            LOG_ERROR(LIBSSH2_INIT) << "libssh2 initialization failed: " << rc << LOG_END
            [self callbackDelegateWithErrorMessage:@"安全连接建立失败"];
            return;
        }
    }

    NSString *errorMessage = @"未知错误";
    const char *server = [self.host UTF8String];
    const char *user = [self.username UTF8String];
    const char *password = [self.password UTF8String];
    int port = (int)self.port;
    BOOL succeed = NO;
    
    std::string temporaryFile = rsync::PathUtil::join([self.cachesPath UTF8String], [[[NSUUID UUID] UUIDString] UTF8String]);
    std::string remoteDir = std::string([self.remotePath UTF8String]);
    std::string localDir = std::string([self.localPath UTF8String]);
    std::string module = std::string([self.moduleName UTF8String]);
    
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
            rsync::Client client(&sshio, "rsync", API_RSYNC_PROTOCOL, &_g_cancelFlag);
            
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
            rsync::Client client(&io, "rsync", API_RSYNC_PROTOCOL, &_g_cancelFlag);

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
        std::string errMsg = e.getMessage();
        std::string errID = e.getID();
        NSString *errIDObj = [NSString stringWithUTF8String:errID.c_str()];
        if ([errIDObj isEqualToString:@"RSYNC_CANCEL"]) {
            errorMessage = @"用户取消上传";
        } else if ([errIDObj isEqualToString:@"SOCKET_CONNECT"]) {
            errorMessage = @"连接超时";
        } else if ([errIDObj isEqualToString:@"RSYNC_SOCKET"]) {
            errorMessage = @"连接失败";
        }
        LOG_ERROR(RSYNC_ERROR) << "Sync failed: (" << errID << ") : "
                    << errMsg << LOG_END
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
    } else if (errorMessage) {
        [self callbackDelegateWithErrorMessage:errorMessage];
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
