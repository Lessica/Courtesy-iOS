//
//  CourtesyCardComposeViewController.h
//  Courtesy
//
//  Created by Zheng on 3/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardModel.h"
#import "CourtesyCardStyleModel.h"
#import "CourtesyQRCodeModel.h"

#define kComposeTopInsect 24.0
#define kComposeBottomInsect 24.0
#define kComposeLeftInsect 24.0
#define kComposeRightInsect 24.0
#define kComposeTopBarInsectPortrait 24.0
#define kComposeTopBarInsectUpdated 64.0
#define kComposeCardViewMargin 12.0
#define kComposeCardViewBorderWidth 4.0
#define kComposeCardViewShadowOpacity 0.4
#define kComposeCardViewShadowRadius 20.0
#define kComposeCardViewCornerRadius 10.0
#define kComposeCardViewEditInset UIEdgeInsetsMake(-kComposeCardViewMargin / 2, -kComposeCardViewMargin / 2, -kComposeCardViewMargin / 2, -kComposeCardViewMargin / 2)

typedef enum : NSUInteger {
    kCourtesyInputViewDefault    = 0,
    kCourtesyInputViewFontSheet  = 1,
    kCourtesyInputViewAudioSheet = 2,
    kCourtesyInputViewAudioNote  = 3,
    kCourtesyInputViewImageSheet = 4,
    kCourtesyInputViewVideoSheet = 5,
} CourtesyInputViewType;

@class CourtesyCardComposeViewController;

@protocol CourtesyCardComposeDelegate <NSObject>

- (void)cardComposeViewDidFinishEditing:(nonnull CourtesyCardComposeViewController *)controller;
- (void)cardComposeViewWillBeginLoading:(nonnull CourtesyCardComposeViewController *)controller;
- (void)cardComposeViewDidFinishLoading:(nonnull CourtesyCardComposeViewController *)controller;
- (void)cardComposeViewDidCancelEditing:(nonnull CourtesyCardComposeViewController *)controller shouldSaveToDraftBox:(BOOL)save;

@end

@interface CourtesyCardComposeViewController : UIViewController
@property (nonatomic, copy, nullable) CourtesyQRCodeModel *qrcode;
@property (nonatomic, strong, readonly, nullable) CourtesyCardModel *card;
// Shortcut for card.editable
@property (nonatomic, assign, readonly) BOOL editable;
// Shortcut for card.local_template.style
@property (nonatomic, strong, readonly, nullable) CourtesyCardStyleModel *style;
// Preview flag
@property (nonatomic, assign) BOOL previewContext;
@property (nonatomic, strong, nullable, readonly) UIFont *originalFont;
@property (nonatomic, strong, nullable, readonly) NSDictionary *originalAttributes;
@property (nonatomic, weak, nullable) id<CourtesyCardComposeDelegate> delegate;
@property (nonatomic, assign) BOOL cardEdited;

- (nonnull instancetype)initWithCard:(nullable CourtesyCardModel *)card;
@end
