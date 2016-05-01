//
//  CourtesyCardCacheRequestHelper.m
//  Courtesy
//
//  Created by Zheng on 5/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#define kCourtesyCacheErrorDomain @"com.darwin.courtesy-cache"
#define kCourtesyCacheVerification 1

#import "JSONHTTPClient.h"
#import "AFNetworking.h"
#import "FCFileManager.h"
#import "CourtesyCardCacheRequestHelper.h"
#import "CourtesyCardResourceModel.h"

@interface CourtesyCardCacheRequestHelper ()
@property (nonatomic, strong) NSURL *resourceUrl;
@property (nonatomic, strong) NSURL *localUrl;
@property (nonatomic, strong) NSMutableArray <CourtesyCardResourceModel *> *resourcesArray;
@property (nonatomic, assign) BOOL cancelFlag;
#ifdef kCourtesyCacheVerification
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
#else
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
#endif
@property (nonatomic, assign) NSUInteger currentSize;

@end

@implementation CourtesyCardCacheRequestHelper

- (void)sendAsyncQueryRequest {
    if (!_card || !_card.token) {
        return;
    }
    NSURL *queryUrl = [[NSURL URLWithString:API_STATIC_RESOURCES] URLByAppendingPathComponent:_card.token];
    _resourceUrl = queryUrl;
    _localUrl = [NSURL fileURLWithPath:[CourtesyCardAttachmentModel savedAttachmentsPathWithCardToken:_card.token]];
    NSURL *jsonUrl = [queryUrl URLByAppendingPathComponent:@"Contents.json"];
    _resourcesArray = [[NSMutableArray alloc] init];
    __weak NSMutableArray *weakResArr = _resourcesArray;
    JSONObjectBlock handler = ^(id json, JSONModelError *err) {
        __strong NSMutableArray *strongResArr = weakResArr;
        CYLog(@"%@", json);
        @try {
            if (err) {
                @throw NSCustomException(kCourtesyInvalidHttpResponse, [err localizedDescription]);
            }
            if (!json ||
                ![json isKindOfClass:[NSDictionary class]]) {
                @throw NSCustomException(kCourtesyInvalidHttpResponse, @"服务器错误");
            }
            NSDictionary *dict = (NSDictionary *)json;
            if (![dict hasKey:@"card_token"] || ![dict[@"card_token"] isKindOfClass:[NSString class]] || ![dict[@"statics"] isKindOfClass:[NSArray class]]) {
                @throw NSCustomException(kCourtesyUnexceptedObject, @"服务器错误");
            }
            NSString *requested_token = dict[@"card_token"];
            if (![requested_token isEqualToString:_card.token]) {
                @throw NSCustomException(kCourtesyUnexceptedObject, @"卡片资源数据异常");
            }
            NSArray *statics = dict[@"statics"];
            NSUInteger totalSize = 0;
            for (NSDictionary *sub_dict in statics) {
                NSError *err = nil;
                CourtesyCardResourceModel *sub_res = [[CourtesyCardResourceModel alloc] initWithDictionary:sub_dict error:&err];
                if (err) {
                    @throw NSCustomException(kCourtesyUnexceptedObject, @"卡片资源数据异常");
                }
                totalSize += sub_res.size;
                [strongResArr addObject:sub_res];
            }
            _totalBytes = totalSize;
            _logicalBytes = 0;
            if (_delegate && [_delegate respondsToSelector:@selector(cardCacheQuerySucceed:)]) {
                [_delegate cardCacheQuerySucceed:self];
            }
        } @catch (NSException *exception) {
            if (_delegate && [_delegate respondsToSelector:@selector(cardCacheQueryFailed:withError:)]) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:exception.reason, NSLocalizedFailureReasonErrorKey:exception.name};
                NSError *error = [NSError errorWithDomain:kCourtesyCacheErrorDomain code:CourtesyCardCacheStandardError userInfo:userInfo];
                [_delegate cardCacheQueryFailed:self withError:error];
            }
        } @finally {
            
        }
    };
    [JSONHTTPClient getJSONFromURLWithString:[jsonUrl absoluteString]
                                      params:nil
                                  completion:handler];
}

- (BOOL)checkAttachmentExistence:(NSString *)salt {
    for (CourtesyCardResourceModel *resource in _resourcesArray) {
        if ([resource.sha256 isEqualToString:salt]) {
            return YES;
        }
    }
    return NO;
}

- (void)callbackDelegateWithSuccess {
    if (_delegate && [_delegate respondsToSelector:@selector(cardCachedSucceed:)]) {
        [_delegate cardCachedSucceed:self];
    }
}

- (void)callbackDelegateWithErrorMessage:(NSString *)errorMessage {
    if (_delegate && [_delegate respondsToSelector:@selector(cardCachedFailed:withError:)]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errorMessage};
        NSError *error = [NSError errorWithDomain:kCourtesyCacheErrorDomain code:CourtesyCardCacheStandardError userInfo:userInfo];
        [_delegate cardCachedFailed:self withError:error];
    }
}

- (void)callbackDelegateWithProgress:(float)progress {
    if (_totalBytes < 1) return;
    if (_delegate && [_delegate respondsToSelector:@selector(cardCaching:withProgress:)]) {
        float nowProgress = (_logicalBytes + _currentSize * progress) / (float)_totalBytes;
        [_delegate cardCaching:self withProgress:nowProgress];
    }
}

- (void)sendAsyncCacheRequest {
    // 检查资源数据是否存在
    for (CourtesyCardAttachmentModel *attachment in _card.local_template.attachments) {
        if (![self checkAttachmentExistence:attachment.salt_hash]) {
            [self callbackDelegateWithErrorMessage:@"卡片资源预校验失败"];
            return;
        }
    }
    [self downloadNextResource];
}

- (void)downloadNextResource {
    // 检查取消标记
    if (_cancelFlag) {
        [self callbackDelegateWithErrorMessage:@"用户取消缓存操作"];
        return;
    }
    
    // 按顺序取出资源地址
    __block CourtesyCardResourceModel *thisRes = [_resourcesArray lastObject];
    if (!thisRes) { // 所有资源下载完成
        [self callbackDelegateWithSuccess];
        return;
    }
    _currentSize = thisRes.size;
    
    __block NSURL *thisUrl = [_resourceUrl URLByAppendingPathComponent:thisRes.filename];
    __block NSURL *thatUrl = [_localUrl URLByAppendingPathComponent:thisRes.filename];
    if (!thisUrl || !thatUrl) {
        [self callbackDelegateWithErrorMessage:@"资源地址错误"];
        return;
    }
    
    if ([FCFileManager existsItemAtPath:[thatUrl path]])
    { // 资源写入具有原子性，如果存在则跳过
        CYLog(@"Skip caching: %@", thatUrl);
        _logicalBytes += thisRes.size;
        [_resourcesArray removeObject:thisRes];
        [self downloadNextResource];
        return;
    }
    CYLog(@"Start caching: %@ -> %@", thisUrl, thatUrl);
    
    // 开始下载
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:thisUrl];
    
    __weak typeof(self) weakSelf = self;
#ifdef kCourtesyCacheVerification
    // 校验文件类型及哈希值
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObjects:@"image/jpeg", @"image/png", @"video/quicktime", @"audio/x-caf", @"application/octet-stream", nil];
    manager.responseSerializer = serializer;
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request
                                                   uploadProgress:nil
                                                 downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                                                     [weakSelf callbackDelegateWithProgress:downloadProgress.fractionCompleted];
                                                 }
                                                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                    __strong typeof(self) strongSelf = weakSelf;
                                                    if (error) {
                                                        [strongSelf callbackDelegateWithErrorMessage:[error localizedDescription]];
                                                        return;
                                                    }
                                                    if (![responseObject isKindOfClass:[NSData class]]) {
                                                        [strongSelf callbackDelegateWithErrorMessage:@"资源类型校验失败"];
                                                        return;
                                                    }
                                                    NSData *responseData = (NSData *)responseObject;
                                                    if ([responseData length] != thisRes.size) {
//                                                        [strongSelf callbackDelegateWithErrorMessage:@"资源长度校验失败"];
//                                                        return;
                                                    }
                                                    NSString *newHash = [responseData sha256String];
                                                    if (![newHash isEqualToString:thisRes.sha256]) {
                                                        [strongSelf callbackDelegateWithErrorMessage:@"资源完整性校验失败"];
                                                        return;
                                                    }
                                                    BOOL result = [responseData writeToFile:[thatUrl path] atomically:YES];
                                                    if (!result) {
                                                        [strongSelf callbackDelegateWithErrorMessage:@"资源写入失败"];
                                                        return;
                                                    }
                                                    CYLog(@"End caching: %@ -> %@", thisUrl, thatUrl);
                                                    strongSelf.logicalBytes += thisRes.size;
                                                    [strongSelf.resourcesArray removeObject:thisRes];
                                                    [strongSelf downloadNextResource];
                                                }];
    _dataTask = dataTask;
    [dataTask resume];
#else
    // 不做校验
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                         [weakSelf callbackDelegateWithProgress:downloadProgress.fractionCompleted];
                                                                     } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                         return thatUrl;
                                                                     } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                                         __strong typeof(self) strongSelf = weakSelf;
                                                                         if (error) {
                                                                             [strongSelf callbackDelegateWithErrorMessage:[error localizedDescription]];
                                                                             return;
                                                                         }
                                                                         CYLog(@"End caching: %@ -> %@", thisUrl, thatUrl);
                                                                         strongSelf.logicalBytes += thisRes.size;
                                                                         [strongSelf.resourcesArray removeObject:thisRes];
                                                                         [strongSelf downloadNextResource];
                                                                     }];
    _downloadTask = downloadTask;
    [downloadTask resume];
#endif
}

- (void)stop {
    _cancelFlag = YES;
#ifdef kCourtesyCacheVerification
    [_dataTask suspend];
#else
    [_downloadTask suspend];
#endif
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
