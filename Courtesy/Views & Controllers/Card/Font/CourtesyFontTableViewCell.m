//
//  CourtesyFontTableViewCell.m
//  Courtesy
//
//  Created by Zheng on 3/13/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyFontTableViewCell.h"

@interface CourtesyFontTableViewCell ()
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation CourtesyFontTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:frame];
        progressView.progressTintColor = self.tintColor;
        progressView.trackTintColor = [UIColor clearColor];
        [self addSubview:progressView];
        [self sendSubviewToBack:progressView];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height / 2, frame.size.height / 2)];
        indicatorView.center = CGPointMake(indicatorView.frame.size.width / 2, frame.size.height / 2);
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self addSubview:indicatorView];
        
        _progressView = progressView;
        _indicatorView = indicatorView;
    }
    return self;
}

- (void)setFontModel:(CourtesyFontModel *)fontModel {
    _fontModel = fontModel;
    [fontModel addObserver:self
                forKeyPath:@"status"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if (object == _fontModel && [keyPath isEqualToString:@"status"]) {
        dispatch_async_on_main_queue(^{
            if (_fontModel.status == CourtesyFontDownloadingTaskStatusDownload) {
                _progressView.progress = _fontModel.downloadProgress;
            } else if (_fontModel.status == CourtesyFontDownloadingTaskStatusReady) {
                _progressView.progress = 0.0;
                if (![_indicatorView isAnimating]) {
                    [_indicatorView startAnimating];
                }
            } else if (_fontModel.status == CourtesyFontDownloadingTaskStatusDone) {
                _progressView.progress = 0.0;
                if ([_indicatorView isAnimating]) {
                    [_indicatorView stopAnimating];
                }
                self.textLabel.text = _fontModel.fontName;
                self.textLabel.font = _fontModel.font;
            } else if (_fontModel.status == CourtesyFontDownloadingTaskStatusExtract) {
                _progressView.progress = 0.0;
            } else if (_fontModel.status == CourtesyFontDownloadingTaskStatusSuspend) {
                if ([_indicatorView isAnimating]) {
                    [_indicatorView stopAnimating];
                }
            } else {
                _progressView.progress = 0.0;
                if ([_indicatorView isAnimating]) {
                    [_indicatorView stopAnimating];
                }
            }
        });
    }
}

- (void)dealloc {
    if (_fontModel) {
        [_fontModel removeObserver:self
                        forKeyPath:@"status"];
    }
}

@end
