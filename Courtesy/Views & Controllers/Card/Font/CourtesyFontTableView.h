//
//  CourtesyFontViewController.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourtesyCardModel.h"

@class CourtesyFontTableView;

@protocol CourtesyFontViewDelegate <NSObject>

@optional
- (void)fontViewDidCancel:(CourtesyFontTableView *)fontViewController;

@optional
- (void)fontViewDidTapDone:(CourtesyFontTableView *)fontViewController withFont:(UIFont *)font;

@optional
- (void)fontView:(CourtesyFontTableView *)fontViewController changeFontSize:(CGFloat)size;

@end

@interface CourtesyFontTableView : UIView
@property (nonatomic, weak) id<CourtesyFontViewDelegate> delegate;
@property (nonatomic, strong) CourtesyCardModel *card;
@property (nonatomic, assign) CGFloat fitSize;

@end
