//
//  CourtesyCardManager.m
//  Courtesy
//
//  Created by Zheng on 3/15/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardManager.h"
#import "CourtesyCardComposeViewController.h"
#import "AppStorage.h"

#define kCourtesyCardDraftListKey @"kCourtesyCardListKey"

@interface CourtesyCardManager () <CourtesyCardComposeDelegate, CourtesyCardDelegate>

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
    card.local_template = nil;
    
    // 初始化卡片内容
    card.card_data = [[CourtesyCardDataModel alloc] initWithCardToken:card.token];
    card.card_data.content = @"说点什么吧……";
    card.card_data.attachments = nil;
    card.card_data.styleID = kCourtesyCardStyleDefault;
    card.card_data.fontType = [sharedSettings preferredFontType];
    card.card_data.fontSize = [sharedSettings preferredFontSize];
    card.card_data.shouldAutoPlayAudio = NO;
    card.card_data.alignmentType = NSTextAlignmentLeft;
    
    card.newcard = YES;
    return card;
}

- (void)composeNewCardWithViewController:(UIViewController *)controller {
    CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCard:[self newCard]];
    vc.delegate = self;
    [controller presentViewController:vc animated:YES completion:nil];
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
    [card deleteInLocalDatabase];
    [self.cardDraftTokenArray removeObject:card.token];
    [self.cardDraftArray removeObject:card];
    [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
}

- (void)exchangeCardAtIndex:(NSInteger)sourceRow withCardAtIndex:(NSInteger)destinationRow {
    [self.cardDraftArray exchangeObjectAtIndex:sourceRow withObjectAtIndex:destinationRow];
    [self.cardDraftTokenArray exchangeObjectAtIndex:sourceRow withObjectAtIndex:destinationRow];
    [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
}

#pragma mark - CourtesyCardComposeDelegate

- (void)cardComposeViewDidFinishEditing:(nonnull CourtesyCardComposeViewController *)controller {

}

- (void)cardComposeViewWillBeginLoading:(nonnull CourtesyCardComposeViewController *)controller {

}

- (void)cardComposeViewDidFinishLoading:(nonnull CourtesyCardComposeViewController *)controller {

}

- (void)cardComposeViewDidCancelEditing:(CourtesyCardComposeViewController *)controller shouldSaveToDraftBox:(BOOL)save {
    if (save && controller.card) {
        [JDStatusBarNotification showWithStatus:@"正在保存卡片……"
                                   dismissAfter:kStatusBarNotificationTime
                                      styleName:JDStatusBarStyleDefault];
        [JDStatusBarNotification showActivityIndicator:YES
                                        indicatorStyle:UIActivityIndicatorViewStyleGray];
        [controller.card saveToLocalDatabase];
    }
    [controller dismissViewControllerAnimated:YES completion:^() {  }];
}

#pragma mark - CourtesyCardDelegate

- (void)cardDidFinishLoading:(nonnull CourtesyCardModel *)card {

}

- (void)cardDidFinishSaving:(nonnull CourtesyCardModel *)card newRecord:(BOOL)newRecord {
    if (newRecord) { // 添加记录则将元素加入数组并写入数据库
        [self.cardDraftTokenArray insertObject:card.token atIndex:0];
        [self.cardDraftArray insertObject:card atIndex:0];
    }
//    else { // 修改记录则将元素提到最前 (Is that necessary?)
//        NSInteger origIndex = [self.cardDraftArray indexOfObject:card];
//        [self.cardDraftTokenArray removeObjectAtIndex:origIndex];
//        [self.cardDraftArray removeObjectAtIndex:origIndex];
//        [self.cardDraftTokenArray insertObject:card.token atIndex:0];
//        [self.cardDraftArray insertObject:card atIndex:0];
//    }
    [self.appStorage setObject:self.cardDraftTokenArray forKey:kCourtesyCardDraftListKey];
    [JDStatusBarNotification showWithStatus:@"卡片已保存到草稿箱"
                               dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleSuccess];
}

- (void)cardDidFailedSaving:(nonnull CourtesyCardModel *)card {
    [JDStatusBarNotification showWithStatus:@"卡片保存失败"
                                   dismissAfter:kStatusBarNotificationTime
                                      styleName:JDStatusBarStyleError];
}

@end
