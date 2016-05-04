//
//  CourtesyLongImageTableViewCell.m
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyLongImageTableViewCell.h"

@interface CourtesyLongImageTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (strong, nonatomic) UIImageView *maskImageView;

@end

@implementation CourtesyLongImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_previewImageView addSubview:self.maskImageView];
}

- (UIImageView *)maskImageView {
    if (!_maskImageView) {
        _maskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        _maskImageView.image = [UIImage imageNamed:@"ll-checkmark"];
        _maskImageView.alpha = 0.85;
        _maskImageView.hidden = YES;
    }
    return _maskImageView;
}

- (void)setPreviewImage:(UIImage *)previewImage {
    _previewImage = previewImage;
    self.previewImageView.image = previewImage;
}

- (void)setPreviewStyleSelected:(BOOL)selected {
    if (selected) {
        _maskImageView.hidden = NO;
        _maskImageView.center = CGPointMake(_previewImageView.frame.size.width / 2, _previewImageView.frame.size.height / 2);
    } else {
        _maskImageView.hidden = YES;
    }
}

@end
