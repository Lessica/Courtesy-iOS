//
//  CourtesyMyOutboxEmptyTipTableViewCell.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyMyOutboxEmptyTipTableViewCell.h"

@interface CourtesyMyOutboxEmptyTipTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabelView;

@end

@implementation CourtesyMyOutboxEmptyTipTableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Accessors

#pragma Title

- (NSString *)titleText {
    return self.tipsLabelView.text;
}

- (void)setTitleText:(NSString *)title {
    self.tipsLabelView.text = title;
}

#pragma Icon

- (UIImage *)iconImage {
    return self.iconImageView.image;
}

- (void)setIconImage:(UIImage *)icon {
    self.iconImageView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
