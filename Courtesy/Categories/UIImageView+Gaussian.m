//
//  UIImageView+Gaussian.m
//  Courtesy
//
//  Created by Zheng on 3/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "UIImageView+Gaussian.h"

@implementation UIImageView (Gaussian)
@dynamic nl_hasGaussian;
@dynamic nl_gaussianView;

- (void)setHasGaussian:(BOOL)hasGaussian {
    self.nl_hasGaussian = hasGaussian;
    if (hasGaussian) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        if (!self.nl_gaussianView) {
            self.nl_gaussianView = [UIVisualEffectView new];
            self.nl_gaussianView.frame = self.bounds;
        }
        [self addSubview:self.nl_gaussianView];
        [UIView animateWithDuration:0.2
                         animations:^() {
                             self.nl_gaussianView.effect = blurEffect;
                         } completion:^(BOOL finished) {
                             
                         }];
    } else {
        [UIView animateWithDuration:0.2
                         animations:^() {
                             self.nl_gaussianView.effect = nil;
                         } completion:^(BOOL finished) {
                             if (finished) [self.nl_gaussianView removeFromSuperview];
                         }];
    }
}

@end
