//
//  ParallaxHeaderView.h
//  ParallaxTableViewHeader
//
//  Created by Zheng on 4/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParallaxHeaderView : UIView
@property (nonatomic, strong) IBOutlet UILabel *headerTitleLabel;
@property (nonatomic, strong) UIImage *headerImage;
@property (nonatomic, strong) NSURL *headerImageURL;

+ (id)parallaxHeaderViewWithImage:(UIImage *)image forSize:(CGSize)headerSize;
+ (id)parallaxHeaderViewWithSubView:(UIView *)subView;
- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset;
- (void)refreshBlurViewForNewImage;
@end
