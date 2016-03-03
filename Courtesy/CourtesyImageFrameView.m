//
//  CourtesyImageFrameView.m
//  Courtesy
//
//  Created by Zheng on 3/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyImageFrameView.h"

#define kImageFrameLabelHeight 24
#define kImageFrameLabelTextHeight 16
#define kImageFrameBorderWidth 6
#define kImageFrameBtnBorderWidth 16
#define kImageFrameBtnWidth 27
#define kImageFrameBtnInterval 12

@implementation CourtesyImageFrameView {
    BOOL optionsOpen;
    BOOL labelOpen;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Init of Frame View
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowOpacity = 0.45;
        self.layer.shadowRadius = 1;
        // Init of Small Option Buttons
        UIImageView *deleteBtn = [[UIImageView alloc] initWithFrame:CGRectMake(kImageFrameBtnBorderWidth, kImageFrameBtnBorderWidth, kImageFrameBtnWidth, kImageFrameBtnWidth)];
        deleteBtn.backgroundColor = [UIColor clearColor];
        deleteBtn.image = [UIImage imageNamed:@"41-unbrella-delete"];
        deleteBtn.alpha = 0;
        deleteBtn.hidden = YES;
        deleteBtn.userInteractionEnabled = YES;
        UITapGestureRecognizer *deleteGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *g) {
            [_delegate imageFrameShouldDeleted:self];
        }];
        [deleteBtn addGestureRecognizer:deleteGesture];
        [self addSubview:deleteBtn];
        UIImageView *editBtn = [[UIImageView alloc] initWithFrame:CGRectMake(kImageFrameBtnBorderWidth + kImageFrameBtnWidth + kImageFrameBtnInterval, kImageFrameBtnBorderWidth, kImageFrameBtnWidth, kImageFrameBtnWidth)];
        editBtn.backgroundColor = [UIColor clearColor];
        editBtn.image = [UIImage imageNamed:@"43-unbrella-edit"];
        editBtn.alpha = 0;
        editBtn.hidden = YES;
        editBtn.userInteractionEnabled = YES;
        UITapGestureRecognizer *editGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *g) {
            if (!labelOpen) {
                [self toggleBottomLabelView:YES];
            } else {
                [self toggleBottomLabelView:NO];
            }
        }];
        [editBtn addGestureRecognizer:editGesture];
        [self addSubview:editBtn];
        UIImageView *cropBtn = [[UIImageView alloc] initWithFrame:CGRectMake(kImageFrameBtnBorderWidth + (kImageFrameBtnWidth + kImageFrameBtnInterval) * 2, kImageFrameBtnBorderWidth, kImageFrameBtnWidth, kImageFrameBtnWidth)];
        cropBtn.backgroundColor = [UIColor clearColor];
        cropBtn.image = [UIImage imageNamed:@"42-unbrella-insert"];
        cropBtn.alpha = 0;
        cropBtn.hidden = YES;
        cropBtn.userInteractionEnabled = YES;
        UITapGestureRecognizer *cropGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *g) {
            [_delegate imageFrameShouldCropped:self];
        }];
        [cropBtn addGestureRecognizer:cropGesture];
        [self addSubview:cropBtn];
        __weak typeof(self) _self = self;
        // Init of Gesture Recognizer
        UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *g) {
            __strong typeof(_self) self = _self;
            optionsOpen = !optionsOpen;
            if (_bottomLabel && [_bottomLabel isFirstResponder]) {
                [_bottomLabel resignFirstResponder];
            }
            if (_centerImageView) {
                if (optionsOpen) {
                    [_centerImageView setHasGaussian:YES];
                    deleteBtn.hidden = NO;
                    editBtn.hidden = NO;
                    cropBtn.hidden = NO;
                    [UIView animateWithDuration:0.2
                                     animations:^{
                                         deleteBtn.alpha = 1;
                                         editBtn.alpha = 1;
                                         cropBtn.alpha = 1;
                                     } completion:^(BOOL finished) {
                                         
                                     }];
                } else {
                    [_centerImageView setHasGaussian:NO];
                    [UIView animateWithDuration:0.2
                                     animations:^{
                                         deleteBtn.alpha = 0;
                                         editBtn.alpha = 0;
                                         cropBtn.alpha = 0;
                                     } completion:^(BOOL finished) {
                                         deleteBtn.hidden = YES;
                                         editBtn.hidden = YES;
                                         cropBtn.hidden = YES;
                                     }];
                }
            }
            if (_delegate) {
                [_delegate imageFrameTapped:self];
            }
        }];
        [self addGestureRecognizer:g];
        // Init of Bottom Label View
        _bottomLabel = [UITextField new];
        _bottomLabel.tintColor = [UIColor darkGrayColor];
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.textColor = [UIColor darkGrayColor];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.placeholder = @"图片描述";
        _bottomLabel.userInteractionEnabled = YES;
        _bottomLabel.delegate = self;
        labelOpen = NO;
    }
    return self;
}

- (void)setCenterImage:(UIImage *)centerImage {
    // Remove Old Image View
    if (_centerImageView) {
        [_centerImageView removeFromSuperview];
    }
    // Calculate Image Scaled Height
    CGFloat scaleValue = 0;
    CGFloat height = 0;
    // Set New Image View
    _centerImage = centerImage;
    _centerImageView = nil;
    if (_centerImage.size.width > self.frame.size.width) {
        scaleValue = self.frame.size.width / _centerImage.size.width;
        height = _centerImage.size.height * scaleValue;
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - kImageFrameBorderWidth * 2, height)];
        _centerImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        height = _centerImage.size.height;
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - kImageFrameBorderWidth * 2, height)];
        _centerImageView.contentMode = UIViewContentModeCenter;
    }
    _centerImageView.clipsToBounds = YES;
    _centerImageView.userInteractionEnabled = YES;
    _centerImageView.image = _centerImage;
    _centerImageView.nl_hasGaussian = NO;
    // Reset Frame View
    if (labelOpen) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _centerImageView.height + kImageFrameBorderWidth * 2 + kImageFrameLabelHeight);
        _centerImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - kImageFrameLabelHeight);
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _centerImageView.height + kImageFrameBorderWidth * 2);
        _centerImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    }
    [self addSubview:_centerImageView];
    [self sendSubviewToBack:_centerImageView];
}

- (void)toggleBottomLabelView:(BOOL)on {
    if (on && !labelOpen) {
        labelOpen = YES;
        CGFloat targetHeight = self.height + kImageFrameLabelHeight;
        // Reset Label View
        _bottomLabel.frame = CGRectMake(kImageFrameBorderWidth, targetHeight - kImageFrameBorderWidth - kImageFrameLabelTextHeight, self.frame.size.width - kImageFrameBorderWidth * 2, kImageFrameLabelTextHeight);
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self setHeight:targetHeight];
                         } completion:^(BOOL finished) {
                             [self addSubview:_bottomLabel];
                             if (![_bottomLabel isFirstResponder]) {
                                 [_bottomLabel becomeFirstResponder];
                             }
                         }];
    } else if (!on && labelOpen) {
        labelOpen = NO;
        if ([_bottomLabel isFirstResponder]) {
            [_bottomLabel resignFirstResponder];
        }
        CGFloat targetHeight = self.height - kImageFrameLabelHeight;
        [_bottomLabel removeFromSuperview];
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self setHeight:targetHeight];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    if ([textField.text isEmpty]) {
        [self toggleBottomLabelView:NO];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (_delegate) {
        [_delegate imageFrameDidBeginEditing:self];
    }
}

#pragma mark - PECropViewControllerDelegate

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
    if (controller) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        [self setCenterImage:croppedImage];
    }
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
    if (controller) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
