//
//  CourtesyDraftTableViewCell.m
//  Courtesy
//
//  Created by Zheng on 3/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyDraftTableViewCell.h"
#import "NSDate+Compare.h"

@interface CourtesyDraftTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *briefTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;

@end

@implementation CourtesyDraftTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.mainTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.briefTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.mainTitleLabel.numberOfLines = 1;
    self.briefTitleLabel.numberOfLines = 1;
}

- (void)setCard:(CourtesyCardModel *)card {
    _card = card;
    self.mainTitleLabel.text = card.card_data.mainTitle;
    self.briefTitleLabel.text = card.card_data.briefTitle;
    self.dateLabel.text = [NSString stringWithFormat:@"%@ | 字数 %lu", [[NSDate dateWithTimeIntervalSince1970:card.modified_at] compareCurrentTime], (unsigned long)card.card_data.content.length];
    if (card.card_data.smallThumbnailURL) {
        [self.imagePreview setImageWithURL:card.card_data.smallThumbnailURL
                               placeholder:nil
                                   options:YYWebImageOptionSetImageWithFadeAnimation
                                   manager:nil
                                  progress:nil
                                 transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                     return [image imageByResizeToSize:CGSizeMake(self.frame.size.height, self.frame.size.height) // Square ones
                                                           contentMode:UIViewContentModeScaleAspectFit];
                                 }
                                completion:nil];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
