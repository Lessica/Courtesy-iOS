//
//  CourtesyImageFrameView.h
//  Courtesy
//
//  Created by Zheng on 3/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "PECropViewController.h"

@class CourtesyImageFrameView;

@protocol CourtesyImageFrameDelegate <NSObject>

@optional
- (void)imageFrameTapped:(CourtesyImageFrameView *)imageFrame;

@optional
- (void)imageFrameDidBeginEditing:(CourtesyImageFrameView *)imageFrame;

@optional
- (void)imageFrameShouldDeleted:(CourtesyImageFrameView *)imageFrame
                       animated:(BOOL)animated;

@optional
- (void)imageFrameShouldCropped:(CourtesyImageFrameView *)imageFrame;

@optional
- (void)imageFrameDidEndEditing:(CourtesyImageFrameView *)imageFrame;

@optional
- (void)imageFrameShouldReplaced:(CourtesyImageFrameView *)imageFrame
                              by:(UIImage *)image;

@end

@interface CourtesyImageFrameView : UIView <UITextFieldDelegate, PECropViewControllerDelegate>
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImage *centerImage;
@property (nonatomic, strong) UITextField *bottomLabel;
@property (nonatomic, weak) id<CourtesyImageFrameDelegate> delegate;
@property (nonatomic, assign) NSRange selfRange;

- (void)toggleBottomLabelView:(BOOL)on;

@end
