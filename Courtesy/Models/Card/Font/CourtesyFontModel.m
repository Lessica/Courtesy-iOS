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

- (BOOL)downloaded {
    if (_font) return YES;
    if (!_localURL) return NO;
    if (![FCFileManager isDirectoryItemAtPath:[[_localURL path] stringByDeletingLastPathComponent]])
        [FCFileManager createDirectoriesForFileAtPath:[_localURL path]];
    return [FCFileManager isReadableItemAtPath:[_localURL path]];
}

- (UIFont *)font {
    if (!_font) {
        if (!_localURL) return nil;
        if (![FCFileManager isReadableItemAtPath:[_localURL path]]) return nil;
        NSError *error = nil;
        _font = [UIFont loadFontFromData:[NSData dataWithContentsOfURL:_localURL
                                                               options:NSDataReadingMappedAlways
                                                                 error:&error]];
        if (error) {
            CYLog(@"%@", error);
            return nil;
        }
    }
    return _font;
}

#pragma mark - Send Message to CourtesyFontDownloadDelegate

- (void)callbackDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(fontDownloadDidSucceed:)]) {
        return;
    }
    [_delegate fontDownloadDidSucceed:self];
}

- (void)callbackDelegateFailedWithError:(NSError *)error {
    if (!_delegate || ![_delegate respondsToSelector:@selector(fontDownloadDidFailed:withErrorMessage:)]) {
        return;
    }
    [_delegate fontDownloadDidFailed:self withErrorMessage:[error localizedDescription]];
}

- (void)callbackDelegateWithProcess {
    if (!_delegate || ![_delegate respondsToSelector:@selector(fontDownload:withProgress:)]) {
        return;
    }
    [_delegate fontDownload:self withProgress:_downloadProgress];
}

#pragma mark - 下载字体

- (void)downloadFont {
    if (_downloading || self.downloaded) return;
    if (!_remoteURL || !_localURL) return;
    if (downloadTask) {
        [downloadTask resume];
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:self.remoteURL];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    _downloading = YES;
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
        _downloading = NO;
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

- (void)pauseDownloadFont {
    _downloading = NO;
    [downloadTask suspend];
}

#pragma mark - SSZipArchiveDelegate

- (void)zipArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total {
    
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path
                                zipInfo:(unz_global_info)zipInfo
                           unzippedPath:(NSString *)unzippedPath
{
    if (self.downloaded) {
        _downloadProgress = 1.0;
        [self callbackDelegateSucceed];
    }
}

#pragma mark - Memory Check

- (void)dealloc {
    CYLog(@"");
}

@end
