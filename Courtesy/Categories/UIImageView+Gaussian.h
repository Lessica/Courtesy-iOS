//
//  UIImageView+Gaussian.h
//  Courtesy
//
//  Created by Zheng on 3/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

@interface UIImageView (Gaussian)

@property (nonatomic, assign) BOOL nl_hasGaussian;
@property (nonatomic, strong) UIVisualEffectView *nl_gaussianView;

- (void)setHasGaussian:(BOOL)hasGaussian;

@end
