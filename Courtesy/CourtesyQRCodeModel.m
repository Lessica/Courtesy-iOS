//
//  CourtesyQRCodeModel.m
//  Courtesy
//
//  Created by Zheng on 2/28/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyQRCodeModel.h"
#import "JSONHTTPClient.h"

@implementation CourtesyQRCodeQueryModel

@end

@implementation CourtesyQRCodeModel {
    CourtesyQRCodeQueryModel *queryDict;
}

- (instancetype)initWithDelegate:(id)delegate uid:(NSString *)unique_id {
    if ([self init]) {
        _delegate = delegate;
        _unique_id = unique_id;
    }
    return self;
}

#pragma mark - 发送委托方法

- (void)callbackQueryDelegateWithErrorMessage:(NSString *)message {
    if (!_delegate ||
        ![_delegate respondsToSelector:@selector(queryQRCodeFailed:errorMessage:)]) {
        CYLog(@"No delegate found!");
        return;
    }
    [_delegate queryQRCodeFailed:self errorMessage:message];
}

- (void)callbackQueryDelegateSucceed {
    if (!_delegate ||
        ![_delegate respondsToSelector:@selector(queryQRCodeSucceed:)]) {
        CYLog(@"No delegate found!");
        return;
    }
    [_delegate queryQRCodeSucceed:self];
}


#pragma mark - 构造请求

- (BOOL)makeRequest {
    queryDict = [CourtesyQRCodeQueryModel new];
    queryDict.action = @"qr_query";
    if (!_unique_id) {
        return NO;
    }
    queryDict.qr_id = _unique_id;
    CYLog(@"%@", [queryDict toJSONString]);
    return YES;
}

#pragma mark - 发送请求

- (void)sendRequestQuery {
    if (![self makeRequest]) {
        return;
    }
    JSONObjectBlock handler = ^(id json, JSONModelError *err) {
        CYLog(@"%@", json);
        @try {
            if (err) {
                @throw NSException(kCourtesyInvalidHttpResponse, [err localizedDescription]);
            }
            if (!json ||
                ![json isKindOfClass:[NSDictionary class]]) {
                @throw NSException(kCourtesyInvalidHttpResponse, @"服务器错误");
            }
            NSDictionary *dict = (NSDictionary *)json;
            if (![dict hasKey:@"error"]) {
                @throw NSException(kCourtesyUnexceptedObject, @"服务器错误");
            }
            NSInteger errorCode = [[dict objectForKey:@"error"] integerValue];
            if (errorCode == 403) {
                @throw NSException(kCourtesyForbidden, @"请重新登录");
            } else if (errorCode == 0) {
                NSDictionary *qr_info = nil;
                if (![dict hasKey:@"qr_info"] || ![[dict objectForKey:@"qr_info"] isKindOfClass:[NSDictionary class]]) {
                    @throw NSException(kCourtesyUnexceptedObject, @"数据解析失败");
                }
                NSError *error = nil;
                qr_info = [dict objectForKey:@"qr_info"];
                [self mergeFromDictionary:qr_info useKeyMapping:NO error:&error];
                if (error) {
                    @throw NSException(kCourtesyUnexceptedObject, @"数据解析失败");
                }
                [self callbackQueryDelegateSucceed];
                return;
            } else if (errorCode == 404) {
                @throw NSException(kCourtesyUnexceptedStatus, @"「礼记」二维码不存在");
            }
            @throw NSException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
        }
        @catch (NSException *exception) {
            if ([exception.name isEqualToString:kCourtesyForbidden]) {
                [sharedSettings setHasLogin:NO];
            }
            [self callbackQueryDelegateWithErrorMessage:exception.reason];
            return;
        }
        @finally {
            
        }
    };
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:[queryDict toJSONString]
                                   completion:handler];
}

@end
