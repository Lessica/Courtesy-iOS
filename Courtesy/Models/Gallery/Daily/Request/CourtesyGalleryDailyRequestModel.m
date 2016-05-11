//
//  CourtesyGalleryDailyRequestModel.m
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyGalleryDailyRequestModel.h"
#import "JSONHTTPClient.h"

@implementation CourtesyGalleryDailyRequestModel

+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    if (
        [propertyName isEqualToString:@"cards"] ||
        [propertyName isEqualToString:@"delegate"]
        ) {
        return YES;
    }
    return NO;
}

- (NSString *)action {
    return @"news_query";
}

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
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
            if (![dict hasKey:@"error"]
                ) {
                @throw NSCustomException(kCourtesyUnexceptedObject, @"服务器错误");
            }
            NSInteger errorCode = [[dict objectForKey:@"error"] integerValue];
            if (errorCode == 0) {
                if (![dict hasKey:@"news"] ||
                    ![[dict objectForKey:@"news"] isKindOfClass:[NSArray class]]) {
                    @throw NSCustomException(kCourtesyUnexceptedObject, @"服务器错误");
                }
                NSArray<NSDictionary *> *news = (NSArray *)[dict objectForKey:@"news"];
                NSMutableArray<CourtesyGalleryDailyCardModel *> *dailyCards = [NSMutableArray new];
                for (NSDictionary *new in news) {
                    NSError *error = nil;
                    CourtesyGalleryDailyCardModel *newDailyCard = [[CourtesyGalleryDailyCardModel alloc] initWithDictionary:new error:&error];
                    if (!newDailyCard || error) {
                        CYLog(@"%@", error);
                        @throw NSCustomException(kCourtesyUnexceptedObject, @"服务器错误");
                    }
                    [dailyCards addObject:newDailyCard];
                }
                if ([dailyCards count] <= 0) {
                    @throw NSCustomException(kCourtesyUnexceptedObject, @"无可用卡片数据");
                }
                self.cards = [dailyCards copy];
                [self callbackGalleryDailyDelegateSucceed];
                return;
            }
            @throw NSCustomException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
        } @catch (NSException *exception) {
            [self callbackGalleryDailyDelegateWithErrorMessage:exception.reason andReason:exception.name];
            return;
        } @finally {
            
        }
    };
    NSString *body = [self toJSONString];
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:body
                                   completion:handler];
}

#pragma mark - Send message to CourtesyGalleryDailyRequestDelegate

- (void)callbackGalleryDailyDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(galleryDailyRequestSucceed:)]) {
        return;
    }
    [_delegate galleryDailyRequestSucceed:self];
}

- (void)callbackGalleryDailyDelegateWithErrorMessage:(NSString *)message andReason:(NSString *)reason {
    if (!_delegate || ![_delegate respondsToSelector:@selector(galleryDailyRequestFailed:withError:)]) {
        return;
    }
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message, NSLocalizedFailureReasonErrorKey: reason};
    NSError *newError = [NSError errorWithDomain:kCourtesyCommonErrorDomain code:CourtesyGalleryDailyRequestStandardError userInfo:userInfo];
    [_delegate galleryDailyRequestFailed:self withError:newError];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
