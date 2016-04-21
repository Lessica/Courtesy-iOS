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
