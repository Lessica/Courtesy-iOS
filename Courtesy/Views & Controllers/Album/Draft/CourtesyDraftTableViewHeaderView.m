//
//  CourtesyDraftTableViewHeaderView.m
//  Courtesy
//
//  Created by Zheng on 4/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyDraftTableViewHeaderView.h"

@interface CourtesyDraftTableViewHeaderView ()

@end

@implementation CourtesyDraftTableViewHeaderView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGColorRef borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
        self.layer.borderColor = borderColor;
        self.layer.borderWidth = 0.6;
        self.tintColor = [UIColor lightGrayColor];
        self.backgroundColor = [UIColor whiteColor];
        
        /* Init of avatar view */
        UIImageView *circleAvatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
        circleAvatarView.layer.masksToBounds = YES;
        circleAvatarView.layer.cornerRadius = circleAvatarView.frame.size.width / 2;
        self.circleAvatarView = circleAvatarView;
        [self addSubview:circleAvatarView];
        
        /* Init of nick label */
        UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 42)];
        nickLabel.font = [UIFont systemFontOfSize:20.0];
        nickLabel.textColor = [UIColor blackColor];
        self.nickLabel = nickLabel;
        [self addSubview:nickLabel];
        
        /* Init of introduction label */
        UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 36)];
        introLabel.lineBreakMode = NSLineBreakByWordWrapping;
        introLabel.numberOfLines = 2;
        introLabel.font = [UIFont systemFontOfSize:15.0];
        introLabel.textColor = [UIColor grayColor];
        self.introLabel = introLabel;
        [self addSubview:introLabel];
        
        /* Init of count label */
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 32)];
        countLabel.numberOfLines = 1;
        countLabel.font = [UIFont systemFontOfSize:14.0];
        countLabel.textColor = [UIColor lightGrayColor];
        self.countLabel = countLabel;
        [self addSubview:countLabel];
        
        [self updateAccountInfo];
    }
    return self;
}

- (void)updateConstraints {
    [_circleAvatarView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(16);
        make.top.equalTo(self.mas_top).with.offset(16);
        make.width.equalTo(@42);
        make.height.equalTo(@42);
    }];
    
    [_nickLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_circleAvatarView.mas_right).with.offset(16);
        make.top.equalTo(self.mas_top).with.offset(16);
        make.trailing.equalTo(self.mas_trailing);
        make.height.equalTo(@42);
    }];
    
    [_introLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(16);
        make.top.equalTo(_circleAvatarView.mas_bottom).with.offset(12);
        make.trailing.equalTo(self.mas_trailing);
        make.height.equalTo(@36);
    }];
    
    [_countLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(16);
        make.bottom.equalTo(self.mas_bottom).with.offset(-8);
        make.trailing.equalTo(self.mas_trailing);
        make.height.equalTo(@32);
    }];
    
    [_editButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-20);
        make.top.equalTo(self.mas_top).with.offset(20);
        make.width.equalTo(@32);
        make.height.equalTo(@32);
    }];
    
    [super updateConstraints];
}

- (void)setCardCount:(NSUInteger)cardCount {
    if (cardCount == 0)
    {
        [_countLabel setText:@"无卡片"];
    }
    else
    {
        [_countLabel setText:[NSString stringWithFormat:@"%lu 张卡片", (unsigned long)cardCount]];
    }
}

- (void)updateAccountInfo {
    if ([sharedSettings hasLogin]) {
        if (!kProfile.avatar) {
            [_circleAvatarView setImage:[UIImage imageNamed:@"3-avatar"]];
        } else {
            [_circleAvatarView setImageURL:kProfile.avatar_url_small];
        }
        _nickLabel.text = kProfile.nick;
        _introLabel.text = kProfile.introduction;
        [self setCardCount:_cardCount];
    } else {
        [_nickLabel setText:@"未登录"];
        [_introLabel setText:@"登录以查看「我的卡片」"];
        [_circleAvatarView setImage:[UIImage imageNamed:@"3-avatar"]];
    }
}

@end
