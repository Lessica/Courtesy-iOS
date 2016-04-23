//
//  CourtesyCardManager.m
//  Courtesy
//
//  Created by Zheng on 3/15/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "AppStorage.h"
#import "CourtesyCardManager.h"
#import "CourtesyCardComposeViewController.h"
#import "CourtesyCardPublishQueue.h"
#import "CourtesyCardDeleteRequestModel.h"

#define kCourtesyCardDraftListKey @"kCourtesyCardListKey"

@interface CourtesyCardManager () <CourtesyCardComposeDelegate, CourtesyCardDelegate, CourtesyCardDeleteRequestDelegate>

@end

@implementation CourtesyCardManager

+ (id)sharedManager {
    static CourtesyCardManager *sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        id obj = [self.appStorage objectForKey:kCourtesyCardDraftListKey];
        if (obj && [obj isMemberOfClass:[NSMutableArray class]]) {
            self.cardDraftTokenArray = obj;
        } else {
            self.cardDraftTokenArray = [[NSMutableArray alloc] init];
        }
        self.cardDraftArray = [[NSMutableArray alloc] init];

        // Load Draft Cards List From Database
        id list_obj = [self.appStorage objectForKey:kCourtesyCardDraftListKey];
        BOOL shouldSync = NO;
        NSMutableArray *tokensShouldBeRemoved = [NSMutableArray new];
        if (list_obj && [list_obj isKindOfClass:[NSMutableArray class]]) {
            self.cardDraftTokenArray = list_obj;
        }
        for (NSString *token in self.cardDraftTokenArray) {
            CourtesyCardModel *card = [[CourtesyCardModel alloc] initWithCardToken:token];
            if (!card) {
                shouldSync = YES;
                [tokensShouldBeRemoved addObject:token];
                continue;
            }
            card.delegate = self;
            [self.cardDraftArray addObject:card];
        }
        if (shouldSync) { // 需要同步卡片列表数组，因为卡片不存在了
            for (NSString *invalid_token in tokensShouldBeRemoved) {
                [self.cardDraftTokenArray removeObject:invalid_token];
            }
            [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
        }
    }
    return self;
}

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
}

- (CourtesyCardModel *)newCard {
    // 初始化卡片
    CourtesyCardModel *card = [CourtesyCardModel new];
    card.delegate = self;
    card.is_editable = YES;
    card.is_public = [sharedSettings switchAutoPublic];
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

- (CourtesyCardModel *)composeNewCardWithViewController:(UIViewController *)controller {
    CourtesyCardModel *newCard = [self newCard];
    CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCard:newCard];
    vc.delegate = self;
    [controller presentViewController:vc animated:YES completion:nil];
    return newCard;
}

- (void)editCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller {
    CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCard:card];
    vc.delegate = self;
    [controller presentViewController:vc animated:YES completion:nil];
}

- (UIViewController *)prepareCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller {
    CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCard:card];
    vc.previewContext = YES;
    vc.delegate = self;
    return vc;
}

- (void)commitCardComposeViewController:(UIViewController *)viewController withViewController:(UIViewController *)controller {
    CourtesyCardComposeViewController *vc = (CourtesyCardComposeViewController *)viewController;
    vc.previewContext = NO;
    [controller presentViewController:vc animated:YES completion:nil];
}

- (void)deleteCardInDraft:(CourtesyCardModel *)card {
    if (card.hasPublished) {
        dispatch_async_on_main_queue(^{
            [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"正在撤回卡片 %@……", card.local_template.mainTitle]
                                       dismissAfter:kStatusBarNotificationTime
                                          styleName:JDStatusBarStyleDefault];
            [JDStatusBarNotification showActivityIndicator:YES
                                            indicatorStyle:UIActivityIndicatorViewStyleGray];
        });
        
        __block CourtesyCardDeleteRequestModel *deleteRequest = [[CourtesyCardDeleteRequestModel alloc] initWithDelegate:self];
        deleteRequest.token = card.token;
        deleteRequest.card = card;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [deleteRequest sendRequest];
        });
    } else {
        [card deleteInLocalDatabase];
        [self.cardDraftTokenArray removeObject:card.token];
        [self.cardDraftArray removeObject:card];
        [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
    }
}

- (void)exchangeCardAtIndex:(NSInteger)sourceRow withCardAtIndex:(NSInteger)destinationRow {
    [self.cardDraftArray exchangeObjectAtIndex:sourceRow withObjectAtIndex:destinationRow];
    [self.cardDraftTokenArray exchangeObjectAtIndex:sourceRow withObjectAtIndex:destinationRow];
    [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
}

#pragma mark - CourtesyCardComposeDelegate

- (void)backToAlbumViewController {
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] albumViewController]];
}

- (void)cardComposeViewDidFinishEditing:(nonnull CourtesyCardComposeViewController *)controller {
    if (controller.card) {
        [controller.card saveToLocalDatabaseShouldPublish:YES];
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
        [controller.card saveToLocalDatabaseShouldPublish:NO];
        [self backToAlbumViewController];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CourtesyCardDelegate

- (void)cardDidFinishLoading:(nonnull CourtesyCardModel *)card {

}

- (void)cardDidFinishSaving:(nonnull CourtesyCardModel *)card isNewRecord:(BOOL)newRecord willPublish:(BOOL)willPublish {
    if (newRecord) { // 添加记录则将元素加入数组并写入数据库
        [self.cardDraftTokenArray insertObject:card.token atIndex:0];
        [self.cardDraftArray insertObject:card atIndex:0];
    }
    [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
    if (willPublish == NO) {
        dispatch_async_on_main_queue(^{
            [JDStatusBarNotification showWithStatus:@"卡片已保存到草稿箱"
                                       dismissAfter:kStatusBarNotificationTime
                                          styleName:JDStatusBarStyleSuccess];
        });
    } else {
        [[CourtesyCardPublishQueue sharedQueue] addCardPublishTask:card];
    }
}

- (void)cardDidFailedSaving:(nonnull CourtesyCardModel *)card {
    dispatch_async_on_main_queue(^{
        [JDStatusBarNotification showWithStatus:@"卡片保存失败"
                                   dismissAfter:kStatusBarNotificationTime
                                      styleName:JDStatusBarStyleError];
    });
}

#pragma mark - CourtesyCardDeleteRequestDelegate

- (void)cardDeleteRequestSucceed:(CourtesyCardDeleteRequestModel *)sender {
    CourtesyCardModel *card = sender.card;
    dispatch_async_on_main_queue(^{
        [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"卡片 %@ 撤回成功", card.local_template.mainTitle]
                                   dismissAfter:kStatusBarNotificationTime
                                      styleName:JDStatusBarStyleSuccess];
    });
    card.hasPublished = NO;
    [card saveToLocalDatabaseShouldPublish:NO];
}

- (void)cardDeleteRequestFailed:(CourtesyCardDeleteRequestModel *)sender
                      withError:(NSError *)error {
    CourtesyCardModel *card = sender.card;
    dispatch_async_on_main_queue(^{
        [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"卡片 %@ 撤回失败 - %@", card.local_template.mainTitle, [error localizedDescription]]
                                   dismissAfter:kStatusBarNotificationTime
                                      styleName:JDStatusBarStyleError];
    });
}

@end
