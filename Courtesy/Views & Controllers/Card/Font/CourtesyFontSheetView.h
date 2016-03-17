//
//  CourtesyFontViewController.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourtesyCardModel.h"
#import "CourtesyCardComposeViewController.h"

@class CourtesyFontSheetView;

@protocol CourtesyFontSheetViewDelegate <NSObject>
@property (nonatomic, strong) CourtesyCardModel *card;

- (void)fontSheetViewDidCancel:(CourtesyFontSheetView *)fontSheetView;
- (void)fontSheetViewDidTapDone:(CourtesyFontSheetView *)fontSheetView withFont:(UIFont *)font;
- (void)fontSheetView:(CourtesyFontSheetView *)fontSheetView changeFontSize:(CGFloat)size;

@end

@interface CourtesyFontSheetView : UIView
@property (nonatomic, weak) CourtesyCardComposeViewController <CourtesyFontSheetViewDelegate> *delegate;
- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController<CourtesyFontSheetViewDelegate> *)viewController;

@end
