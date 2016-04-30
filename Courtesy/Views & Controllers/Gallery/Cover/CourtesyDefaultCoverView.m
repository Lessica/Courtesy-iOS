//
//  CourtesyDefaultCoverView.m
//  Courtesy
//
//  Created by Zheng on 4/30/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyDefaultCoverView.h"

@interface CourtesyDefaultCoverView ()
@property (nonatomic, strong) YYAnimatedImageView *coverImageView;
@property (nonatomic, strong) YYLabel *coverTitleView;

@end

@implementation CourtesyDefaultCoverView

- (void)setup {
    [super setup];
    YYAnimatedImageView *coverImageView = [[YYAnimatedImageView alloc] initWithFrame:self.bounds];
    coverImageView.layer.cornerRadius = 10.0;
    coverImageView.clipsToBounds = YES;
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [coverImageView setImage:[[UIImage imageNamed:@"default-cover"] imageByBlurRadius:3.0
                                                                            tintColor:[UIColor colorWithWhite:0.11 alpha:0.25]
                                                                             tintMode:kCGBlendModeNormal
                                                                           saturation:1.2
                                                                            maskImage:nil]];
    [self addSubview:coverImageView];
    self.coverImageView = coverImageView;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

@end
