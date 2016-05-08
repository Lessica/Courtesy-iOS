//
//  CourtesyCardRemoveRequestModel.m
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardRemoveRequestModel.h"
#import "JSONHTTPClient.h"

@implementation CourtesyCardRemoveRequestModel

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (NSString *)action {
    if (_isHistory) {
        return @"history_delete";
    } else {
        return @"card_real_delete";
    }
}

- (void)sendRequest {
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
            } else if (errorCode == 425) {
                @throw NSCustomException(kCourtesyUnexceptedStatus, @"卡片不可用");
            } else if (errorCode == 0) {
                [self callbackRemoveDelegateSucceed];
                return;
            }
            @throw NSCustomException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
        } @catch (NSException *exception) {
            if ([exception.name isEqualToString:kCourtesyForbidden]) {
                [sharedSettings setHasLogin:NO];
            }
            [self callbackRemoveDelegateWithErrorMessage:exception.reason andReason:exception.name];
            return;
        } @finally {
            
        }
    };
    NSString *body = [self toJSONString];
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:body
                                   completion:handler];
}

#pragma mark - Send message to CourtesyCardQueryRequestDelegate

- (void)callbackRemoveDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardRemoveRequestSucceed:)]) {
        return;
    }
    [_delegate cardRemoveRequestSucceed:self];
}

- (void)callbackRemoveDelegateWithErrorMessage:(NSString *)message andReason:(NSString *)reason {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardRemoveRequestFailed:withError:)]) {
        return;
    }
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message, NSLocalizedFailureReasonErrorKey: reason};
    NSError *newError = [NSError errorWithDomain:kCourtesyCommonErrorDomain code:CourtesyCardRemoveRequestStandardError userInfo:userInfo];
    [_delegate cardRemoveRequestFailed:self withError:newError];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
