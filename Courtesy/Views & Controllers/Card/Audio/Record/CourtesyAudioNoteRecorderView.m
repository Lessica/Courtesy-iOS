//
//  AudioNoteRecordedViewController.m
//
//  Created by Pawel Maczewski on 29/01/14.
//

#import "CourtesyAudioNoteRecorderView.h"

static SystemSoundID record_sound_id = 0;

@interface CourtesyAudioNoteRecorderView ()
@property (nonatomic, strong) UIButton *play;
@property (nonatomic, strong) UIButton *record;
@property (nonatomic, strong) UILabel *recordLengthLabel;
@property (nonatomic, strong) UITextField *recordName;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSTimer *recordingTimer;
@end

@implementation CourtesyAudioNoteRecorderView {
    BOOL isPlaying;
}

- (CourtesyCardDataModel *)cdata {
    return self.delegate.card.local_template;
}

- (CourtesyCardStyleModel *)style {
    return self.delegate.card.local_template.style;
}

- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController<CourtesyAudioNoteRecorderDelegate> *)viewController {
    if (self = [super initWithFrame:frame]) {
        self.delegate = viewController;
        
        self.backgroundColor = self.style.toolbarColor;
        self.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        self.layer.borderWidth = 0.5;
        CGFloat barHeight = 64.0f;
        
        // top bar
        UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, barHeight)];
        [self addSubview:topBar];
        
        // Record name label
        self.recordName = [UITextField new];
        _recordName.frame = CGRectMake(0, topBar.frame.size.height / 2 - 16, topBar.frame.size.width, 32);
        _recordName.backgroundColor = [UIColor clearColor];
        _recordName.font = [UIFont systemFontOfSize:16];
        _recordName.textColor = self.style.toolbarTintColor;
        _recordName.textAlignment = NSTextAlignmentCenter;
        _recordName.text = @"新录音";
        _recordName.userInteractionEnabled = NO;
        [topBar addSubview:_recordName];
        
        // Top buttons
        self.doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectMake(self.frame.size.width - 12 - 48, 12, 48, 48);
        _doneBtn.enabled = NO;
        [_doneBtn setTintColor:self.style.toolbarTintColor];
        [_doneBtn setImage:[[UIImage imageNamed:@"approve"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_doneBtn setImage:nil forState:UIControlStateDisabled];
        [_doneBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        [_doneBtn sizeToFit];
        [topBar addSubview:_doneBtn];
        
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(12, 12, 48, 48);
        [_cancelBtn setTintColor:self.style.toolbarTintColor];
        [_cancelBtn setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn sizeToFit];
        [topBar addSubview:_cancelBtn];
        
        // Control buttons
        self.recordLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 20, 64)];
        _recordLengthLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - _recordLengthLabel.height / 4);
        _recordLengthLabel.text = @"00:00.00";
        _recordLengthLabel.font = [UIFont systemFontOfSize:48.0 weight:UIFontWeightUltraLight];
        _recordLengthLabel.textAlignment = NSTextAlignmentCenter;
        [_recordLengthLabel setTextColor:self.style.toolbarTintColor];
        [self addSubview:_recordLengthLabel];
        
        self.record = [UIButton buttonWithType:UIButtonTypeCustom];
        _record.frame = CGRectMake(0, 0, 64, 64);
        _record.center = CGPointMake(24 + _record.frame.size.width / 2, self.frame.size.height - 56);
        [_record setTintColor:self.style.toolbarTintColor];
        [_record setImage:[[UIImage imageNamed:@"record"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_record setImage:[[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [_record addTarget:self action:@selector(recordTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_record];
        
        self.play = [UIButton buttonWithType:UIButtonTypeCustom];
        _play.frame = CGRectMake(0, 0, 64, 64);
        _play.center = CGPointMake(self.frame.size.width - 24 - _play.frame.size.width / 2, self.frame.size.height - 56);
        _play.enabled = NO;
        [_play setTintColor:self.style.toolbarTintColor];
        [_play setImage:[[UIImage imageNamed:@"play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_play setImage:nil forState:UIControlStateDisabled];
        [_play addTarget:self action:@selector(playTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_play];
        
        isPlaying = NO;
    }
    return self;
}

#pragma mark - actions

- (void)cancel:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioNoteRecorderDidCancel:)]) {
        [self.delegate audioNoteRecorderDidCancel:self];
    }
}

- (void)done:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioNoteRecorderDidCancel:)]) {
        [self.delegate audioNoteRecorderDidTapDone:self withRecordedURL:_recorder.url];
    }
}

- (void)recordTap:(UIButton *) sender {
    if (sender.selected) {
        [self.recorder stop];
        _play.enabled = YES;
        _doneBtn.enabled = YES;
        [self.recordingTimer invalidate];
        self.recordingTimer = nil;
    } else {
        [self playRecordSound];
        _play.enabled = NO;
        _doneBtn.enabled = NO;
        [self performSelector:@selector(startRecord) withObject:nil afterDelay:0.5];
    }
    sender.selected = !sender.selected;
}

- (void)startRecord {
    NSDictionary* recorderSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                      [NSNumber numberWithInt:44100], AVSampleRateKey,
                                      [NSNumber numberWithInt:1],     AVNumberOfChannelsKey,
                                      [NSNumber numberWithBool:NO],   AVLinearPCMIsNonInterleaved,
                                      [NSNumber numberWithInt:16],    AVLinearPCMBitDepthKey,
                                      [NSNumber numberWithBool:NO],   AVLinearPCMIsBigEndianKey,
                                      [NSNumber numberWithBool:NO],   AVLinearPCMIsFloatKey,
                                      nil];
    NSError* error = nil;
    NSString *cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filename = [NSString stringWithFormat:@"%@.wav", [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]]];
    NSURL *targetURL = [NSURL fileURLWithPath:[cachesDir stringByAppendingPathComponent:filename]];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:targetURL settings:recorderSettings error:&error];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error:nil];
    //UInt32 doChangeDefault = 1;
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    //AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);
    if (error) CYLog(@"%@", error);
    
    self.recorder.delegate = self;
    [self.recorder record];
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recordingTimerUpdate:) userInfo:nil repeats:YES];
    [_recordingTimer fire];
}

- (void)playTap:(UIButton *)sender {
    if (isPlaying) return;
    NSError* error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recorder.url error:&error];
    if (error) return;
    isPlaying = YES;
    _player.volume = 1.0f;
    _player.numberOfLoops = 0;
    _player.delegate = self;
    [_player play];
}

- (void)playRecordSound {
    if (record_sound_id != 0) {
        AudioServicesPlaySystemSound(record_sound_id);
        return;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"toggle-record" ofType:@"wav"];
    if (path) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &record_sound_id);
        AudioServicesPlaySystemSound(record_sound_id);
    }
}

- (void)recordingTimerUpdate:(id)sender {
    int minute = (int)(_recorder.currentTime / 60);
    int second = (int)(_recorder.currentTime) % 60;
    int micro = (int)(_recorder.currentTime * 100) % 100;
    self.recordLengthLabel.text = [NSString stringWithFormat:@"%02d:%02d.%02d", minute, second, micro];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    isPlaying = NO;
}

- (void)dealloc {
    CYLog(@"");
}

@end
