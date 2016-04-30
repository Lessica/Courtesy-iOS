//
//  CourtesyFontTableViewCell.m
//  Courtesy
//
//  Created by Zheng on 3/13/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyFontTableViewCell.h"

@interface CourtesyFontTableViewCell ()
@property (nonatomic, strong)  UIView   *upView;
@property (nonatomic, strong)  UILabel  *upLabel;

@end

@implementation CourtesyFontTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        upView.layer.masksToBounds = YES;
        [self addSubview:upView];
        self.upView = upView;
        
        UILabel *upLabel = [[UILabel alloc] init];
        [upView addSubview:upLabel];
        self.upLabel = upLabel;
    }
    return self;
}

- (void)setFontModel:(CourtesyFontModel *)fontModel {
    _fontModel = fontModel;
}

- (void)didMoveToSuperview {
    _upView.backgroundColor = self.tintColor;
    _upLabel.text = self.textLabel.text;
    _upLabel.font = self.textLabel.font;
    _upLabel.textColor = [UIColor whiteColor];
    _upLabel.textAlignment = self.textLabel.textAlignment;
    [super didMoveToSuperview];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _upLabel.frame = self.textLabel.frame;
}

- (void)setProgress:(float)progress {
    _upView.width = self.width * progress;
}

- (void)notifyFontUpdate {
    if (_fontModel.status == CourtesyFontDownloadingTaskStatusDownload) {
        [self setProgress:_fontModel.downloadProgress];
    } else if (_fontModel.status == CourtesyFontDownloadingTaskStatusReady) {
        [self setProgress:0.0];
    } else if (_fontModel.status == CourtesyFontDownloadingTaskStatusDone) {
        [self setProgress:0.0];
        self.textLabel.text = _fontModel.fontName;
        self.textLabel.font = _fontModel.font;
    } else if (_fontModel.status == CourtesyFontDownloadingTaskStatusExtract) {
        [self setProgress:0.0];
    } else if (_fontModel.status == CourtesyFontDownloadingTaskStatusSuspend) {
        
    } else {
        [self setProgress:0.0];
    }
}

@end
