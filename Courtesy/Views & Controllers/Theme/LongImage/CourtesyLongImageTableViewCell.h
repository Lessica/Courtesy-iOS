//
//  CourtesyLongImageTableViewCell.h
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourtesyLongImageTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) UIImage *previewCheckmark;

- (void)setPreviewStyleSelected:(BOOL)selected;

@end
