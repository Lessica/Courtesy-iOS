//
//  CourtesyImageFrameView.m
//  Courtesy
//
//  Created by Zheng on 3/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyImageFrameView.h"

@implementation CourtesyImageFrameView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Init of Frame View
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowOpacity = 0.45;
        self.layer.shadowRadius = 1;
        // Init of Small Option Buttons
        for (UIImageView *btn in [self optionButtons]) {
            [self addSubview:btn];
        }
        // Init of Gesture Recognizer
        UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(frameTapped:)];
        [self addGestureRecognizer:g];
        // Init of Bottom Label View
        _bottomLabel = [UITextField new];
        _bottomLabel.tintColor = [UIColor darkGrayColor];
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.textColor = [UIColor darkGrayColor];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.placeholder = [self labelHolder];
        _bottomLabel.userInteractionEnabled = YES;
        _bottomLabel.delegate = self;
        _labelOpen = NO;
    }
    return self;
}

- (NSString *)labelHolder {
    return @"图片描述";
}

- (NSArray *)optionButtons {
    return @[[self deleteBtn],
             [self editBtn],
             [self cropBtn]];
}

- (UIImageView *)centerBtn {
    return nil;
}

- (UIImageView *)cropBtn {
    if (!_cropBtn) {
        _cropBtn = [[UIImageView alloc] initWithFrame:CGRectMake(kImageFrameBtnBorderWidth + (kImageFrameBtnWidth + kImageFrameBtnInterval) * 2, kImageFrameBtnBorderWidth, kImageFrameBtnWidth, kImageFrameBtnWidth)];
        _cropBtn.backgroundColor = [UIColor clearColor];
        _cropBtn.image = [UIImage imageNamed:@"42-unbrella-insert"];
        _cropBtn.alpha = 0;
        _cropBtn.hidden = YES;
        _cropBtn.userInteractionEnabled = YES;
        __weak typeof(self) _self = self;
        UITapGestureRecognizer *cropGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *g) {
            __strong typeof(_self) self = _self;
            [self frameTapped:g];
            if (_delegate && [_delegate respondsToSelector:@selector(imageFrameShouldCropped:)]) {
                [_delegate imageFrameShouldCropped:self];
            }
        }];
        [_cropBtn addGestureRecognizer:cropGesture];
    }
    return _cropBtn;
}

- (UIImageView *)editBtn {
    if (!_editBtn) {
        _editBtn = [[UIImageView alloc] initWithFrame:CGRectMake(kImageFrameBtnBorderWidth + kImageFrameBtnWidth + kImageFrameBtnInterval, kImageFrameBtnBorderWidth, kImageFrameBtnWidth, kImageFrameBtnWidth)];
        _editBtn.backgroundColor = [UIColor clearColor];
        _editBtn.image = [UIImage imageNamed:@"43-unbrella-edit"];
        _editBtn.alpha = 0;
        _editBtn.hidden = YES;
        _editBtn.userInteractionEnabled = YES;
        __weak typeof(self) _self = self;
        UITapGestureRecognizer *editGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *g) {
            __strong typeof(_self) self = _self;
            [self frameTapped:g];
            if (!_labelOpen) {
                [self toggleBottomLabelView:YES];
            } else {
                [self toggleBottomLabelView:NO];
            }
        }];
        [_editBtn addGestureRecognizer:editGesture];
    }
    return _editBtn;
}

- (UIImageView *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [[UIImageView alloc] initWithFrame:CGRectMake(kImageFrameBtnBorderWidth, kImageFrameBtnBorderWidth, kImageFrameBtnWidth, kImageFrameBtnWidth)];
        _deleteBtn.backgroundColor = [UIColor clearColor];
        _deleteBtn.image = [UIImage imageNamed:@"41-unbrella-delete"];
        _deleteBtn.alpha = 0;
        _deleteBtn.hidden = YES;
        _deleteBtn.userInteractionEnabled = YES;
        __weak typeof(self) _self = self;
        UITapGestureRecognizer *deleteGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *g) {
            __strong typeof(_self) self = _self;
            if (_delegate && [_delegate respondsToSelector:@selector(imageFrameShouldDeleted:animated:)]) {
                [_delegate imageFrameShouldDeleted:self animated:YES];
            }
        }];
        [_deleteBtn addGestureRecognizer:deleteGesture];
    }
    return _deleteBtn;
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
        if (_centerImage.size.height < kImageFrameMinHeight) {
            height = kImageFrameMinHeight; // 最小高度
        } else {
            height = _centerImage.size.height;
        }
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - kImageFrameBorderWidth * 2, height)];
        _centerImageView.contentMode = UIViewContentModeCenter;
    }
    _centerImageView.tintColor = [UIColor whiteColor];
    _centerImageView.clipsToBounds = YES;
    _centerImageView.userInteractionEnabled = YES;
    _centerImageView.image = _centerImage;
    _centerImageView.nl_hasGaussian = NO;
    // Reset Frame View
    if (_labelOpen) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _centerImageView.height + kImageFrameBorderWidth * 2 + kImageFrameLabelHeight);
        _centerImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - kImageFrameLabelHeight);
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _centerImageView.height + kImageFrameBorderWidth * 2);
        _centerImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    }
    [self addSubview:_centerImageView];
    [self sendSubviewToBack:_centerImageView];
    if ([self centerBtn]) {
        [_centerImageView addSubview:[self centerBtn]];
    }
}

- (void)frameTapped:(id)sender {
        _optionsOpen = !_optionsOpen;
        if (_bottomLabel && [_bottomLabel isFirstResponder]) {
            [_bottomLabel resignFirstResponder];
        }
        if (_centerImageView) {
            if (_optionsOpen) {
                [_centerImageView setHasGaussian:YES];
                for (UIImageView *btn in [self optionButtons]) {
                    btn.hidden = NO;
                }
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     for (UIImageView *btn in [self optionButtons]) {
                                         btn.alpha = 1.0;
                                     }
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            } else {
                [_centerImageView setHasGaussian:NO];
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     for (UIImageView *btn in [self optionButtons]) {
                                         btn.alpha = 0.0;
                                     }
                                 } completion:^(BOOL finished) {
                                     if (finished) {
                                         for (UIImageView *btn in [self optionButtons]) {
                                             btn.hidden = YES;
                                         }
                                     }
                                 }];
            }
        }
    if (_delegate && [_delegate respondsToSelector:@selector(imageFrameTapped:)]) {
        [_delegate imageFrameTapped:self];
    }
}

- (void)toggleBottomLabelView:(BOOL)on {
    if (on && !_labelOpen) {
        _labelOpen = YES;
        CGFloat targetHeight = self.height + kImageFrameLabelHeight;
        // Reset Label View
        _bottomLabel.frame = CGRectMake(kImageFrameBorderWidth, targetHeight - kImageFrameBorderWidth - kImageFrameLabelTextHeight, self.frame.size.width - kImageFrameBorderWidth * 2, kImageFrameLabelTextHeight);
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self setHeight:targetHeight];
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 [self addSubview:_bottomLabel];
                                 if (![_bottomLabel isFirstResponder]) {
                                     [_bottomLabel becomeFirstResponder];
                                 }
                             }
                         }];
    } else if (!on && _labelOpen) {
        _labelOpen = NO;
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
    if (_delegate && [_delegate respondsToSelector:@selector(imageFrameDidBeginEditing:)]) {
        [_delegate imageFrameDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEmpty]) {
        [self toggleBottomLabelView:NO];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(imageFrameDidEndEditing:)]) {
        [_delegate imageFrameDidEndEditing:self];
    }
}

#pragma mark - PECropViewControllerDelegate

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
    if (controller) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (_delegate && [_delegate respondsToSelector:@selector(imageFrameShouldReplaced:by:userinfo:)]) {
            [_delegate imageFrameShouldReplaced:self by:croppedImage userinfo:_userinfo];
        }
    }
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
    if (controller) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
