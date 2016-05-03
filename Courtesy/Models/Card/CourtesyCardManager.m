//
//  CourtesyCardManager.m
//  Courtesy
//
//  Created by Zheng on 3/15/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "AppStorage.h"
#import "FCFileManager.h"
#import "CourtesyCardManager.h"
#import "CourtesyCardComposeViewController.h"
#import "CourtesyPortraitViewController.h"
#import "CourtesyLoginRegisterViewController.h"
#import "CourtesyCardPublishQueue.h"
#import "CourtesyCardPublicRequestModel.h"
#import "CourtesyCardCacheRequestHelper.h"

#define kCourtesyCardDraftListKey @"kCourtesyCardListKey"
#define kCourtesyCardHistoryListKey @"kCourtesyCardHistoryKey"

@interface CourtesyCardManager () <CourtesyCardComposeDelegate, CourtesyCardPublicRequestDelegate, CourtesyCardCacheRequestHelperDelegate, LGAlertViewDelegate>
@property (nonatomic, strong) LGAlertView *currentAlert;

@end

@implementation CourtesyCardManager

#pragma mark - 存储

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
}

#pragma mark - 初始化

+ (id)sharedManager {
    static CourtesyCardManager *sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)clearCards {
    _cardDraftTokenArray = nil;
    _cardDraftArray = nil;
}

- (void)clearHistory {
    _cardHistoryTokenArray = nil;
    _cardHistoryArray = nil;
}

- (NSMutableArray <NSString *> *)cardHistoryTokenArray {
    if (!_cardHistoryTokenArray) {
        id history_obj = [self.appStorage objectForKey:kCourtesyCardHistoryListKey];
        if (history_obj && [history_obj isKindOfClass:[NSMutableArray class]]) {
            _cardHistoryTokenArray = history_obj;
        } else {
            _cardHistoryTokenArray = [[NSMutableArray alloc] init];
        }
    }
    return _cardHistoryTokenArray;
}

- (NSMutableArray <NSString *> *)cardDraftTokenArray {
    if (!_cardDraftTokenArray) {
        id list_obj = [self.appStorage objectForKey:kCourtesyCardDraftListKey];
        if (list_obj && [list_obj isKindOfClass:[NSMutableArray class]]) {
            _cardDraftTokenArray = list_obj;
        } else {
            _cardDraftTokenArray = [[NSMutableArray alloc] init];
        }
    }
    return _cardDraftTokenArray;
}

- (NSMutableArray <CourtesyCardModel *> *)cardHistoryArray {
    if (!_cardHistoryArray) {
        BOOL shouldSync = NO;
        _cardHistoryArray = [[NSMutableArray alloc] init];
        NSMutableArray *historyTokensShouldBeRemoved = [NSMutableArray new];
        for (NSString *token in self.cardHistoryTokenArray) {
            CourtesyCardModel *card = [[CourtesyCardModel alloc] initWithCardToken:token];
            if (!card) {
                shouldSync = YES;
                [historyTokensShouldBeRemoved addObject:token];
                continue;
            }
            if ([card isReadByMe]) {
                // 当前用户接收到的卡片
                card.read_by = kAccount;
                card.delegate = self;
                [_cardHistoryArray addObject:card];
            }
        }
        if (shouldSync) {
            for (NSString *invalid_token in historyTokensShouldBeRemoved) {
                [self.cardHistoryTokenArray removeObject:invalid_token];
            }
            [self.appStorage setObject:self.cardHistoryTokenArray forKey:kCourtesyCardHistoryListKey];
        }
    }
    return _cardHistoryArray;
}

- (NSMutableArray <CourtesyCardModel *> *)cardDraftArray {
    if (!_cardDraftArray) {
        BOOL shouldSync = NO;
        _cardDraftArray = [[NSMutableArray alloc] init];
        NSMutableArray *tokensShouldBeRemoved = [NSMutableArray new];
        for (NSString *token in self.cardDraftTokenArray) {
            CourtesyCardModel *card = [[CourtesyCardModel alloc] initWithCardToken:token];
            if (!card) {
                shouldSync = YES;
                [tokensShouldBeRemoved addObject:token];
                continue;
            }
            if ([card isMyCard])
            {
                // 如果是当前用户编写的卡片
                card.author = kAccount;
                card.delegate = self;
                [_cardDraftArray addObject:card];
            }
            else
            {
                shouldSync = YES;
                [tokensShouldBeRemoved addObject:token];
            }
        }
        if (shouldSync) {
            for (NSString *invalid_token in tokensShouldBeRemoved) {
                [self.cardDraftTokenArray removeObject:invalid_token];
            }
            [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
        }
    }
    return _cardDraftArray;
}

#pragma mark - 生成新卡片

- (CourtesyCardModel *)newCard {
    // 初始化卡片
    CourtesyCardModel *card = [CourtesyCardModel new];
    card.delegate = self;
    card.is_editable = YES;
    card.is_banned = ![sharedSettings switchAutoPublic];
    card.view_count = 0;
    card.created_at = [[NSDate date] timeIntervalSince1970];
    card.modified_at = [[NSDate date] timeIntervalSince1970];
    card.first_read_at = 0;
    card.token = [[NSUUID UUID] UUIDString];
    card.edited_count = 0;
    card.stars = 0;
    card.author = kAccount;
    card.read_by = nil;
    
    card.local_template = [CourtesyCardDataModel new];
    // 初始化卡片内容
    card.local_template.content = @"说点什么吧……";
    card.local_template.attachments = nil;
    card.local_template.styleID = kCourtesyCardStyleDefault;
    card.local_template.fontType = [sharedSettings preferredFontType];
    card.local_template.fontSize = [sharedSettings preferredFontSize];
    card.local_template.shouldAutoPlayAudio = NO;
    card.local_template.alignmentType = NSTextAlignmentLeft;
    card.local_template.card_token = card.token;
    
    card.isNewCard = YES;
    card.hasPublished = NO;
    return card;
}

#pragma mark - 本地卡片查询

- (BOOL)hasLocalToken:(NSString *)token {
    for (NSString *arr_token in self.cardDraftTokenArray) {
        if ([arr_token isEqualToString:token]) {
            return YES;
        }
    }
    for (NSString *arr_token in self.cardHistoryTokenArray) {
        if ([arr_token isEqualToString:token]) {
            return YES;
        }
    }
    return NO;
}

- (CourtesyCardModel *)cardWithToken:(NSString *)token {
    if (![self hasLocalToken:token]) {
        return nil;
    }
    for (CourtesyCardModel *arr_card in self.cardDraftArray) {
        if ([arr_card.token isEqualToString:token]) {
            return arr_card;
        }
    }
    for (CourtesyCardModel *arr_card in self.cardHistoryArray) {
        if ([arr_card.token isEqualToString:token]) {
            return arr_card;
        }
    }
    return nil;
}

#pragma mark - 卡片编辑与查看控制

- (CourtesyCardModel *)composeNewCardWithViewController:(UIViewController *)controller {
    if (![sharedSettings hasLogin]) { // 未登录
        CourtesyLoginRegisterViewController *vc = [CourtesyLoginRegisterViewController new];
        CourtesyPortraitViewController *navc = [[CourtesyPortraitViewController alloc] initWithRootViewController:vc];
        [controller presentViewController:navc animated:YES completion:nil];
        return nil;
    }
    CourtesyCardModel *newCard = [self newCard];
    CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCard:newCard];
    vc.delegate = self;
    [controller presentViewController:vc animated:YES completion:nil];
    return newCard;
}

- (void)editCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller {
    if ([card isCardCached]) {
        // 卡片已下载
        CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCard:card];
        vc.delegate = self;
        [controller presentViewController:vc animated:YES completion:nil];
    } else {
        dispatch_async_on_main_queue(^{
            LGAlertView *alertView = [[LGAlertView alloc] initWithActivityIndicatorAndTitle:@"请求中"
                                                                                    message:@"正在请求下载卡片资源"
                                                                                      style:LGAlertViewStyleActionSheet
                                                                               buttonTitles:nil
                                                                          cancelButtonTitle:nil
                                                                     destructiveButtonTitle:nil
                                                                              actionHandler:nil
                                                                              cancelHandler:nil
                                                                         destructiveHandler:nil];
            SetCourtesyAleryViewStyle(alertView, controller.navigationController.view)
            [alertView showAnimated:YES completionHandler:nil];
            self.currentAlert = alertView;
        });
        // 卡片未下载或未全部下载
        // 发起下载异步检查请求
        CourtesyCardCacheRequestHelper *helper = [CourtesyCardCacheRequestHelper new];
        helper.delegate = self;
        helper.card = card;
        helper.relatedViewController = controller;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [helper sendAsyncQueryRequest];
        });
    }
}

#pragma mark - 3D Touch

- (UIViewController *)prepareCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller {
    if ([card isCardCached]) {
        // 卡片已下载，可以载入预览
        CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCard:card];
        vc.previewContext = YES;
        vc.delegate = self;
        return vc;
    }
    // 卡片未下载，无法预览
    return nil;
}

- (void)commitCardComposeViewController:(UIViewController *)viewController withViewController:(UIViewController *)controller {
    CourtesyCardComposeViewController *vc = (CourtesyCardComposeViewController *)viewController;
    vc.previewContext = NO;
    [controller presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 管理卡片

- (void)restoreCardInDraft:(CourtesyCardModel *)card {
    if ([card isMyCard]) {
        if (card.hasPublished) {
            if (card.is_banned) {
                dispatch_async_on_main_queue(^{
                    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"正在公开卡片 %@……", card.local_template.mainTitle]
                                               dismissAfter:kStatusBarNotificationTime
                                                  styleName:JDStatusBarStyleDefault];
                    [JDStatusBarNotification showActivityIndicator:YES
                                                    indicatorStyle:UIActivityIndicatorViewStyleGray];
                });
                
                __block CourtesyCardPublicRequestModel *restoreRequest = [[CourtesyCardPublicRequestModel alloc] initWithDelegate:self];
                restoreRequest.token = card.token;
                restoreRequest.card = card;
                restoreRequest.toBan = NO;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [restoreRequest sendRequest];
                });
            }
        }
    }
}

- (void)publicCardInDraft:(CourtesyCardModel *)card {
    if ([card isMyCard]) {
        if (card.hasPublished) {
            if (card.is_banned == NO) {
                dispatch_async_on_main_queue(^{
                    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"正在隐藏卡片 %@……", card.local_template.mainTitle]
                                               dismissAfter:kStatusBarNotificationTime
                                                  styleName:JDStatusBarStyleDefault];
                    [JDStatusBarNotification showActivityIndicator:YES
                                                    indicatorStyle:UIActivityIndicatorViewStyleGray];
                });
                
                __block CourtesyCardPublicRequestModel *publicRequest = [[CourtesyCardPublicRequestModel alloc] initWithDelegate:self];
                publicRequest.token = card.token;
                publicRequest.card = card;
                publicRequest.toBan = YES;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [publicRequest sendRequest];
                });
            }
        }
    }
}

- (void)deleteCardInDraft:(CourtesyCardModel *)card {
    if ([card isMyCard]) {
        if (card.hasPublished) {
            if (card.is_banned == NO) {
                return;
            }
        }
        [self.cardDraftTokenArray removeObject:card.token];
        [self.cardDraftArray removeObject:card];
        [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
    }
}

- (void)deleteCardInHistory:(CourtesyCardModel *)card {
    if ([card isReadByMe]) {
        [self.cardHistoryTokenArray removeObject:card.token];
        [self.cardHistoryArray removeObject:card];
        [self.appStorage setObject:self.cardHistoryTokenArray forKey:kCourtesyCardHistoryListKey];
        [card deleteInLocalDatabase];
    }
}

- (void)exchangeCardAtIndex:(NSInteger)sourceRow withCardAtIndex:(NSInteger)destinationRow {
    [self.cardDraftArray exchangeObjectAtIndex:sourceRow withObjectAtIndex:destinationRow];
    [self.cardDraftTokenArray exchangeObjectAtIndex:sourceRow withObjectAtIndex:destinationRow];
    [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
}

- (void)exchangeHistoryCardAtIndex:(NSInteger)sourceRow withCardAtIndex:(NSInteger)destinationRow {
    [self.cardHistoryArray exchangeObjectAtIndex:sourceRow withObjectAtIndex:destinationRow];
    [self.cardHistoryTokenArray exchangeObjectAtIndex:sourceRow withObjectAtIndex:destinationRow];
    [self.appStorage setObject:self.cardHistoryTokenArray forKey:kCourtesyCardHistoryListKey];
}

#pragma mark - CourtesyCardComposeDelegate

- (void)backToAlbumViewController {
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] albumViewController]];
}

- (void)cardComposeViewDidFinishEditing:(nonnull CourtesyCardComposeViewController *)controller {
    if (controller.card) {
        controller.card.willPublish = YES;
        controller.card.shouldNotify = YES;
        [controller.card saveToLocalDatabase];
    }
    [self backToAlbumViewController];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)cardComposeViewWillBeginLoading:(nonnull CourtesyCardComposeViewController *)controller {

}

- (void)cardComposeViewDidFinishLoading:(nonnull CourtesyCardComposeViewController *)controller {

}

- (void)cardComposeViewDidCancelEditing:(CourtesyCardComposeViewController *)controller shouldSaveToDraftBox:(BOOL)save {
    if (save && controller.card) {
        dispatch_async_on_main_queue(^{
            [JDStatusBarNotification showWithStatus:@"正在保存卡片……"
                                          styleName:JDStatusBarStyleDefault];
            [JDStatusBarNotification showActivityIndicator:YES
                                            indicatorStyle:UIActivityIndicatorViewStyleGray];
        });
        controller.card.willPublish = NO;
        controller.card.shouldNotify = YES;
        [controller.card saveToLocalDatabase];
    }
    [self backToAlbumViewController];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CourtesyCardDelegate

- (void)cardDidFinishSaving:(nonnull CourtesyCardModel *)card {
    if ([card isMyCard]) {
        if (![self hasLocalToken:card.token]) {
            [self.cardDraftTokenArray insertObject:card.token atIndex:0];
            [self.cardDraftArray insertObject:card atIndex:0];
        }
        [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
    } else if ([card isReadByMe]) {
        if (![self hasLocalToken:card.token]) {
            [self.cardHistoryTokenArray insertObject:card.token atIndex:0];
            [self.cardHistoryArray insertObject:card atIndex:0];
        }
        [self.appStorage setObject:self.cardHistoryTokenArray forKey:kCourtesyCardHistoryListKey];
    } else {
        return;
    }
    
    if (card.willPublish == NO) {
        if (card.shouldNotify) {
            dispatch_async_on_main_queue(^{
                [JDStatusBarNotification showWithStatus:@"卡片已保存"
                                           dismissAfter:kStatusBarNotificationTime
                                              styleName:JDStatusBarStyleSuccess];
            });
        }
        card.shouldNotify = NO;
    } else {
        [[CourtesyCardPublishQueue sharedQueue] addCardPublishTask:card];
        card.willPublish = NO;
    }
}

- (void)cardDidFailedSaving:(nonnull CourtesyCardModel *)card withError:(NSError *)error {
    dispatch_async_on_main_queue(^{
        [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"卡片保存失败 - %@", [error localizedDescription]]
                                   dismissAfter:kStatusBarNotificationTime
                                      styleName:JDStatusBarStyleError];
    });
}

#pragma mark - CourtesyCardPublicRequestDelegate

- (void)cardPublicRequestSucceed:(CourtesyCardPublicRequestModel *)sender {
    if (sender.toBan) {
        CourtesyCardModel *card = sender.card;
        dispatch_async_on_main_queue(^{
            [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"卡片 %@ 已经隐藏", card.local_template.mainTitle]
                                       dismissAfter:kStatusBarNotificationTime
                                          styleName:JDStatusBarStyleSuccess];
        });
        card.is_banned = YES;
        card.willPublish = NO;
        card.shouldNotify = NO;
        [card saveToLocalDatabase];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCourtesyCardStatusUpdated object:card];
    } else {
        CourtesyCardModel *card = sender.card;
        dispatch_async_on_main_queue(^{
            [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"卡片 %@ 已经公开", card.local_template.mainTitle]
                                       dismissAfter:kStatusBarNotificationTime
                                          styleName:JDStatusBarStyleSuccess];
        });
        card.is_banned = NO;
        card.willPublish = NO;
        card.shouldNotify = NO;
        [card saveToLocalDatabase];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCourtesyCardStatusUpdated object:card];
    }
}

- (void)cardPublicRequestFailed:(CourtesyCardPublicRequestModel *)sender
                      withError:(NSError *)error {
    if (sender.toBan) {
        CourtesyCardModel *card = sender.card;
        dispatch_async_on_main_queue(^{
            [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"卡片 %@ 隐藏失败 - %@", card.local_template.mainTitle, [error localizedDescription]]
                                       dismissAfter:kStatusBarNotificationTime
                                          styleName:JDStatusBarStyleError];
        });
    } else {
        CourtesyCardModel *card = sender.card;
        dispatch_async_on_main_queue(^{
            [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"卡片 %@ 公开失败 - %@", card.local_template.mainTitle, [error localizedDescription]]
                                       dismissAfter:kStatusBarNotificationTime
                                          styleName:JDStatusBarStyleError];
        });
    }
}

#pragma mark - CourtesyCardCacheRequestHelperDelegate

- (void)cardCacheQuerySucceed:(CourtesyCardCacheRequestHelper *)helper {
    dispatch_async_on_main_queue(^{
        __weak typeof(self) weakSelf = self;
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"准备下载"
                                                            message:[NSString stringWithFormat:@"需要下载 %@ 的卡片资源",
                                                                     [FCFileManager sizeFormatted:[NSNumber numberWithUnsignedInteger:helper.totalBytes]]]
                                                              style:LGAlertViewStyleActionSheet
                                                       buttonTitles:@[@"开始"]
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                      actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                          [weakSelf startCacheWithHelper:helper];
                                                      }
                                                      cancelHandler:nil
                                                 destructiveHandler:nil];
        SetCourtesyAleryViewStyle(alertView, helper.relatedViewController.navigationController.view)
        if (self.currentAlert && self.currentAlert.isShowing) {
            [self.currentAlert transitionToAlertView:alertView completionHandler:nil];
        } else {
            [alertView showAnimated:YES completionHandler:nil];
        }
        self.currentAlert = alertView;
    });
}

- (void)cardCacheQueryFailed:(CourtesyCardCacheRequestHelper *)helper withError:(NSError *)error {
    dispatch_async_on_main_queue(^{
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"请求失败"
                                                            message:[NSString stringWithFormat:@"此时无法下载卡片资源 - %@", [error localizedDescription]]
                                                              style:LGAlertViewStyleActionSheet
                                                       buttonTitles:nil
                                                  cancelButtonTitle:@"好"
                                             destructiveButtonTitle:nil
                                                      actionHandler:nil
                                                      cancelHandler:nil
                                                 destructiveHandler:nil];
        SetCourtesyAleryViewStyle(alertView, helper.relatedViewController.navigationController.view)
        if (self.currentAlert && self.currentAlert.isShowing) {
            [self.currentAlert transitionToAlertView:alertView completionHandler:nil];
        } else {
            [alertView showAnimated:YES completionHandler:nil];
        }
        self.currentAlert = alertView;
    });
}

- (void)cardCachedSucceed:(CourtesyCardCacheRequestHelper *)helper {
    dispatch_async_on_main_queue(^{
        if (self.currentAlert && self.currentAlert.isShowing) {
            [self.currentAlert dismissAnimated:YES completionHandler:nil];
        }
        CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCard:helper.card];
        vc.delegate = self;
        [helper.relatedViewController presentViewController:vc animated:YES completion:nil];
    });
}

- (void)cardCachedFailed:(CourtesyCardCacheRequestHelper *)helper withError:(NSError *)error {
    [self cardCacheQueryFailed:helper withError:error];
}

- (void)cardCaching:(CourtesyCardCacheRequestHelper *)helper withProgress:(float)progress {
    if (progress > 1.f) progress = 1.f;
    dispatch_async_on_main_queue(^{
        [self.currentAlert setProgress:progress progressLabelText:[NSString stringWithFormat:@"%.0f %%", progress * 100]];
    });
}

- (void)startCacheWithHelper:(CourtesyCardCacheRequestHelper *)helper {
    LGAlertView *alertView = [[LGAlertView alloc] initWithProgressViewAndTitle:@"下载中"
                                                                       message:@"下载卡片资源可能需要一些时间，请耐心等候。"
                                                                         style:LGAlertViewStyleActionSheet
                                                             progressLabelText:@"0 %"
                                                                  buttonTitles:nil
                                                             cancelButtonTitle:@"取消"
                                                        destructiveButtonTitle:nil
                                                                 actionHandler:nil
                                                                 cancelHandler:^(LGAlertView *alertView) {
                                                                     [helper stop];
                                                                 }
                                                            destructiveHandler:nil];
    SetCourtesyAleryViewStyle(alertView, helper.relatedViewController.navigationController.view);
    [alertView showAnimated:YES completionHandler:nil];
    self.currentAlert = alertView;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [helper sendAsyncCacheRequest];
    });
}

@end
