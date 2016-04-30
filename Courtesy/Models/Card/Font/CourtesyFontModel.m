//
//  CourtesyFontModel.m
//  Courtesy
//
//  Created by Zheng on 3/13/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AFNetworking.h"
#import "CourtesyFontModel.h"
#import "FCFileManager.h"

@implementation CourtesyFontModel {
    NSURLSessionTask *downloadTask;
}

- (instancetype)init {
    if (self = [super init]) {
        downloadTask = nil;
    }
    return self;
}

- (instancetype)initWithLocalURL:(NSURL *)localURL {
    if (self = [super init]) {
        NSAssert(localURL != nil, @"Init new font with invalid local url!");
        downloadTask = nil;
        _localURL = localURL;
        NSString *urlPath = [_localURL path];
        BOOL fontReadable = [FCFileManager isReadableItemAtPath:urlPath];
        if (fontReadable) {
            [self loadFontFromLocalURL];
        } else {
            if (![FCFileManager isDirectoryItemAtPath:[urlPath stringByDeletingLastPathComponent]])
                [FCFileManager createDirectoriesForFileAtPath:urlPath];
            _font = nil;
            self.status = CourtesyFontDownloadingTaskStatusNone;
        }
    }
    return self;
}

- (void)loadFontFromLocalURL {
    NSError *error = nil;
    _font = [UIFont loadFontFromData:[NSData dataWithContentsOfURL:_localURL
                                                           options:NSDataReadingMappedAlways
                                                             error:&error]];
    NSAssert(_font != nil && error == nil, @"Error occured when load font from local url!");
    if (self.status == CourtesyFontDownloadingTaskStatusNone) {
        self.status = CourtesyFontDownloadingTaskStatusDone;
    }
}

#pragma mark - Send Message to CourtesyFontDownloadDelegate

- (void)callbackDelegateSucceed {
    dispatch_async_on_main_queue(^{
        if (self.status == CourtesyFontDownloadingTaskStatusExtract) {
            self.status = CourtesyFontDownloadingTaskStatusDone;
        }
        if (!_delegate || ![_delegate respondsToSelector:@selector(fontDownloadDidSucceed:)]) {
            return;
        }
        [_delegate fontDownloadDidSucceed:self];
    });
}

- (void)callbackDelegateFailedWithError:(NSError *)error {
    dispatch_async_on_main_queue(^{
        self.status = CourtesyFontDownloadingTaskStatusNone;
        if (!_delegate || ![_delegate respondsToSelector:@selector(fontDownloadDidFailed:withErrorMessage:)]) {
            return;
        }
        [_delegate fontDownloadDidFailed:self withErrorMessage:[error localizedDescription]];
    });
}

- (void)callbackDelegateWithProcess {
    dispatch_async_on_main_queue(^{
        if (self.status != CourtesyFontDownloadingTaskStatusSuspend) {
            self.status = CourtesyFontDownloadingTaskStatusDownload;
        }
        if (!_delegate || ![_delegate respondsToSelector:@selector(fontDownloadProgressNotify:)]) {
            return;
        }
        [_delegate fontDownloadProgressNotify:self];
    });
}

- (void)setStatus:(CourtesyFontDownloadingTaskStatus)status {
    _status = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:kCourtesyFontQueueUpdated object:self];
}

#pragma mark - 下载字体

- (void)startDownloadTask {
    if (self.status == CourtesyFontDownloadingTaskStatusSuspend) {
        self.status = CourtesyFontDownloadingTaskStatusReady;
        if (downloadTask) {
            [downloadTask resume];
        }
        return;
    } else if (self.status == CourtesyFontDownloadingTaskStatusNone) {
        self.status = CourtesyFontDownloadingTaskStatusReady;
    } else {
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:self.remoteURL];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    __weak typeof(self) weakSelf = self;
    downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        __strong typeof(self) strongSelf = weakSelf;
        _downloadProgress = [downloadProgress fractionCompleted];
        [strongSelf callbackDelegateWithProcess];
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        __strong typeof(self) strongSelf = weakSelf;
        NSURL *targetURL = [strongSelf.localURL URLByAppendingPathExtension:@"zip"];
        return targetURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            CYLog(@"%@", error);
            [strongSelf callbackDelegateFailedWithError:error];
            return;
        }
        CYLog(@"Unzip: %@", filePath);
        [SSZipArchive unzipFileAtPath:[filePath path]
                        toDestination:[[strongSelf.localURL path] stringByDeletingLastPathComponent]
                            overwrite:YES
                             password:nil
                                error:&error
                             delegate:strongSelf];
        if (error) {
            CYLog(@"%@", error);
            [strongSelf callbackDelegateFailedWithError:error];
            return;
        }
    }];
    [downloadTask resume];
}

- (void)pauseDownloadTask {
    if (self.status == CourtesyFontDownloadingTaskStatusDownload) {
        if (downloadTask) {
            [downloadTask suspend];
        }
        self.status = CourtesyFontDownloadingTaskStatusSuspend;
        return;
    }
}

#pragma mark - SSZipArchiveDelegate

- (void)zipArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total {
    dispatch_async_on_main_queue(^{
        if (self.status == CourtesyFontDownloadingTaskStatusDownload) {
            self.status = CourtesyFontDownloadingTaskStatusExtract;
        }
    });
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path
                                zipInfo:(unz_global_info)zipInfo
                           unzippedPath:(NSString *)unzippedPath
{
    [self loadFontFromLocalURL];
    [self callbackDelegateSucceed];
}

#pragma mark - Memory Check

- (void)dealloc {
    CYLog(@"");
}

@end
