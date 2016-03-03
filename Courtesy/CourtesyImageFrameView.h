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

- (void)imageFrameTapped:(CourtesyImageFrameView *)imageFrame;
- (void)imageFrameDidBeginEditing:(CourtesyImageFrameView *)imageFrame;
- (void)imageFrameShouldDeleted:(CourtesyImageFrameView *)imageFrame;
- (void)imageFrameShouldCropped:(CourtesyImageFrameView *)imageFrame;

@end

@interface CourtesyImageFrameView : UIView <UITextFieldDelegate, PECropViewControllerDelegate>
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImage *centerImage;
@property (nonatomic, strong) UITextField *bottomLabel;
@property (nonatomic, weak) id<CourtesyImageFrameDelegate> delegate;

- (void)toggleBottomLabelView:(BOOL)on;

@end
