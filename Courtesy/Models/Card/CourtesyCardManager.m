//
//  CourtesyCardManager.m
//  Courtesy
//
//  Created by Zheng on 3/15/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardManager.h"

@implementation CourtesyCardManager
+ (id)sharedManager {
    static CourtesyCardManager *sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

+ (CourtesyCardModel *)newCard {
    // 初始化卡片
    CourtesyCardModel *card = [CourtesyCardModel new];
    card.is_editable = YES;
    card.is_public = [sharedSettings switchAutoPublic];
    card.view_count = 0;
    card.created_at = time(NULL);
    card.created_at_object = [NSDate date];
    card.modified_at = card.created_at;
    card.modified_at_object = [NSDate date];
    card.first_read_at = 0;
    card.first_read_at_object = nil;
    card.token = nil;
    card.edited_count = 0;
    card.stars = 0;
    card.author = kAccount;
    card.read_by = nil;
    card.local_template = nil;
    
    // 初始化卡片内容
    card.card_data = [CourtesyCardDataModel new];
    card.card_data.content = [[NSAttributedString alloc] initWithString:@"说点什么吧……"];
    card.card_data.attachments = nil;
    card.card_data.styleID = kCourtesyCardStyleDefault;
    card.card_data.style = [[CourtesyCardStyleManager sharedManager] styleWithID:card.card_data.styleID];
    card.card_data.shouldAutoPlayAudio = NO;
    card.card_data.newcard = YES;
    return card;
}

@end
