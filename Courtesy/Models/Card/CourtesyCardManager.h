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
+ (id)sharedManager;
+ (CourtesyCardModel *)newCard;
- (void)composeNewCardWithViewController:(UIViewController *)controller;
- (void)editCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller;
- (NSMutableArray <CourtesyCardModel *> *)draftboxCardsList;
- (void)deleteCardInDraft:(CourtesyCardModel *)card;

@end
