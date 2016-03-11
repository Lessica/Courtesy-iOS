//
//  CourtesyImageFrameView.m
//  Courtesy
//
//  Created by Zheng on 3/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyImageFrameView.h"

@implementation CourtesyImageFrameView {
    UITapGestureRecognizer *tapGesture;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Init of Frame View
        [self setCardBackgroundColor:nil];
        [self setCardShadowColor:nil];
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowOpacity = 0.45;
        self.layer.shadowRadius = 1;
        // Init of Small Option Buttons
        for (UIImageView *btn in [self optionButtons]) [self addSubview:btn];
        [self setEditable:NO];
        // Init of Bottom Label View
        [self setCardTintColor:nil];
        [self setCardTextColor:nil];
        self.labelOpen = NO;
    }
    return self;
}

- (void)dealloc {
    CYLog(@"");
}

- (UITextField *)bottomLabel {
    if (!_bottomLabel) {
        UITextField *bottomLabel = [UITextField new];
        bottomLabel.font = [UIFont systemFontOfSize:12];
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        bottomLabel.placeholder = [self labelHolder];
        bottomLabel.delegate = self;
        _bottomLabel = bottomLabel;
    }
    return _bottomLabel;
}

- (void)setCardTextColor:(UIColor *)cardTextColor {
    _cardTextColor = cardTextColor;
    if (!self.bottomLabel) return;
    self.bottomLabel.textColor = tryValue(_cardTextColor, [UIColor darkGrayColor]);
}

- (void)setCardTintColor:(UIColor *)cardTintColor {
    _cardTintColor = cardTintColor;
    if (!self.bottomLabel) return;
    self.bottomLabel.tintColor = tryValue(_cardTintColor, [UIColor darkGrayColor]);
}

- (void)setCardShadowColor:(UIColor *)cardShadowColor {
    _cardShadowColor = cardShadowColor;
    self.layer.shadowColor = tryValue(_cardShadowColor, [UIColor blackColor]).CGColor;
}

- (void)setCardBackgroundColor:(UIColor *)cardBackgroundColor {
    _cardBackgroundColor = cardBackgroundColor;
    self.backgroundColor = tryValue(_cardBackgroundColor, [UIColor whiteColor]);
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    self.bottomLabel.userInteractionEnabled = _editable;
    if (_editable) {
        if (!tapGesture) {
            // Init of Gesture Recognizer
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(frameTapped:)];
        }
        if (tapGesture) {
            [self addGestureRecognizer:tapGesture];
        }
    } else {
        if (tapGesture) {
            [self removeGestureRecognizer:tapGesture];
        }
    }
}

- (void)setLabelText:(NSString *)labelText {
    _labelText = labelText;
    if ([labelText isEmpty]) {
        [self toggleBottomLabelView:NO animated:NO];
    } else {
        self.bottomLabel.text = _labelText;
        [self toggleBottomLabelView:YES animated:NO];
    }
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
        UIImageView *cropBtn = [[UIImageView alloc] initWithFrame:CGRectMake(kImageFrameBtnBorderWidth + (kImageFrameBtnWidth + kImageFrameBtnInterval) * 2, kImageFrameBtnBorderWidth, kImageFrameBtnWidth, kImageFrameBtnWidth)];
        cropBtn.backgroundColor = [UIColor clearColor];
        cropBtn.image = [UIImage imageNamed:@"42-unbrella-insert"];
        cropBtn.alpha = 0;
        cropBtn.hidden = YES;
        cropBtn.userInteractionEnabled = YES;
        UITapGestureRecognizer *cropGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cropGestureRecognized:)];
        [cropBtn addGestureRecognizer:cropGesture];
        _cropBtn = cropBtn;
    }
    return _cropBtn;
}

- (void)cropGestureRecognized:(UIGestureRecognizer *)sender {
    [self frameTapped:sender];
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageFrameShouldCropped:)]) {
        [self.delegate imageFrameShouldCropped:self];
    }
}

- (UIImageView *)editBtn {
    if (!_editBtn) {
        UIImageView *editBtn = [[UIImageView alloc] initWithFrame:CGRectMake(kImageFrameBtnBorderWidth + kImageFrameBtnWidth + kImageFrameBtnInterval, kImageFrameBtnBorderWidth, kImageFrameBtnWidth, kImageFrameBtnWidth)];
        editBtn.backgroundColor = [UIColor clearColor];
        editBtn.image = [UIImage imageNamed:@"43-unbrella-edit"];
        editBtn.alpha = 0;
        editBtn.hidden = YES;
        editBtn.userInteractionEnabled = YES;
        UITapGestureRecognizer *editGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editGestureRecognized:)];
        [editBtn addGestureRecognizer:editGesture];
        _editBtn = editBtn;
    }
    return _editBtn;
}

- (void)editGestureRecognized:(UIGestureRecognizer *)sender {
    [self frameTapped:sender];
    if (!self.labelOpen) {
        [self toggleBottomLabelView:YES animated:YES];
    } else {
        [self toggleBottomLabelView:NO animated:YES];
    }
}

- (UIImageView *)deleteBtn {
    if (!_deleteBtn) {
        UIImageView *deleteBtn = [[UIImageView alloc] initWithFrame:CGRectMake(kImageFrameBtnBorderWidth, kImageFrameBtnBorderWidth, kImageFrameBtnWidth, kImageFrameBtnWidth)];
        deleteBtn.backgroundColor = [UIColor clearColor];
        deleteBtn.image = [UIImage imageNamed:@"41-unbrella-delete"];
        deleteBtn.alpha = 0;
        deleteBtn.hidden = YES;
        deleteBtn.userInteractionEnabled = YES;
        UITapGestureRecognizer *deleteGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteGestureRecognized:)];
        [deleteBtn addGestureRecognizer:deleteGesture];
        _deleteBtn = deleteBtn;
    }
    return _deleteBtn;
}

- (void)deleteGestureRecognized:(UIGestureRecognizer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageFrameShouldDeleted:animated:)]) {
        [self.delegate imageFrameShouldDeleted:self animated:YES];
    }
}

- (void)setCenterImage:(UIImage *)centerImage {
    // Remove Old Image View
    if (self.centerImageView) {
        [self.centerImageView removeFromSuperview];
    }
    // Calculate Image Scaled Height
    CGFloat scaleValue = 0;
    CGFloat height = 0;
    // Set New Image View
    UIImageView *centerImageView = nil;
    if (centerImage.size.width > self.frame.size.width) {
        scaleValue = self.frame.size.width / centerImage.size.width;
        height = ceil(((float)centerImage.size.height * scaleValue) / self.standardLineHeight) * self.standardLineHeight;
        centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - kImageFrameBorderWidth * 2, height)];
        centerImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        if (centerImage.size.height < kImageFrameMinHeight) {
            height = kImageFrameMinHeight; // 最小高度
        } else {
            height = ceil((float)centerImage.size.height / self.standardLineHeight) * self.standardLineHeight;
        }
        centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - kImageFrameBorderWidth * 2, height)];
        centerImageView.contentMode = UIViewContentModeCenter;
    }
    centerImageView.tintColor = [UIColor whiteColor];
    centerImageView.clipsToBounds = YES;
    centerImageView.userInteractionEnabled = YES;
    centerImageView.image = centerImage;
    centerImageView.nl_hasGaussian = NO;
    // Reset Frame View
    if (_labelOpen) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, centerImageView.frame.size.height + kImageFrameBorderWidth * 2 + kImageFrameLabelHeight);
        centerImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - kImageFrameLabelHeight);
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, centerImageView.frame.size.height + kImageFrameBorderWidth * 2);
        centerImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    }
    _centerImage = centerImage;
    _centerImageView = centerImageView;
    [self addSubview:centerImageView];
    [self sendSubviewToBack:centerImageView];
    if (self.centerBtn) {
        [centerImageView addSubview:self.centerBtn];
    }
}

- (void)frameTapped:(id)sender {
        self.optionsOpen = !self.optionsOpen;
        if (self.bottomLabel && [self.bottomLabel isFirstResponder]) {
            [self.bottomLabel resignFirstResponder];
        }
        if (self.centerImageView) {
            if (self.optionsOpen) {
                [self.centerImageView setHasGaussian:YES];
                for (UIImageView *btn in self.optionButtons) {
                    btn.hidden = NO;
                }
                __weak typeof(self) weakSelf = self;
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     for (UIImageView *btn in weakSelf.optionButtons) {
                                         btn.alpha = 1.0;
                                     }
                                 } completion:nil];
            } else {
                [self.centerImageView setHasGaussian:NO];
                __weak typeof(self) weakSelf = self;
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     for (UIImageView *btn in weakSelf.optionButtons) {
                                         btn.alpha = 0.0;
                                     }
                                 } completion:^(BOOL finished) {
                                     if (finished) {
                                         for (UIImageView *btn in weakSelf.optionButtons) {
                                             btn.hidden = YES;
                                         }
                                     }
                                 }];
            }
        }
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageFrameTapped:)]) {
        [self.delegate imageFrameTapped:self];
    }
}

- (void)toggleBottomLabelView:(BOOL)on
                     animated:(BOOL)animated {
    if (on && !self.labelOpen) {
        self.labelOpen = YES;
        CGFloat targetHeight = self.frame.size.height + kImageFrameLabelHeight;
        // Reset Label View
        self.bottomLabel.frame = CGRectMake(kImageFrameBorderWidth, targetHeight - kImageFrameBorderWidth - kImageFrameLabelTextHeight, self.frame.size.width - kImageFrameBorderWidth * 2, kImageFrameLabelTextHeight);
        if (animated) {
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.2
                             animations:^{
                                 [weakSelf setHeight:targetHeight];
                             } completion:^(BOOL finished) {
                                 __strong typeof(self) strongSelf = weakSelf;
                                 if (finished) {
                                     [strongSelf addSubview:strongSelf.bottomLabel];
                                     if (![strongSelf.bottomLabel isFirstResponder]) {
                                         [strongSelf.bottomLabel becomeFirstResponder];
                                     }
                                 }
                             }];
        } else {
            [self setHeight:targetHeight];
            [self addSubview:self.bottomLabel];
            if (![self.bottomLabel isFirstResponder]) {
                [self.bottomLabel becomeFirstResponder];
            }
        }
    } else if (!on && self.labelOpen) {
        self.labelOpen = NO;
        if ([self.bottomLabel isFirstResponder]) {
            [self.bottomLabel resignFirstResponder];
        }
        CGFloat targetHeight = self.height - kImageFrameLabelHeight;
        [self.bottomLabel removeFromSuperview];
        if (animated) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 [self setHeight:targetHeight];
                             } completion:nil];
        } else {
            [self setHeight:targetHeight];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    if ([textField.text isEmpty]) {
        [self toggleBottomLabelView:NO animated:YES];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageFrameDidBeginEditing:)]) {
        [self.delegate imageFrameDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.labelText = textField.text;
    if ([textField.text isEmpty]) {
        [self toggleBottomLabelView:NO animated:YES];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageFrameDidEndEditing:)]) {
        [self.delegate imageFrameDidEndEditing:self];
    }
}

#pragma mark - PECropViewControllerDelegate

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
    if (controller) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageFrameShouldReplaced:by:userinfo:)]) {
            [self.delegate imageFrameShouldReplaced:self by:croppedImage userinfo:self.userinfo];
        }
    }
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
    if (controller) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
