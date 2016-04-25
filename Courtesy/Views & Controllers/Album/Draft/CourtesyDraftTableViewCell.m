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
#import "CourtesyCardPublishTask.h"
#import "CourtesyCardPublishQueue.h"
#import "CourtesyPaddingLabel.h"

@interface CourtesyDraftTableViewCell ()
@property (weak, nonatomic) IBOutlet CourtesyPaddingLabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *briefTitleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIProgressView *publishProgressView;
@property (strong, nonatomic) CourtesyCardPublishTask *targetTask;
@property (weak, nonatomic) IBOutlet UIImageView *smallAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *smallNickLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrcImageView;

@end

@implementation CourtesyDraftTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.mainTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.briefTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.smallNickLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.mainTitleLabel.numberOfLines = 1;
    self.briefTitleLabel.numberOfLines = 2;
    self.smallNickLabel.numberOfLines = 1;
    self.imagePreview.layer.masksToBounds = YES;
    self.imagePreview.layer.cornerRadius = 3.0;
    self.smallAvatarView.layer.cornerRadius = self.smallAvatarView.frame.size.width / 2;
    self.targetTask = nil;
}

- (void)setCard:(CourtesyCardModel *)card {
    _card = card;
    self.mainTitleLabel.text = card.local_template.mainTitle;
    self.briefTitleLabel.text = card.local_template.briefTitle;
    self.smallAvatarView.imageURL = card.author.profile.avatar_url_small;
    self.smallNickLabel.text = card.author.profile.nick;
    NSURL *thumbnailURL = card.local_template.smallThumbnailURL;
    if (thumbnailURL) {
        [self.imagePreview setImageWithURL:thumbnailURL
                                   options:YYWebImageOptionSetImageWithFadeAnimation];
    } else {
        [self.imagePreview setImage:nil]; // 清除缩略图
    }
    if (card.qr_id) {
        self.mainTitleLabel.edgeInsets = UIEdgeInsetsMake(0, 28, 0, 0);
        self.qrcImageView.hidden = NO;
    } else {
        self.qrcImageView.hidden = YES;
    }
    
    // Fetch Task
    CourtesyCardPublishQueue *queue = [CourtesyCardPublishQueue sharedQueue];
    CourtesyCardPublishTask *task = [queue publishTaskInPublishQueueWithCard:card];
    if (task) {
        [self setPublishProgressWithStatus:task.status withError:nil];
        if (!task.hasObserver) {
            [task addObserver:self
                   forKeyPath:@"status"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
        }
        self.targetTask = task;
    } else {
        [self resetsmallTimeLabelText];
    }
}

- (void)resetsmallTimeLabelText {
    if (self.card) {
        [self resetLabelColor];
//        self.smallTimeLabel.text = [NSString stringWithFormat:@"字数 %lu", (unsigned long)self.card.local_template.content.length];
        self.smallTimeLabel.text = [[NSDate dateWithTimeIntervalSince1970:self.card.modified_at] compareCurrentTime];
    }
}

- (void)resetLabelColor {
    if (self.card) {
        if (self.card.hasBanned) {
            self.mainTitleLabel.textColor = [UIColor magicColor];
        } else {
            self.mainTitleLabel.textColor = [UIColor blackColor];
        }
    }
}

- (void)setPublishProgressWithStatus:(CourtesyCardPublishTaskStatus)status withError:(NSError *)err {
    if (status == CourtesyCardPublishTaskStatusProcessing) {
        self.smallTimeLabel.text = @"正在同步";
        return;
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
    [self.publishProgressView setProgress:0.0 animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [self removeTaskObserver];
}

- (void)removeTaskObserver {
    if (self.targetTask && self.targetTask.hasObserver) {
        [self.targetTask removeObserver:self
                             forKeyPath:@"status"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context {
    if (object == self.targetTask &&
        [keyPath isEqualToString:@"status"]) {
        dispatch_async_on_main_queue(^{
            [self setPublishProgressWithStatus:self.targetTask.status withError:self.targetTask.error];
            if (self.targetTask.status == CourtesyCardPublishTaskStatusProcessing) {
                if (self.targetTask.totalBytes < 1) return;
                [self.publishProgressView setProgress:((float)self.targetTask.currentProgress) animated:YES];
                self.smallTimeLabel.text = [NSString stringWithFormat:@"正在同步 - %@ / %@",
                                       [FCFileManager sizeFormatted:[NSNumber numberWithFloat:self.targetTask.logicalBytes]],
                                       [FCFileManager sizeFormatted:[NSNumber numberWithFloat:(self.targetTask.totalBytes - self.targetTask.skippedBytes)]]];
            }
        });
    }
}

@end
