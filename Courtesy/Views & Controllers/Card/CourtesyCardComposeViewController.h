//
//  CourtesyCardComposeViewController.h
//  Courtesy
//
//  Created by Zheng on 3/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardStyleModel.h"
#import "CourtesyQRCodeModel.h"
#import "CourtesyCardManager.h"

@interface CourtesyCardComposeViewController : UIViewController

// 传值
@property (nonatomic, copy, nullable) CourtesyQRCodeModel *qrcode;


@property (nonatomic, strong, readonly, nullable) CourtesyCardModel *card;
// Shortcut for card.editable
@property (nonatomic, assign, readonly) BOOL editable;
// Shortcut for card.card_data.style
@property (nonatomic, strong, readonly, nullable) CourtesyCardStyleModel *style;

- (nonnull instancetype)initWithCard:(nullable CourtesyCardModel *)card;
@end
