//
//  CourtesyCardAuthorHeader.m
//  Courtesy
//
//  Created by Zheng on 4/25/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardAuthorHeader.h"

@interface CourtesyCardAuthorHeader ()
@property (strong, nonatomic) UIView *avatarContainerView;

@end

@implementation CourtesyCardAuthorHeader
- (void)prepare
{
    [super prepare];
    
    self.mj_h = 100;
    
    UIView *avatarContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 65, 65)];
    avatarContainerView.backgroundColor = [UIColor black50PercentColor];
    avatarContainerView.layer.masksToBounds = YES;
    avatarContainerView.layer.cornerRadius = avatarContainerView.frame.size.width / 2;
    [self addSubview:avatarContainerView];
    self.avatarContainerView = avatarContainerView;
    
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2;
    [avatarContainerView addSubview:avatarImageView];
    self.avatarImageView = avatarImageView;
    
    UILabel *nickLabelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 24)];
    nickLabelView.textAlignment = NSTextAlignmentCenter;
    nickLabelView.numberOfLines = 1;
    nickLabelView.lineBreakMode = NSLineBreakByTruncatingTail;
    nickLabelView.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:nickLabelView];
    self.nickLabelView = nickLabelView;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    self.avatarContainerView.center = CGPointMake(self.mj_w * 0.5, 35);
    self.avatarImageView.center = CGPointMake(self.avatarContainerView.frame.size.width / 2, self.avatarContainerView.frame.size.height / 2);
    self.nickLabelView.bounds = CGRectMake(0, 0, self.mj_w, 24);
    self.nickLabelView.center = CGPointMake(self.avatarContainerView.center.x, self.avatarContainerView.center.y + 48);
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
}

- (void)setState:(MJRefreshState)state
{

}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
}

@end
