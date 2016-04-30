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
        
    }
    return self;
}

- (void)setFontModel:(CourtesyFontModel *)fontModel {
    _fontModel = fontModel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
    upView.layer.masksToBounds = YES;
    upView.backgroundColor = self.tintColor;
    
    [self addSubview:upView];
    self.upView = upView;
    
    UILabel *upLabel = [[UILabel alloc] initWithFrame:self.textLabel.frame];
    upLabel.text = self.textLabel.text;
    upLabel.font = self.textLabel.font;
    upLabel.textColor = [UIColor whiteColor];
    upLabel.textAlignment = self.textLabel.textAlignment;
    [upView addSubview:upLabel];
    self.upLabel = upLabel;
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
