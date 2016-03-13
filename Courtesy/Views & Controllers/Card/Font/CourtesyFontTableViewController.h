//
//  CourtesyFontViewController.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CourtesyFontTableViewController;

@protocol CourtesyFontViewControllerDelegate <NSObject>

@optional
- (void)fontViewControllerDidCancel:(CourtesyFontTableViewController *)fontViewController;

@optional
- (void)fontViewControllerDidTapDone:(CourtesyFontTableViewController *)fontViewController withFont:(UIFont *)font;

@optional
- (void)fontViewController:(CourtesyFontTableViewController *)fontViewController
            changeFontSize:(CGFloat)size;

@end

@interface CourtesyFontTableViewController : UIViewController
@property (nonatomic, weak) id<CourtesyFontViewControllerDelegate> delegate;
@property (nonatomic, assign) CGFloat fitSize;

- (instancetype)initWithMasterViewController:(UIViewController *)masterViewController;

@end
