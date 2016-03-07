//
//  CourtesyAudioFrameView.m
//  Courtesy
//
//  Created by Zheng on 3/7/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAudioFrameView.h"

@implementation CourtesyAudioFrameView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Init of Frame View
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowOpacity = 0.45;
        self.layer.shadowRadius = 1;
        // Init of Play Button
        _playBtn = [UIButton new];
        _playBtn.frame = CGRectMake(kAudioFrameBtnInterval, kAudioFrameBorderWidth, kAudioFrameBtnWidth, kAudioFrameBtnWidth);
        _playBtn.layer.cornerRadius = _playBtn.frame.size.width / 2;
        _playBtn.layer.masksToBounds = YES;
        _playBtn.backgroundColor = [UIColor clearColor];
        [_playBtn setImage:[UIImage imageNamed:@"54-play-audio"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"55-pause-audio"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        _isPlaying = NO;
        [_playBtn setSelected:NO];
        [self addSubview:_playBtn];
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self pausePlaying];
}

- (void)pausePlaying {
    if (_isPlaying) {
        _isPlaying = NO;
        [_playBtn setSelected:_isPlaying];
        [_audioQueue pause];
    }
}

- (void)setAudioURL:(NSURL *)audioURL {
    _audioURL = audioURL;
    if (self.waveform) {
        [self.waveform removeFromSuperview];
    }
    // Init of Wave View
    self.waveform = [[FDWaveformView alloc] initWithFrame:CGRectMake(kAudioFrameBtnInterval + kAudioFrameBtnWidth + kAudioFrameBtnInterval, kAudioFrameBorderWidth, self.frame.size.width - kAudioFrameBtnInterval * 3 - kAudioFrameBtnWidth, self.frame.size.height - kAudioFrameBorderWidth * 2)];
    self.waveform.delegate = self;
    self.waveform.audioURL = audioURL;
    self.waveform.zoomStartSamples = 0;
    self.waveform.zoomEndSamples = self.waveform.totalSamples / 4;
    self.waveform.doesAllowScrubbing = YES;
    self.waveform.wavesColor = [UIColor grayColor];
    self.waveform.progressColor = [UIColor darkGrayColor];
    [self addSubview:_waveform];
    [self sendSubviewToBack:_waveform];
    // Init of Title Label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - kAudioFrameBtnInterval * 3 - kAudioFrameBtnWidth, kAudioFrameLabelHeight)];
    self.titleLabel.center = self.waveform.center;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = @"正在载入波形……";
    [self addSubview:self.titleLabel];
    // Init of Audio Player
    if (!_audioURL) {
        return;
    }
    _audioItem = [[AFSoundItem alloc] initWithStreamingURL:_audioURL];
    if (!_audioItem) {
        return;
    }
    _audioQueue = [[AFSoundPlayback alloc] initWithItem:_audioItem];
    _scale = self.waveform.totalSamples / _audioItem.duration;
}

- (void)playButtonTapped:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(audioFrameTapped:)]) {
        [_delegate audioFrameTapped:self];
    }
    if (!_audioQueue) {
        return;
    }
    if (!_isPlaying) {
        _isPlaying = YES;
        [_playBtn setSelected:_isPlaying];
        [_audioQueue listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
            [UIView animateWithDuration:1.0 animations:^{
                self.waveform.progressSamples = _scale * item.timePlayed;
            }];
            CYLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
        } andFinishedBlock:^() {
            _isPlaying = NO;
            [_audioQueue pause];
            [_audioQueue restart];
            [_playBtn setSelected:_isPlaying];
            [UIView animateWithDuration:0.2 animations:^{
                self.waveform.progressSamples = 0;
            }];
            CYLog(@"Track finished playing!");
        }];
        [_audioQueue play];
        if (_delegate && [_delegate respondsToSelector:@selector(audioFrameDidBeginPlaying:)]) {
            [_delegate audioFrameDidBeginPlaying:self];
        }
    } else {
        _isPlaying = NO;
        [_playBtn setSelected:_isPlaying];
        [_audioQueue pause];
        if (_delegate && [_delegate respondsToSelector:@selector(audioFrameDidEndPlaying:)]) {
            [_delegate audioFrameDidEndPlaying:self];
        }
    }
}

#pragma mark - FDWaveformViewDelegate

- (void)waveformViewDidRender:(FDWaveformView *)waveformView {
    if (!_titleLabel) {
        return;
    }
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = [self.userinfo title];
}

- (void)waveformTapped:(FDWaveformView *)waveformView {
    if (_delegate && [_delegate respondsToSelector:@selector(audioFrameTapped:)]) {
        [_delegate audioFrameTapped:self];
    }
    [self startPlaying];
}

- (void)startPlaying {
    if (!_audioQueue || !_waveform) {
        return;
    }
    _isPlaying = YES;
    [_playBtn setSelected:_isPlaying];
    _audioItem.timePlayed = (((float)_waveform.progressSamples / _waveform.totalSamples) * [_audioQueue currentItem].duration);
    [_audioQueue playAtSecond:_audioItem.timePlayed];
    [_audioQueue play];
}

@end
