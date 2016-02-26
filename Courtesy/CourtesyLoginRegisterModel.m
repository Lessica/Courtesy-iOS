//
//  CourtesyLoginRegisterModel.m
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "JSONHTTPClient.h"
#import "CourtesyLoginRegisterModel.h"

#pragma mark - 登录注册请求包虚拟类

@implementation CourtesyLoginRegisterAccountRequestModel
@end

@implementation CourtesyLoginRegisterRequestModel
@end

#pragma mark - 登录注册请求类

@implementation CourtesyLoginRegisterModel {
    CourtesyLoginRegisterAccountRequestModel *accountDict;
    CourtesyLoginRegisterRequestModel *loginRegisterDict;
    NSString *originalPassword;
}

- (instancetype)initWithAccount:(NSString *)email
                       password:(NSString *)password
                       delegate:(id)delegate {
    if (self = [super init]) {
        _email = email;
        _password_enc = [password md5String];
        _delegate = delegate;
        originalPassword = password;
    }
    return self;
}

#pragma mark - 发送委托方法

- (void)callbackDelegateWithErrorMessage:(NSString *)message isLogin:(BOOL)login {
    if (!_delegate || ![_delegate respondsToSelector:@selector(loginRegisterFailed:errorMessage:isLogin:)]) {
        return;
    }
    [_delegate loginRegisterFailed:self errorMessage:message isLogin:login];
}

- (void)callbackDelegateWithSucceedAccount:(NSString *)email isLogin:(BOOL)login {
    if (!_delegate || ![_delegate respondsToSelector:@selector(loginRegisterSucceed:isLogin:)]) {
        return;
    }
    [_delegate loginRegisterSucceed:self isLogin:login];
}

#pragma mark - 检查并生成请求

- (void)makeRequest:(BOOL)login {
    if (![_email isEmail]) {
        [self callbackDelegateWithErrorMessage:@"电子邮箱格式错误" isLogin:login];
        return;
    }
    if ([originalPassword isEmpty]) {
        [self callbackDelegateWithErrorMessage:@"密码不能为空" isLogin:login];
        return;
    }
    accountDict = [CourtesyLoginRegisterAccountRequestModel new];
    accountDict.email = _email;
    accountDict.pwd = _password_enc;
    loginRegisterDict = [CourtesyLoginRegisterRequestModel new];
    if (login) {
        loginRegisterDict.action = @"user_login";
    } else {
        loginRegisterDict.action = @"user_register";
    }
    loginRegisterDict.account = accountDict;
    CYLog(@"%@", [loginRegisterDict toJSONString]);
}

#pragma mark - 发送请求

- (void)sendRequestLogin {
    [self makeRequest:YES];
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
            if (errorCode == 0) {
                [self callbackDelegateWithSucceedAccount:_email isLogin:YES];
                return;
            } else if (errorCode == 406) {
                @throw NSException(kCourtesyUnexceptedStatus, @"电子邮箱或密码错误");
            } else if (errorCode == 407) {
                @throw NSException(kCourtesyUnexceptedStatus, @"账户被禁用");
            }
            @throw NSException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", errorCode]));
        }
        @catch (NSException *exception) {
            [self callbackDelegateWithErrorMessage:exception.reason isLogin:YES];
            return;
        }
        @finally {
            
        }
    };
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:[loginRegisterDict toJSONString]
                                   completion:handler];
}

- (void)sendRequestRegister {
    [self makeRequest:NO];
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
            if (errorCode == 0) {
                [self callbackDelegateWithSucceedAccount:_email isLogin:NO];
                return;
            } else if (errorCode == 405) {
                @throw NSException(kCourtesyUnexceptedStatus, @"电子邮箱已被占用");
            }
            @throw NSException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", errorCode]));
        }
        @catch (NSException *exception) {
            [self callbackDelegateWithErrorMessage:exception.reason isLogin:NO];
            return;
        }
        @finally {
            
        }
    };
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:[loginRegisterDict toJSONString]
                                   completion:handler];
}

@end
