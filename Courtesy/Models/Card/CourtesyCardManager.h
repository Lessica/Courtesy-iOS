//
//  CourtesyCardManager.h
//  Courtesy
//
//  Created by Zheng on 3/15/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CourtesyCardModel.h"

@interface CourtesyCardManager : NSObject <CourtesyCardDelegate>
@property (nonatomic, strong) NSMutableArray <NSString *> *cardDraftTokenArray;
@property (nonatomic, strong) NSMutableArray <CourtesyCardModel *> *cardDraftArray;

@property (nonatomic, strong) NSMutableArray <NSString *> *cardHistoryTokenArray;
@property (nonatomic, strong) NSMutableArray <CourtesyCardModel *> *cardHistoryArray;

+ (id)sharedManager;
- (void)clearCards;
- (void)clearHistory;

- (CourtesyCardModel *)newCard;
- (CourtesyCardModel *)composeNewCardWithViewController:(UIViewController *)controller;
- (void)editCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller;

- (void)publicCardInDraft:(CourtesyCardModel *)card;
- (void)restoreCardInDraft:(CourtesyCardModel *)card;

- (void)deleteCardInDraft:(CourtesyCardModel *)card;
- (void)exchangeCardAtIndex:(NSInteger)sourceRow withCardAtIndex:(NSInteger)destinationRow;

- (void)deleteCardInHistory:(CourtesyCardModel *)card;
- (void)exchangeHistoryCardAtIndex:(NSInteger)sourceRow withCardAtIndex:(NSInteger)destinationRow;

- (UIViewController *)prepareCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller;
- (void)commitCardComposeViewController:(UIViewController *)viewController withViewController:(UIViewController *)controller;

- (BOOL)hasLocalToken:(NSString *)token;
- (CourtesyCardModel *)cardWithToken:(NSString *)token;

- (void)handleRemoteCardToken:(NSString *)token withController:(UIViewController *)controller;

@end
