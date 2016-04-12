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

@interface CourtesyDraftTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *briefTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIProgressView *publishProgressView;
@property (strong, nonatomic) CourtesyCardPublishTask *targetTask;

@end

@implementation CourtesyDraftTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.mainTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.briefTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.mainTitleLabel.numberOfLines = 1;
    self.briefTitleLabel.numberOfLines = 1;
    self.targetTask = nil;
}

- (void)setCard:(CourtesyCardModel *)card {
    _card = card;
    self.mainTitleLabel.text = card.card_data.mainTitle;
    self.briefTitleLabel.text = card.card_data.briefTitle;
    NSURL *thumbnailURL = card.card_data.smallThumbnailURL;
    if (thumbnailURL) {
        [self.imagePreview setImageWithURL:thumbnailURL
                                   options:YYWebImageOptionSetImageWithFadeAnimation];
    } else {
        [self.imagePreview setImage:nil]; // 清除缩略图
    }
    
    // Fetch Task
    CourtesyCardPublishQueue *queue = [CourtesyCardPublishQueue sharedQueue];
    CourtesyCardPublishTask *task = [queue publishTaskInPublishQueueWithCard:card];
    if (task) {
        [self setPublishProgressWithStatus:task.status];
        if (!task.hasObserver) {
            [task addObserver:self
                   forKeyPath:@"status"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
        }
        self.targetTask = task;
    } else {
        [self resetDateLabelText];
    }
}

- (void)resetDateLabelText {
    if (self.card) {
        self.dateLabel.text = [NSString stringWithFormat:@"%@ | 字数 %lu", [[NSDate dateWithTimeIntervalSince1970:self.card.modified_at] compareCurrentTime], (unsigned long)self.card.card_data.content.length];
    }
}

- (void)setPublishProgressWithTotalBytes:(int64_t)totalBytes andLogicalBytes:(int64_t)logicalBytes {
    if (totalBytes < 1) return;
    [self.publishProgressView setProgress:((float)logicalBytes / totalBytes) animated:YES];
    self.dateLabel.text = [NSString stringWithFormat:@"正在上传 - %@ / %@",
                           [FCFileManager sizeFormatted:[NSNumber numberWithFloat:logicalBytes]],
                           [FCFileManager sizeFormatted:[NSNumber numberWithFloat:totalBytes]]];
}

- (void)setPublishProgressWithStatus:(CourtesyCardPublishTaskStatus)status {
    if (status == CourtesyCardPublishTaskStatusProcessing) {
        self.dateLabel.text = @"正在上传";
        return;
    } else if (status == CourtesyCardPublishTaskStatusNone) {
        self.dateLabel.text = @"等待上传";
    } else if (status == CourtesyCardPublishTaskStatusReady) {
        self.dateLabel.text = @"正在准备上传";
    } else if (status == CourtesyCardPublishTaskStatusCanceled) {
        self.dateLabel.text = @"上传失败";
    } else if (status == CourtesyCardPublishTaskStatusDone) {
        self.dateLabel.text = @"上传成功";
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
            [self setPublishProgressWithStatus:self.targetTask.status];
            if (self.targetTask.status == CourtesyCardPublishTaskStatusProcessing) {
                [self setPublishProgressWithTotalBytes:self.targetTask.totalBytes andLogicalBytes:self.targetTask.logicalBytes];
            }
        });
    }
}

@end
