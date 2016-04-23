//
//  CourtesyCardQueryRequestModel.m
//  Courtesy
//
//  Created by Zheng on 4/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardQueryRequestModel.h"
#import "JSONHTTPClient.h"

@implementation CourtesyCardQueryRequestModel {
    BOOL isRequestingQuery;
}

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        isRequestingQuery = NO;
        _delegate = delegate;
    }
    return self;
}

- (NSString *)action {
    return @"card_query";
}

- (void)sendRequest {
    if (isRequestingQuery) {
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
                self.card_dict = json[@"card_info"];
                [self callbackQueryDelegateSucceed];
                return;
            }
            @throw NSCustomException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
        } @catch (NSException *exception) {
            if ([exception.name isEqualToString:kCourtesyForbidden]) {
                [sharedSettings setHasLogin:NO];
            }
            if (isRequestingQuery) {
                [self callbackQueryDelegateWithErrorMessage:exception.reason andReason:exception.name];
            }
            return;
        } @finally {
            isRequestingQuery = NO;
        }
    };
    isRequestingQuery = YES;
    NSString *body = [self toJSONString];
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:body
                                   completion:handler];
}

#pragma mark - 获取请求状态

- (BOOL)isRequestingQuery {
    return isRequestingQuery;
}

#pragma mark - Send message to CourtesyCardQueryRequestDelegate

- (void)callbackQueryDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardQueryRequestSucceed:)]) {
        return;
    }
    [_delegate cardQueryRequestSucceed:self];
}

- (void)callbackQueryDelegateWithErrorMessage:(NSString *)message andReason:(NSString *)reason {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardQueryRequestFailed:withError:)]) {
        return;
    }
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message, NSLocalizedFailureReasonErrorKey: reason};
    NSError *newError = [NSError errorWithDomain:kCourtesyCommonErrorDomain code:CourtesyCardQueryRequestStandardError userInfo:userInfo];
    [_delegate cardQueryRequestFailed:self withError:newError];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
