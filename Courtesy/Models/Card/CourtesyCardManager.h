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
- (CourtesyCardModel *)newCard;
- (void)composeNewCardWithViewController:(UIViewController *)controller;
- (void)editCard:(CourtesyCardModel *)card withViewController:(UIViewController *)controller;
- (void)deleteCardInDraft:(CourtesyCardModel *)card;

@end
