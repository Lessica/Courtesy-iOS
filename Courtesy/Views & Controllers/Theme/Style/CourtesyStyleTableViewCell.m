//
//  CourtesyStyleTableViewCell.m
//  Courtesy
//
//  Created by Zheng on 5/5/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyStyleTableViewCell.h"
#import "CourtesyPaddingLabel.h"
#import "POP.h"

@interface CourtesyStyleTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *styleImageView;
@property (weak, nonatomic) IBOutlet CourtesyPaddingLabel *styleTitleLabel;
@property (strong, nonatomic) UIImageView *maskImageView;

@end

@implementation CourtesyStyleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_styleImageView addSubview:self.maskImageView];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (self.highlighted) {
        
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration           = 0.1f;
        scaleAnimation.toValue            = [NSValue valueWithCGPoint:CGPointMake(0.85, 0.85)];
        [self.maskImageView pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    } else {
        
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.toValue             = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity            = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.springBounciness    = 20.f;
        [self.maskImageView pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    }
}

- (UIImageView *)maskImageView {
    if (!_maskImageView) {
        _maskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        _maskImageView.alpha = 0.95;
        _maskImageView.hidden = YES;
    }
    return _maskImageView;
}

- (void)setStyleImage:(UIImage *)styleImage {
    _styleImage = styleImage;
    self.styleImageView.image = styleImage;
}

- (void)setStyleCheckmark:(UIImage *)styleCheckmark {
    _styleCheckmark = styleCheckmark;
    self.maskImageView.image = styleCheckmark;
}

- (void)setStyleFont:(UIFont *)styleFont {
    _styleFont = styleFont;
    self.styleTitleLabel.font = styleFont;
}

- (void)setStyleSelected:(BOOL)selected {
    if (selected) {
        _styleTitleLabel.edgeInsets = UIEdgeInsetsMake(0, _styleCheckmark.size.width * 2, 0, 0);
        _maskImageView.hidden = NO;
        _maskImageView.center = CGPointMake(32 + _maskImageView.frame.size.width / 2, _styleImageView.frame.size.height / 2);
    } else {
        _styleTitleLabel.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _maskImageView.hidden = YES;
    }
}

@end
