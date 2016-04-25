//
//  CourtesyDraftTableViewHeaderView.h
//  Courtesy
//
//  Created by Zheng on 4/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourtesyDraftTableViewHeaderView : UIView
@property (nonatomic, strong) UIImageView *circleAvatarView;
@property (nonatomic, strong) UILabel *nickLabel;
@property (nonatomic, strong) UILabel *introLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) NSUInteger cardCount;

@property (nonatomic, strong) UIButton *editButton;

- (void)updateAccountInfo;

@end
