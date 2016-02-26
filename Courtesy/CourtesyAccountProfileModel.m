//
//  CourtesyAccountProfileModel.m
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "JSONHTTPClient.h"
#import "CourtesyAccountProfileModel.h"

@implementation CourtesyEditProfileRequestModel

@end

@implementation CourtesyAccountProfileModel {
    CourtesyEditProfileRequestModel *fetchDict;
    BOOL isEditing;
}

- (instancetype)init {
    if (self = [super init]) {
        isEditing = NO;
    }
    return self;
}

- (instancetype)initWithDelegate:(id)delegate {
    if ([self init]) {
        _delegate = delegate;
    }
    return self;
}

- (BOOL)isEditing {
    return isEditing;
}

#pragma mark - 构造请求

- (void)makeRequest {
    fetchDict = [CourtesyEditProfileRequestModel new];
    fetchDict.action = @"user_edit_profile";
    fetchDict.profile = kProfile;
    CYLog(@"%@", [fetchDict toJSONString]);
}

#pragma mark - 发送委托方法

- (void)callbackDelegateWithErrorMessage:(NSString *)message {
    if (!_delegate || ![_delegate respondsToSelector:@selector(editProfileFailed:errorMessage:)]) {
        return;
    }
    [_delegate editProfileFailed:self errorMessage:message];
}

- (void)callbackDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(editProfileSucceed:)]) {
        return;
    }
    [_delegate editProfileSucceed:self];
}

#pragma mark - 发送请求

- (void)editProfile {
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
                [self callbackDelegateSucceed];
                return;
            }
            @throw NSException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", errorCode]));
        }
        @catch (NSException *exception) {
            if ([exception.name isEqualToString:kCourtesyForbidden]) {
                [[GlobalSettings sharedInstance] setHasLogin:NO];
            }
            [self callbackDelegateWithErrorMessage:exception.reason];
            return;
        }
        @finally {
            isEditing = NO;
        }
    };
    isEditing = YES;
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:[fetchDict toJSONString]
                                   completion:handler];
}

@end
