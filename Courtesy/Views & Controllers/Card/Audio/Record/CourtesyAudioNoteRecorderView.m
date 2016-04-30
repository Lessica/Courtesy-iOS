//
//  AudioNoteRecordedViewController.m
//
//  Created by Pawel Maczewski on 29/01/14.
//

#import "CourtesyAudioNoteRecorderView.h"
#import "DrawLineView.h"

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

@property (nonatomic, strong) DrawLineView *drawView;
@property (nonatomic, strong) CADisplayLink *displayLink;
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
        
        // Draw view
        DrawLineView *drawView = [[DrawLineView alloc] initWithFrame:self.bounds];
        [self addSubview:drawView];
        self.drawView = drawView;
        
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawEvent)];
        self.displayLink = displayLink;
        
        // top bar
        UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, barHeight)];
        [self addSubview:topBar];
        
        // Record name label
        UITextField *recordName = [UITextField new];
        recordName.frame = CGRectMake(0, topBar.frame.size.height / 2 - 16, topBar.frame.size.width, 32);
        recordName.backgroundColor = [UIColor clearColor];
        recordName.font = [UIFont systemFontOfSize:16];
        recordName.textColor = self.style.toolbarTintColor;
        recordName.textAlignment = NSTextAlignmentCenter;
        recordName.text = @"新录音";
        recordName.userInteractionEnabled = NO;
        [topBar addSubview:recordName];
        self.recordName = recordName;
        
        // Top buttons
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(self.frame.size.width - 12 - 48, 12, 48, 48);
        doneBtn.enabled = NO;
        [doneBtn setTintColor:self.style.toolbarTintColor];
        [doneBtn setImage:[[UIImage imageNamed:@"approve"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [doneBtn setImage:nil forState:UIControlStateDisabled];
        [doneBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        [doneBtn sizeToFit];
        [topBar addSubview:doneBtn];
        self.doneBtn = doneBtn;
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(12, 12, 48, 48);
        [cancelBtn setTintColor:self.style.toolbarTintColor];
        [cancelBtn setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn sizeToFit];
        [topBar addSubview:cancelBtn];
        self.cancelBtn = cancelBtn;
        
        // Control buttons
        UILabel *recordLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 20, 64)];
        recordLengthLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - recordLengthLabel.height / 4);
        recordLengthLabel.text = @"00:00.00";
        recordLengthLabel.font = [UIFont systemFontOfSize:48.0 weight:UIFontWeightUltraLight];
        recordLengthLabel.textAlignment = NSTextAlignmentCenter;
        [recordLengthLabel setTextColor:self.style.toolbarTintColor];
        [self addSubview:recordLengthLabel];
        self.recordLengthLabel = recordLengthLabel;
        
        // Reset Draw View Origin
        self.drawView.centerY = recordLengthLabel.centerY + 45.0;
        
        UIButton *record = [UIButton buttonWithType:UIButtonTypeCustom];
        record.frame = CGRectMake(0, 0, 64, 64);
        record.center = CGPointMake(24 + record.frame.size.width / 2, self.frame.size.height - 56);
        [record setTintColor:self.style.toolbarTintColor];
        [record setImage:[[UIImage imageNamed:@"record"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [record setImage:[[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [record addTarget:self action:@selector(recordTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:record];
        self.record = record;
        
        UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
        play.frame = CGRectMake(0, 0, 64, 64);
        play.center = CGPointMake(self.frame.size.width - 24 - play.frame.size.width / 2, self.frame.size.height - 56);
        play.enabled = NO;
        [play setTintColor:self.style.toolbarTintColor];
        [play setImage:[[UIImage imageNamed:@"play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [play setImage:nil forState:UIControlStateDisabled];
        [play addTarget:self action:@selector(playTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:play];
        self.play = play;
        
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
    if (sender.selected) { // 停止录音
        [self.recorder stop];
        [self.displayLink invalidate];
        _play.enabled = YES;
        _doneBtn.enabled = YES;
        [self.recordingTimer invalidate];
        self.recordingTimer = nil;
    } else { // 开始播放录音
        [self playRecordSound];
        _play.enabled = NO;
        _doneBtn.enabled = NO;
        [self performSelector:@selector(startRecord) withObject:nil afterDelay:0.5];
    }
    sender.selected = !sender.selected;
}

- (void)startRecord { // 开始录音
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
    self.recorder.meteringEnabled = YES;
    [self.recorder record];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recordingTimerUpdate:) userInfo:nil repeats:YES];
    [_recordingTimer fire];
}

- (void)playTap:(UIButton *)sender { // 开始播放录音
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

- (void)drawEvent {
    [self.recorder updateMeters]; // 更新仪表读数
    
    // 读取每个声道的平均电平和峰值电平，代表每个声道的分贝数，范围在 -100 ~ 0 之间。
    self.drawView.avgValue = [self.recorder averagePowerForChannel:0];
    
    [self.drawView setNeedsDisplay];
}

- (void)recordingTimerUpdate:(id)sender {
    if (!_recorder) {
        return;
    }
    int minute = (int)(_recorder.currentTime / 60);
    int second = (int)(_recorder.currentTime) % 60;
    int micro = (int)(_recorder.currentTime * 100) % 100;
    self.recordLengthLabel.text = [NSString stringWithFormat:@"%02d:%02d.%02d", minute, second, micro];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    isPlaying = NO;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.displayLink invalidate]; self.displayLink = nil;
    [self.recordingTimer invalidate]; self.recordingTimer = nil;
    [self.recorder stop]; self.recorder = nil;
    [self.player stop]; self.player = nil;
}

- (void)dealloc {
    CYLog(@"");
}

@end
