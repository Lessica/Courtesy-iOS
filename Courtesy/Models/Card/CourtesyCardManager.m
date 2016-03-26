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

@interface CourtesyCardManager () <CourtesyCardComposeDelegate>
@property (nonatomic, strong) NSMutableArray <NSString *> *cardDraftIDArray;
@property (nonatomic, strong) NSMutableArray <CourtesyCardModel *> *cardDraftArray;

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
            self.cardDraftIDArray = obj;
        } else {
            self.cardDraftIDArray = [[NSMutableArray alloc] init];
        }
        self.cardDraftArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
}

+ (CourtesyCardModel *)newCard {
    // 初始化卡片
    CourtesyCardModel *card = [CourtesyCardModel new];
    card.delegate = [self sharedManager];
    card.is_editable = YES;
    card.is_public = [sharedSettings switchAutoPublic];
    card.view_count = 0;
    card.created_at_object = [NSDate date];
    card.modified_at_object = [NSDate date];
    card.first_read_at = 0;
    card.first_read_at_object = nil;
    card.token = nil;
    card.edited_count = 0;
    card.stars = 0;
    card.author = kAccount;
    card.read_by = nil;
    card.local_template = nil;
    card.local_token = [[NSUUID UUID] UUIDString];
    
    // 初始化卡片内容
    card.card_data = [CourtesyCardDataModel new];
    card.card_data.content = @"说点什么吧……";
    card.card_data.attachments = nil;
    card.card_data.styleID = kCourtesyCardStyleDefault;
    card.card_data.style = [[CourtesyCardStyleManager sharedManager] styleWithID:card.card_data.styleID];
    card.card_data.fontType = [sharedSettings preferredFontType];
    card.card_data.fontSize = [sharedSettings preferredFontSize];
    card.card_data.shouldAutoPlayAudio = NO;
    card.card_data.alignmentType = NSTextAlignmentLeft;
    
    card.newcard = YES;
    return card;
}

- (void)composeNewCardWithViewController:(UIViewController *)controller {
    CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCard:[CourtesyCardManager newCard]];
    vc.delegate = self;
    [controller presentViewController:vc animated:YES completion:nil];
}

- (void)editCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller {
    CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCard:card];
    vc.delegate = self;
    [controller presentViewController:vc animated:YES completion:nil];
}

- (void)deleteCardInDraft:(CourtesyCardModel *)card {
    [card deleteInLocalDatabase];
    [self.cardDraftIDArray removeObject:card.local_token];
    [self.cardDraftArray removeObject:card];
}

- (NSMutableArray <CourtesyCardModel *> *)draftboxCardsList {
    return self.cardDraftArray;
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
    if (newRecord) {
        [self.cardDraftIDArray addObject:card.local_token];
        [self.cardDraftArray addObject:card];
    }
    [self.appStorage setObject:self.cardDraftIDArray forKey:kCourtesyCardDraftListKey];
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
