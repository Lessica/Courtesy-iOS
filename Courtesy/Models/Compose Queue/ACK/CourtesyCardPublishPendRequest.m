//
//  CourtesyCardPublishPendRequest.m
//  Courtesy
//
//  Created by Zheng on 4/18/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#define kCourtesyRsyncErrorDomain @"com.darwin.courtesy-rsync"

#import "JSONHTTPClient.h"
#import "CourtesyCardPublishPendRequest.h"
#import "CourtesyCardResourcesVerificationModel.h"

@implementation CourtesyCardPublishPendRequest {
    BOOL isRequestingPend;
}

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        isRequestingPend = NO;
        _delegate = delegate;
    }
    return self;
}

- (NSString *)action {
    NSString *operation = @"card";
    if (self.card_info.hasPublished) {
        operation = [operation stringByAppendingString:@"_edit"];
    } else {
        operation = [operation stringByAppendingString:@"_create"];
    }
    if (self.query) {
        operation = [operation stringByAppendingString:@"_query"];
    }
    return operation;
}

- (void)sendRequest {
    if (isRequestingPend) {
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
            } else if (errorCode == 424) {
                @throw NSCustomException(kCourtesyUnexceptedStatus, @"二维码已使用");
            } else if (errorCode == 434) {
                @throw NSCustomException(kCourtesyRepeatedOperation, @"请勿重复发布卡片");
            } else if (errorCode == 430) {
                @throw NSCustomException(kCourtesyUnexceptedStatus, @"卡片资源移动失败");
            } else if (errorCode == 0) {
                [self callbackPendDelegateSucceed];
                return;
            }
            @throw NSCustomException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
        } @catch (NSException *exception) {
            if ([exception.name isEqualToString:kCourtesyForbidden]) {
                [sharedSettings setHasLogin:NO];
            }
            if (isRequestingPend) {
                [self callbackPendDelegateWithErrorMessage:exception.reason andReason:exception.name];
            }
            return;
        } @finally {
            isRequestingPend = NO;
        }
    };
    isRequestingPend = YES;
    [self callbackPendDelegateStarted];
    CourtesyCardResourcesVerificationModel *verification = [[CourtesyCardResourcesVerificationModel alloc] initWithCard:self.card_info];
    [verification generateVerificationInfo];
    NSString *body = [self toJSONString];
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:body
                                   completion:handler];
}

- (void)stopRequest {
    isRequestingPend = NO;
}

#pragma mark - 获取请求状态

- (BOOL)isRequestingPend {
    return isRequestingPend;
}

#pragma mark - Send message to CourtesyCardPublishPendDelegate

- (void)callbackPendDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardPublishPendSucceed:)]) {
        return;
    }
    [_delegate cardPublishPendSucceed:self];
}

- (void)callbackPendDelegateWithErrorMessage:(NSString *)message andReason:(NSString *)reason {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardPublishPendFailed:withError:)]) {
        return;
    }
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message, NSLocalizedFailureReasonErrorKey: reason};
    NSError *newError = [NSError errorWithDomain:kCourtesyRsyncErrorDomain code:CourtesyCardPublishPendStandardError userInfo:userInfo];
    [_delegate cardPublishPendFailed:self withError:newError];
}

- (void)callbackPendDelegateStarted {
    if (!_delegate || ![_delegate respondsToSelector:@selector(cardPublishPendDidStart:)]) {
        return;
    }
    [_delegate cardPublishPendDidStart:self];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
