//
//  CourtesyCardLocationTableViewCell.m
//  Courtesy
//
//  Created by Zheng on 6/17/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardLocationTableViewCell.h"

@implementation CourtesyCardLocationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.selectionStyle                = UITableViewCellSelectionStyleNone;
        self.textLabel.font                = [UIFont systemFontOfSize:16];
        self.detailTextLabel.font          = [UIFont systemFontOfSize:12];
        self.detailTextLabel.textColor     = [UIColor grayColor];
    }
    return self;
}

@end
