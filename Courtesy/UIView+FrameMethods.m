//
//  UIView+FrameMethods.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "UIView+FrameMethods.h"

@implementation UIView (FrameMethods)

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

@end
