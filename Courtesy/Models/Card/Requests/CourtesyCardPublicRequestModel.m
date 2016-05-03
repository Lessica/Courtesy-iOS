//
//  CourtesyCardPublicRequestModel.m
//  Courtesy
//
//  Created by Zheng on 4/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPublicRequestModel.h"
#import "JSONHTTPClient.h"

@implementation CourtesyCardPublicRequestModel {
    BOOL isRequestingDelete;
}

- (NSString *)action {
    if (self.toBan) {
        return @"card_delete";
    } else {
        return @"card_restore";
    }
}

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        isRequestingDelete = NO;
        _delegate = delegate;
    }
    return self;
}

- (void)sendRequest {
    if (isRequestingDelete) {
        return;
    }
    JSONObjectBlock handler = ^(id json, JSONModelError *err) {
        CYLog(@"%@", [json jsonStringEncoded]);
        @try {
            if (err) {
                @throw NSCustomException(kCourtesyInvalidHttpResponse, [err localizedDescription]);
            }
            if (!json ||
                ![json isKindOfClass:[NSDictionary class]]) {
                @throw NSCustomException(kCourtesyInvalidHttpResponse, @"服务器错误");
            }
            NSDictionary *dict = (NSDictionary *)json;
            if (![dict hasKey:@"error"]) {
                @throw NSCustomException(kCourtesyUnexceptedObject, @"服务器错误");
            }
            NSInteger errorCode = [[dict objectForKey:@"error"] integerValue];
            if (errorCode == 403) {
                @throw NSCustomException(kCourtesyForbidden, @"请重新登录");
            } else if (errorCode == 0) {
                [self callbackPublicDelegateSucceed];
                return;
            }
            @throw NSCustomException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
        } @catch (NSException *exception) {
            if ([exception.name isEqualToString:kCourtesyForbidden]) {
                [sharedSettings setHasLogin:NO];
            }
            if (isRequestingDelete) {
                [self callbackPublicDelegateWithErrorMessage:exception.reason andReason:exception.name];
            }
            return;
        } @finally {
            isRequestingDelete = NO;
        }
    };
    isRequestingDelete = YES;
    NSString *body = [self toJSONString];
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:body
                                   completion:handler];
}

#pragma mark - 获取请求状态

- (BOOL)isRequestingPublic {
    return isRequestingDelete;
}

#pragma mark - Send message to CourtesyCardDeleteRequestDelegate

- (void)callbackPublicDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardPublicRequestSucceed:)]) {
        return;
    }
    [_delegate cardPublicRequestSucceed:self];
}

- (void)callbackPublicDelegateWithErrorMessage:(NSString *)message andReason:(NSString *)reason {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardPublicRequestFailed:withError:)]) {
        return;
    }
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message, NSLocalizedFailureReasonErrorKey: reason};
    NSError *newError = [NSError errorWithDomain:kCourtesyCommonErrorDomain code:CourtesyCardDeleteRequestStandardError userInfo:userInfo];
    [_delegate cardPublicRequestFailed:self withError:newError];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
