//
//  CourtesyCardManager.h
//  Courtesy
//
//  Created by Zheng on 3/15/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CourtesyCardModel.h"

@interface CourtesyCardManager : NSObject
@property (nonatomic, strong) NSMutableArray <NSString *> *cardDraftTokenArray;
@property (nonatomic, strong) NSMutableArray <CourtesyCardModel *> *cardDraftArray;

+ (id)sharedManager;
- (void)clearCards;
- (void)reloadCards;
- (CourtesyCardModel *)newCard;
- (CourtesyCardModel *)composeNewCardWithViewController:(UIViewController *)controller;
- (void)editCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller;
- (void)deleteCardInDraft:(CourtesyCardModel *)card;
- (void)restoreCardInDraft:(CourtesyCardModel *)card;
- (void)exchangeCardAtIndex:(NSInteger)sourceRow withCardAtIndex:(NSInteger)destinationRow;
- (UIViewController *)prepareCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller;
- (void)commitCardComposeViewController:(UIViewController *)viewController withViewController:(UIViewController *)controller;
- (void)handleRemoteCardToken:(NSString *)token;

@end
