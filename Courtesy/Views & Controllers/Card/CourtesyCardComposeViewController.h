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

typedef enum : NSUInteger {
    kCourtesyInputViewDefault    = 0,
    kCourtesyInputViewFontSheet  = 1,
    kCourtesyInputViewAudioSheet = 2,
    kCourtesyInputViewAudioNote  = 3,
    kCourtesyInputViewImageSheet = 4,
    kCourtesyInputViewVideoSheet = 5,
} CourtesyInputViewType;

@interface CourtesyCardComposeViewController : UIViewController
@property (nonatomic, copy, nullable) CourtesyQRCodeModel *qrcode;
@property (nonatomic, strong, readonly, nullable) CourtesyCardModel *card;
// Shortcut for card.editable
@property (nonatomic, assign, readonly) BOOL editable;
// Shortcut for card.card_data.style
@property (nonatomic, strong, readonly, nullable) CourtesyCardStyleModel *style;

- (nonnull instancetype)initWithCard:(nullable CourtesyCardModel *)card;
@end
