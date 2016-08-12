//
//  CourtesyFontSheetViewHeader.m
//  Courtesy
//
//  Created by Zheng on 8/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyFontSheetViewHeader.h"

@interface CourtesyFontSheetViewHeader ()
@property (weak, nonatomic) UIActivityIndicatorView *loading;

@end

@implementation CourtesyFontSheetViewHeader

- (void)prepare
{
    [super prepare];
    
    self.mj_h = 32;
    
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [self addSubview:loading];
    self.loading = loading;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    self.loading.center = CGPointMake(self.mj_w / 2, self.mj_h / 2);
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

@end
