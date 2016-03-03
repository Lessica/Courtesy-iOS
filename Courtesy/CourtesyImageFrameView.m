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
        // Init of Gesture Recognizer
        UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *g) {
            if (_centerImageView) {
                if (_centerImageView.nl_hasGaussian) {
                    [_centerImageView setHasGaussian:NO];
                } else {
                    [_centerImageView setHasGaussian:YES];
                }
            }
        }];
        [self addGestureRecognizer:g];
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
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 12, height)];
        _centerImageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        height = _centerImage.size.height;
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 12, height)];
        _centerImageView.contentMode = UIViewContentModeCenter;
    }
    // Reset Frame View
    self.frame = CGRectMake(0, 0, self.frame.size.width, _centerImageView.height + 12);
    _centerImageView.clipsToBounds = YES;
    _centerImageView.userInteractionEnabled = YES;
    _centerImageView.image = _centerImage;
    _centerImageView.center = self.center;
    _centerImageView.nl_hasGaussian = NO;
    [self addSubview:_centerImageView];
}

@end
