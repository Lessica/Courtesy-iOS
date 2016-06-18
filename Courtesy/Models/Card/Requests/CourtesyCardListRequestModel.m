//
//  CourtesyCardListRequestModel.m
//  Courtesy
//
//  Created by Zheng on 5/2/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#define kCourtesyListErrorDomain @"com.darwin.courtesy-list"

#import "CourtesyCardListRequestModel.h"
#import "CourtesyCardManager.h"
#import "JSONHTTPClient.h"

@implementation CourtesyCardListRequestModel

+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"cards"]) {
        return YES;
    }
    return NO;
}

- (NSString *)action {
    if (self.user_id == kAccount.user_id) {
        if (_history) {
            return @"my_read_history";
        } else {
            return @"my_card_list";
        }
    } else {
        return @"other_card_list";
    }
}

- (void)callbackQueryDelegateWithSuccess {
    if (_delegate && [_delegate respondsToSelector:@selector(cardListRequestSucceed:)]) {
        [_delegate cardListRequestSucceed:self];
    }
}

- (void)callbackQueryDelegateWithErrorMessage:(NSString *)errorMessage {
    if (_delegate && [_delegate respondsToSelector:@selector(cardListRequestFailed:withError:)]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:errorMessage};
        NSError *error = [NSError errorWithDomain:kCourtesyListErrorDomain code:CourtesyCardListStandardError userInfo:userInfo];
        [_delegate cardListRequestFailed:self withError:error];
    }
}

- (void)sendAsyncListRequest {
    JSONObjectBlock handler = ^(id json, JSONModelError *err) {
        CYLog(@"%@", json);
        @try {
            if (err) {
                @throw NSCustomException(kCourtesyInvalidHttpResponse, [err localizedDescription]);
            }
            if (!json ||
                ![json isKindOfClass:[NSDictionary class]]) {
                @throw NSCustomException(kCourtesyInvalidHttpResponse, @"服务器错误");
            }
            NSDictionary *dict = (NSDictionary *)json;
            if (![dict hasKey:@"error"] || ![dict hasKey:@"card_list"] || ![dict[@"card_list"] isKindOfClass:[NSArray class]]) {
                @throw NSCustomException(kCourtesyUnexceptedObject, @"服务器错误");
            }
            NSInteger errorCode = [[dict objectForKey:@"error"] integerValue];
            NSArray *cardList = dict[@"card_list"];
            if (errorCode == 403) {
                @throw NSCustomException(kCourtesyForbidden, @"请重新登录");
            } else if (errorCode == 0) {
                CourtesyCardManager *manager = [CourtesyCardManager sharedManager];
                for (id cardObj in cardList) {
                    if (![cardObj isKindOfClass:[NSDictionary class]]) {
                        @throw NSCustomException(kCourtesyUnexceptedObject, @"卡片解析失败");
                    }
                    
                    NSDictionary *cardDict = (NSDictionary *)cardObj;
                    NSMutableDictionary *cardMutDict = [[NSMutableDictionary alloc] initWithDictionary:cardDict];
                    cardDict = [cardMutDict copy];
                    
                    NSError *err = nil;
                    CourtesyCardModel *card = [[CourtesyCardModel alloc] initWithDictionary:cardDict error:&err];
                    
                    if (!card || err) {
                        @throw NSCustomException(kCourtesyUnexceptedObject, @"卡片解析失败");
                    }
                    
                    card.isNewCard = NO;
                    card.hasPublished = YES;
                    
                    if ([card isMyCard]) {
                        if ([manager hasLocalToken:card.token]) {
                            continue;
                        }
                        card.author = kAccount;
                    } else {
                        card.read_by = kAccount;
                    }
                    
                    card.delegate = manager;
                    card.willPublish = NO;
                    card.shouldNotify = NO;
                    [card saveToLocalDatabase];
                }
                [self callbackQueryDelegateWithSuccess];
                return;
            }
            @throw NSCustomException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
        } @catch (NSException *exception) {
            if ([exception.name isEqualToString:kCourtesyForbidden]) {
                [sharedSettings setHasLogin:NO];
            }
            [self callbackQueryDelegateWithErrorMessage:exception.reason];
            return;
        } @finally {
            
        }
    };
    NSString *body = [self toJSONString];
    CYLog(@"%@", body);
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:body
                                   completion:handler];
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

@end
