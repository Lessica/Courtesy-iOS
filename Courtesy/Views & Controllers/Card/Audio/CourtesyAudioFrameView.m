//
//  CourtesyAudioFrameView.m
//  Courtesy
//
//  Created by Zheng on 3/7/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAudioFrameView.h"

@implementation CourtesyAudioFrameView

- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController <CourtesyAudioFrameDelegate>*)delegate
                  andUserinfo:(NSDictionary *)userinfo {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        _userinfo = userinfo;
        // Init of Frame View
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowOpacity = 0.45;
        self.layer.shadowRadius = 1;
        self.isPlaying = NO;
        [self addSubview:self.playBtn];
        [self reloadStyle];
    }
    return self;
}

- (CourtesyCardDataModel *)cdata {
    return self.delegate.card.local_template;
}

- (CourtesyCardStyleModel *)style {
    return self.delegate.card.local_template.style;
}

- (BOOL)editable {
    return self.delegate.editable;
}

- (void)dealloc {
    CYLog(@"");
}

- (void)removeFromSuperview {
    [self pausePlaying];
    [super removeFromSuperview];
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        UIButton *playBtn = [UIButton new];
        playBtn.frame = CGRectMake(kAudioFrameBtnInterval, kAudioFrameBorderWidth, kAudioFrameBtnWidth, kAudioFrameBtnWidth);
        playBtn.centerY = self.frame.size.height / 2;
        playBtn.layer.masksToBounds = YES;
        playBtn.layer.cornerRadius = playBtn.frame.size.width / 2;
        playBtn.backgroundColor = [UIColor clearColor];
        [playBtn setImage:[[UIImage imageNamed:@"54-play-audio"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [playBtn setImage:[[UIImage imageNamed:@"55-pause-audio"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [playBtn addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [playBtn setSelected:NO];
        _playBtn = playBtn;
    }
    return _playBtn;
}

- (void)reloadStyle {
    self.backgroundColor = self.style.cardElementBackgroundColor;
    self.layer.shadowColor = self.style.cardElementShadowColor.CGColor;
    if (_playBtn) {
        _playBtn.tintColor = self.style.cardElementTintColor;
    }
    if (_waveform) {
        _waveform.progressColor = self.style.cardElementTintColor;
        _waveform.wavesColor = self.style.cardElementTintFocusColor;
    }
    if (_titleLabel) {
        _titleLabel.textColor = self.style.cardElementBackgroundColor;
        _titleLabel.font = [self.delegate.originalFont fontWithSize:12.0];
    }
}

- (void)pausePlaying {
    if (self.isPlaying) {
        self.isPlaying = NO;
        [self.playBtn setSelected:self.isPlaying];
        [self.audioQueue pause];
    }
}

- (void)setAudioURL:(NSURL *)audioURL {
    if (!audioURL) return;
    _audioURL = audioURL;
    if (_waveform) { // Remove old wave form
        [_waveform removeFromSuperview]; _waveform = nil;
    }
    self.waveform.audioURL = audioURL;
    [self addSubview:self.waveform];
    [self sendSubviewToBack:self.waveform];
    [self addSubview:self.titleLabel];
    
    // Init of Audio Player
    AFSoundItem *audioItem = [[AFSoundItem alloc] initWithStreamingURL:audioURL];
    if (!audioItem) return;
    AFSoundPlayback *audioQueue = [[AFSoundPlayback alloc] initWithItem:audioItem];
    if (audioItem.duration == 0) return;
    self.scale = self.waveform.totalSamples / audioItem.duration;
    self.audioItem = audioItem;
    self.audioQueue = audioQueue;
    if (self.cdata.shouldAutoPlayAudio) [self playButtonTapped:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.audioQueue listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
        __strong typeof(self) strongSelf = weakSelf;
        [UIView animateWithDuration:1.0 animations:^{
            strongSelf.waveform.progressSamples = (unsigned long) (strongSelf.scale * item.timePlayed);
        }];
        CYLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
    } andFinishedBlock:^() {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.isPlaying = NO;
        [strongSelf.playBtn setSelected:strongSelf.isPlaying];
        [UIView animateWithDuration:0.2 animations:^{
            strongSelf.waveform.progressSamples = 0;
        }];
        CYLog(@"Track finished playing!");
    }];
}

- (void)setLabelText:(NSString *)labelText {
    if (!labelText) {
        return;
    }
    _labelText = labelText;
    if (![labelText isEmpty]) {
        self.titleLabel.text = labelText;
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - kAudioFrameBtnInterval * 3 - kAudioFrameBtnWidth, kAudioFrameLabelHeight)];
        titleLabel.center = _waveform.center;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [self.delegate.originalFont fontWithSize:12.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = self.style.cardElementTextColor;
        titleLabel.text = @"正在载入波形……";
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (FDWaveformView *)waveform {
    if (!_waveform) {
        FDWaveformView *waveform = [[FDWaveformView alloc] initWithFrame:CGRectMake(kAudioFrameBtnInterval + kAudioFrameBtnWidth + kAudioFrameBtnInterval, kAudioFrameBorderWidth, self.frame.size.width - kAudioFrameBtnInterval * 3 - kAudioFrameBtnWidth, self.frame.size.height - kAudioFrameBorderWidth * 2)];
        waveform.delegate = self;
        waveform.zoomStartSamples = 0;
        waveform.zoomEndSamples = waveform.totalSamples / 4;
        waveform.doesAllowScrubbing = YES;
        waveform.wavesColor = self.style.cardElementTintFocusColor;
        waveform.progressColor = self.style.cardElementTintColor;
        _waveform = waveform;
    }
    return _waveform;
}

- (void)playButtonTapped:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioFrameTapped:)]) {
        [self.delegate audioFrameTapped:self];
    }
    if (!self.audioQueue) {
        return;
    }
    if (!self.isPlaying) {
        self.isPlaying = YES;
        [self.playBtn setSelected:self.isPlaying];
        [self.audioQueue restart];
        [self.audioQueue play];
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioFrameDidBeginPlaying:)]) {
            [self.delegate audioFrameDidBeginPlaying:self];
        }
    } else {
        self.isPlaying = NO;
        [self.playBtn setSelected:self.isPlaying];
        [self.audioQueue pause];
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioFrameDidEndPlaying:)]) {
            [self.delegate audioFrameDidEndPlaying:self];
        }
    }
}

#pragma mark - FDWaveformViewDelegate

- (void)waveformViewDidRender:(FDWaveformView *)waveformView {
    if (!self.titleLabel) {
        return;
    }
    self.titleLabel.textColor = [UIColor whiteColor];
    if (!self.userinfo || ![self.userinfo hasKey:@"title"]) {
        return;
    }
    self.labelText = self.userinfo[@"title"];
}

- (void)waveformViewDidFailedLoading:(FDWaveformView *)waveformView
                        errorMessage:(NSString *)string {
    if (!self.titleLabel) {
        return;
    }
    self.titleLabel.text = [NSString stringWithFormat:@"载入失败 - %@", string];
}

- (void)waveformTapped:(FDWaveformView *)waveformView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioFrameTapped:)]) {
        [self.delegate audioFrameTapped:self];
    }
    [self startPlaying];
}

- (void)startPlaying {
    if (!self.audioQueue || !self.waveform) {
        return;
    }
    if (self.isPlaying) {
        [self.playBtn setSelected:YES];
        self.audioItem.timePlayed = (NSInteger) (((float)self.waveform.progressSamples / self.waveform.totalSamples) * [self.audioQueue currentItem].duration);
        [self.audioQueue playAtSecond:self.audioItem.timePlayed];
        [self.audioQueue play];
    } else {
        [self playButtonTapped:nil];
    }
}

@end
