//
//  CourtesyLongImageTableViewCell.m
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyLongImageTableViewCell.h"

@interface CourtesyLongImageTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@end

@implementation CourtesyLongImageTableViewCell

- (void)setPreviewImage:(UIImage *)previewImage {
    _previewImage = previewImage;
    self.previewImageView.image = previewImage;
}

@end
