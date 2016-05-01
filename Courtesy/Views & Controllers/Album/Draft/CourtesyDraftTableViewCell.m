//
//  CourtesyDraftTableViewCell.m
//  Courtesy
//
//  Created by Zheng on 3/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyDraftTableViewCell.h"
#import "NSDate+Compare.h"
#import "FCFileManager.h"
#import "CourtesyPaddingLabel.h"
#import "POP.h"

/* 这玩意会造成离屏渲染 = =! */
//#import "ColorProgressView.h"
//#import "ProgressColor+Colors.h"

@interface CourtesyDraftTableViewCell ()
//@property (weak, nonatomic) ColorProgressView *publishProgressView;

@property (strong, nonatomic) CourtesyCardPublishTask *targetTask;
@property (weak, nonatomic) IBOutlet CourtesyPaddingLabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *briefTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIProgressView *publishProgressView;
@property (weak, nonatomic) IBOutlet UIImageView *smallAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *smallNickLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrcImageView;

@end

@implementation CourtesyDraftTableViewCell

#pragma mark - UI Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    self.mainTitleLabel.font = [UIFont fontWithName:@"Heiti SC" size:20.0f];
    self.mainTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.mainTitleLabel.numberOfLines = 1;
    
    self.briefTitleLabel.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
    self.briefTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.briefTitleLabel.numberOfLines = 2;
    
    self.smallNickLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.smallNickLabel.numberOfLines = 1;
    
    self.imagePreview.layer.masksToBounds = YES;
    self.imagePreview.layer.cornerRadius = 3.0;
    
    self.smallAvatarView.layer.cornerRadius = self.smallAvatarView.frame.size.width / 2;

//    ColorProgressView *publishProgressView = [[ColorProgressView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 2)];
//    publishProgressView.color = [ProgressColor redGradientColor];
//    [publishProgressView startAnimation];
//    [self.contentView addSubview:publishProgressView];
//    self.publishProgressView = publishProgressView;
//    
//    [_publishProgressView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(self.contentView.mas_width);
//        make.height.equalTo(@2);
//        make.top.equalTo(self.contentView.mas_top);
//        make.left.equalTo(self.contentView.mas_left);
//    }];
}

#pragma mark - Data Updating

- (void)setCard:(CourtesyCardModel *)card {
    _card = card;
    _targetTask = nil;
    [self.publishProgressView setProgress:0.0 animated:NO];
    [self setupStatus];
}

- (void)setupStatus {
    if (!_card) return;
    
    // 刷新文字数据
    _mainTitleLabel.text = _card.local_template.mainTitle;
    _briefTitleLabel.text = _card.local_template.briefTitle;
    _smallAvatarView.imageURL = _card.author.profile.avatar_url_small;
    _smallNickLabel.text = _card.author.profile.nick;
    
    // 刷新缩略图及小标识
    NSURL *thumbnailURL = _card.local_template.smallThumbnailURL;
    if (thumbnailURL) {
        [_imagePreview setImageWithURL:thumbnailURL
                                   options:YYWebImageOptionSetImageWithFadeAnimation];
    } else {
        [_imagePreview setImage:nil]; // 清除缩略图
    }
    if (_card.is_banned) {
        _mainTitleLabel.edgeInsets = UIEdgeInsetsMake(0, 28, 0, 0);
        _qrcImageView.image = [UIImage imageNamed:@"lock-small"];
        _qrcImageView.hidden = NO;
    } else if (_card.qr_id || _card.local_template.qrcode) {
        _mainTitleLabel.edgeInsets = UIEdgeInsetsMake(0, 28, 0, 0);
        _qrcImageView.image = [UIImage imageNamed:@"qrc-small"];
        _qrcImageView.hidden = NO;
    } else {
        _mainTitleLabel.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _qrcImageView.hidden = YES;
    }
    
    // 刷新文字颜色
    [self resetLabelColor];
    
    // 获取卡片任务
    CourtesyCardPublishQueue *queue = [CourtesyCardPublishQueue sharedQueue];
    CourtesyCardPublishTask *task = [queue publishTaskInPublishQueueWithCard:_card];
    if (task) {
        [self setPublishProgressWithStatus:task.status andProgress:0 andError:nil];
        _targetTask = task;
    } else {
        _smallTimeLabel.text = [[NSDate dateWithTimeIntervalSince1970:self.card.modified_at] compareCurrentTime];
    }
}

- (void)resetLabelColor {
    if (self.card) {
        if (self.card.is_banned) {
            self.mainTitleLabel.textColor = [UIColor magicColor];
        } else {
            self.mainTitleLabel.textColor = [UIColor blackColor];
        }
    }
}

#pragma mark - Status Notification

- (void)notifyUpdateStatus {
    [self setupStatus];
}

- (void)notifyUpdateProgress {
    [self setPublishProgressWithStatus:_targetTask.status andProgress:_targetTask.currentProgress andError:_targetTask.error];
}

- (void)setPublishProgressWithStatus:(CourtesyCardPublishTaskStatus)status andProgress:(float)progress andError:(NSError *)err {
    if (status == CourtesyCardPublishTaskStatusProcessing) {
        if (_targetTask.totalBytes != 0) {
            [self.publishProgressView setProgress:_targetTask.currentProgress animated:YES];
            self.smallTimeLabel.text = [NSString stringWithFormat:@"正在同步 - %@ / %@",
                                        [FCFileManager sizeFormatted:[NSNumber numberWithFloat:_targetTask.logicalBytes]],
                                        [FCFileManager sizeFormatted:[NSNumber numberWithFloat:(_targetTask.totalBytes - self.targetTask.skippedBytes)]]];
            return;
        }
        self.smallTimeLabel.text = @"正在同步";
    } else if (status == CourtesyCardPublishTaskStatusNone) {
        self.smallTimeLabel.text = @"等待同步";
    } else if (status == CourtesyCardPublishTaskStatusReady) {
        self.smallTimeLabel.text = @"准备同步";
    } else if (status == CourtesyCardPublishTaskStatusCanceled) {
        if (err) {
            self.smallTimeLabel.text = [NSString stringWithFormat:@"同步失败 - %@", [err localizedDescription]];
        } else {
            self.smallTimeLabel.text = [NSString stringWithFormat:@"取消同步"];
        }
        [self resetLabelColor];
    } else if (status == CourtesyCardPublishTaskStatusDone) {
        self.smallTimeLabel.text = [NSString stringWithFormat:@"同步成功"];
        [self resetLabelColor];
    } else if (status == CourtesyCardPublishTaskStatusPending) {
        self.smallTimeLabel.text = @"建立连接";
    } else if (status == CourtesyCardPublishTaskStatusAcknowledging) {
        self.smallTimeLabel.text = [NSString stringWithFormat:@"完成同步"];
    }
    [self.publishProgressView setProgress:0.0];
}

#pragma mark - Animation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    if (self.highlighted) {
        
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration           = 0.1f;
        scaleAnimation.toValue            = [NSValue valueWithCGPoint:CGPointMake(0.95, 0.95)];
        [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
    } else {
        
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.toValue             = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity            = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.springBounciness    = 20.f;
        [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    }
}

@end
