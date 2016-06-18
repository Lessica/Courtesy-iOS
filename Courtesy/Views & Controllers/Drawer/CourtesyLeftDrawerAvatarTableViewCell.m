//
//  CourtesyLeftDrawerAvatarTableViewCell.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyLeftDrawerAvatarTableViewCell.h"

@interface CourtesyLeftDrawerAvatarTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabelView;

@end

@implementation CourtesyLeftDrawerAvatarTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Accessors

#pragma Title

- (NSString *)nickLabelText {
    return self.nickLabelView.text;
}

- (void)setNickLabelText:(NSString *)nick {
    self.nickLabelView.text = nick;
}

#pragma Icon

- (UIImage *)avatarImage {
    return self.avatarImageView.image;
}

- (void)setAvatarImage:(UIImage *)avatar {
    self.avatarImageView.image = [[avatar imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] imageByRoundCornerRadius:avatar.size.height / 2
                                                                                                                  borderWidth:0
                                                                                                                  borderColor:nil];
}

#pragma mark - Remote

- (void)loadRemoteImage {
    [_avatarImageView setImageWithURL:kProfile.avatar_url_large
                              options:YYWebImageOptionShowNetworkActivity | YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation];
}

@end
