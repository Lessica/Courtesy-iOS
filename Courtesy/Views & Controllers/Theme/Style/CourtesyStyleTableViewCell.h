//
//  CourtesyStyleTableViewCell.h
//  Courtesy
//
//  Created by Zheng on 5/5/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourtesyStyleTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImage *styleImage;
@property (nonatomic, strong) UIImage *styleCheckmark;
@property (nonatomic, strong) UIFont *styleFont;

- (void)setStyleSelected:(BOOL)selected;

@end
