//
//  CourtesyAccountModel.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "JSONHTTPClient.h"
#import "CourtesyCommonRequestModel.h"
#import "CourtesyAccountModel.h"
#import "CourtesyAccountProfileModel.h"

@implementation CourtesyAccountModel {
    CourtesyCommonRequestModel *fetchDict;
    BOOL isFetching;
    BOOL fetched;
}

- (instancetype)init {
    if (self = [super init]) {
        _profile = [CourtesyAccountProfileModel new];
        isFetching = NO;
        fetched = NO;
    }
    return self;
}

- (instancetype)initWithDelegate:(id)delegate {
    if ([self init]) {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Setter, Getter

- (void)setEmail:(NSString *)email {
    _email = email;
    if (!_profile) {
        return;
    }
    [_profile setNick:_email];
}

#pragma mark - 获取请求状态

- (BOOL)isFetching {
    return isFetching;
}

- (BOOL)fetched {
    return fetched;
}

#pragma mark - 构造请求

- (void)makeRequest {
    fetchDict = [CourtesyCommonRequestModel new];
    fetchDict.action = @"user_info";
    CYLog(@"%@", [fetchDict toJSONString]);
}

#pragma mark - 发送委托方法

- (void)callbackDelegateWithErrorMessage:(NSString *)message {
    if (!_delegate || ![_delegate respondsToSelector:@selector(fetchAccountInfoFailed:errorMessage:)]) {
        return;
    }
    [_delegate fetchAccountInfoFailed:self errorMessage:message];
}

- (void)callbackDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(fetchAccountInfoSucceed:)]) {
        return;
    }
    [_delegate fetchAccountInfoSucceed:self];
}

#pragma mark - 发送请求

- (void)fetchAccountInfo {
    [self makeRequest];
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
                NSError *error = nil;
                if ([dict hasKey:@"account_info"]) dict = [dict objectForKey:@"account_info"];
                CourtesyAccountModel *newAccount = [[CourtesyAccountModel alloc] initWithDictionary:dict error:&error];
                if (error) {
                    @throw NSException(kCourtesyUnexceptedObject, @"数据解析失败");
                } else {
                    [[GlobalSettings sharedInstance] setCurrentAccount:newAccount];
                }
                [[GlobalSettings sharedInstance] reloadAccount];
                fetched = YES;
                [self callbackDelegateSucceed];
                return;
            }
            @throw NSException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
        }
        @catch (NSException *exception) {
            if ([exception.name isEqualToString:kCourtesyForbidden]) {
                [[GlobalSettings sharedInstance] setHasLogin:NO];
            }
            [self callbackDelegateWithErrorMessage:exception.reason];
            return;
        }
        @finally {
            isFetching = NO;
        }
    };
    isFetching = YES;
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:[fetchDict toJSONString]
                                   completion:handler];
}

@end
