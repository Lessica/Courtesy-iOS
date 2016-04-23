//
//  CourtesyCardDeleteRequestModel.m
//  Courtesy
//
//  Created by Zheng on 4/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardDeleteRequestModel.h"
#import "JSONHTTPClient.h"

@implementation CourtesyCardDeleteRequestModel {
    BOOL isRequestingDelete;
}

- (NSString *)action {
    return @"card_delete";
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
                [self callbackDeleteDelegateSucceed];
                return;
            }
            @throw NSException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
        } @catch (NSException *exception) {
            if ([exception.name isEqualToString:kCourtesyForbidden]) {
                [sharedSettings setHasLogin:NO];
            }
            if (isRequestingDelete) {
                [self callbackDeleteDelegateWithErrorMessage:exception.reason andReason:exception.name];
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

- (BOOL)isRequestingDelete {
    return isRequestingDelete;
}

#pragma mark - Send message to CourtesyCardDeleteRequestDelegate

- (void)callbackDeleteDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardDeleteRequestSucceed:)]) {
        return;
    }
    [_delegate cardDeleteRequestSucceed:self];
}

- (void)callbackDeleteDelegateWithErrorMessage:(NSString *)message andReason:(NSString *)reason {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardDeleteRequestFailed:withError:)]) {
        return;
    }
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message, NSLocalizedFailureReasonErrorKey: reason};
    NSError *newError = [NSError errorWithDomain:kCourtesyCommonErrorDomain code:CourtesyCardDeleteRequestStandardError userInfo:userInfo];
    [_delegate cardDeleteRequestFailed:self withError:newError];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
