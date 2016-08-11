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
@property (weak, nonatomic) UIActivityIndicatorView *loading;

@end

@implementation CourtesyCardAuthorHeader
- (void)prepare
{
    [super prepare];
    
    self.mj_h = 128;
    
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
    
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loading.center = avatarImageView.center;
    [avatarContainerView addSubview:loading];
    self.loading = loading;
    
    UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 24)];
    nickLabel.textAlignment = NSTextAlignmentCenter;
    nickLabel.numberOfLines = 1;
    nickLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    nickLabel.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:nickLabel];
    self.nickLabel = nickLabel;
    
    UILabel *viewCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 24)];
    viewCountLabel.textAlignment = NSTextAlignmentCenter;
    viewCountLabel.numberOfLines = 1;
    viewCountLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    viewCountLabel.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:viewCountLabel];
    self.viewCountLabel = viewCountLabel;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    self.avatarContainerView.center = CGPointMake(self.mj_w * 0.5, 35);
    self.avatarImageView.center = CGPointMake(self.avatarContainerView.frame.size.width / 2, self.avatarContainerView.frame.size.height / 2);
    self.nickLabel.bounds = CGRectMake(0, 0, self.mj_w, 24);
    self.nickLabel.center = CGPointMake(self.avatarContainerView.center.x, self.avatarContainerView.center.y + 48);
    self.viewCountLabel.bounds = CGRectMake(0, 0, self.mj_w, 24);
    self.viewCountLabel.center = CGPointMake(self.nickLabel.center.x, self.nickLabel.center.y + 24);
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
    MJRefreshCheckState;
    switch (state) {
        case MJRefreshStateIdle:
            [self.loading stopAnimating];
            break;
        case MJRefreshStatePulling:
            [self.loading stopAnimating];
            break;
        case MJRefreshStateRefreshing:
            [self.loading startAnimating];
            break;
        default:
            break;
    }
}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
}

- (void)setViewCount:(NSUInteger)count {
    if (count != 0) {
        [_viewCountLabel setText:[NSString stringWithFormat:@"%lu 次阅读", (unsigned long)count]];
    } else {
        [_viewCountLabel setText:@"新卡片"];
    }
}

@end
