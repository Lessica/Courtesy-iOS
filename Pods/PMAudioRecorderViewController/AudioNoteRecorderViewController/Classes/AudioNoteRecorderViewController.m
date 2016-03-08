//
//  AudioNoteRecordedViewController.m
//
//  Created by Pawel Maczewski on 29/01/14.
//

#import "UIImage+BlurredFrame.h"
#import "AudioNoteRecorderViewController.h"

@interface AudioNoteRecorderViewController ()
@property (nonatomic, strong) UIImageView *background;

@property (nonatomic, strong) UIButton *play;
@property (nonatomic, strong) UIButton *record;
@property (nonatomic, strong) UILabel *recordLengthLabel;
@property (nonatomic, strong) UITextField *recordName;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, strong) UIView *controlsBg;
@end

@implementation AudioNoteRecorderViewController {
    BOOL isPlaying;
}

- (id)initWithMasterViewController:(UIViewController *)masterViewController {
    if (self = [super init]) {
        // make screenshot
        CGSize imageSize = CGSizeMake(masterViewController.view.window.bounds.size.width, masterViewController.view.window.bounds.size.height);
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0); // Retina Support
        [masterViewController.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.background = [[UIImageView alloc] initWithImage:viewImage];
        [self.view addSubview:_background];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    CGFloat height = 240.f;
    CGFloat barHeight = 64.0f;
    
    // Control SG
    self.controlsBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    _controlsBg.frame = CGRectMake(0, self.view.frame.size.height - _controlsBg.frame.size.height, _controlsBg.frame.size.width, _controlsBg.frame.size.height);
    _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y + self.view.frame.size.height);
    [UIView animateWithDuration:0.5f animations:^{
        _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y - self.view.frame.size.height);
    }];
    [self.view addSubview:_controlsBg];
    
    // gray background for the controls
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    [bg setBackgroundColor:[UIColor blackColor]];
    [bg setAlpha:0.65];
    [_controlsBg addSubview:bg];
    
    // top bar
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, barHeight)];
    [_controlsBg addSubview:topBar];
    
    // Record name label
    self.recordName = [UITextField new];
    _recordName.frame = CGRectMake(0, topBar.frame.size.height / 2 - 16, topBar.frame.size.width, 32);
    _recordName.backgroundColor = [UIColor clearColor];
    _recordName.font = [UIFont systemFontOfSize:16];
    _recordName.textColor = [UIColor whiteColor];
    _recordName.textAlignment = NSTextAlignmentCenter;
    _recordName.text = @"新录音";
    _recordName.userInteractionEnabled = NO;
    [topBar addSubview:_recordName];
    
    // Top buttons
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneBtn.frame = CGRectMake(self.view.frame.size.width - 10 - 48, 10, 48, 48);
    _doneBtn.enabled = NO;
    [_doneBtn setTintColor:[UIColor whiteColor]];
    [_doneBtn setImage:[[UIImage imageNamed:@"approve"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_doneBtn setImage:nil forState:UIControlStateDisabled];
    [_doneBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [_doneBtn sizeToFit];
    [topBar addSubview:_doneBtn];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.frame = CGRectMake(10, 10, 48, 48);
    [_cancelBtn setTintColor:[UIColor whiteColor]];
    [_cancelBtn setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelBtn sizeToFit];
    [topBar addSubview:_cancelBtn];
    
    // Control buttons
    self.recordLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, barHeight + 10, self.view.frame.size.width - 20, 64)];
    _recordLengthLabel.text = @"00:00.00";
    _recordLengthLabel.font = [UIFont systemFontOfSize:48.0 weight:UIFontWeightUltraLight];
    _recordLengthLabel.textAlignment = NSTextAlignmentCenter;
    [_recordLengthLabel setTextColor:[UIColor whiteColor]];
    [_controlsBg addSubview:_recordLengthLabel];
    
    self.record = [UIButton buttonWithType:UIButtonTypeCustom];
    _record.frame = CGRectMake(0, 0, 64, 64);
    _record.center = CGPointMake(24 + _record.frame.size.width / 2, height - 56);
    [_record setTintColor:[UIColor whiteColor]];
    [_record setImage:[[UIImage imageNamed:@"record"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_record setImage:[[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [_record addTarget:self action:@selector(recordTap:) forControlEvents:UIControlEventTouchUpInside];
    [_controlsBg addSubview:_record];
    
    self.play = [UIButton buttonWithType:UIButtonTypeCustom];
    _play.frame = CGRectMake(0, 0, 64, 64);
    _play.center = CGPointMake(self.view.frame.size.width - 24 - _play.frame.size.width / 2, height - 56);
    _play.enabled = NO;
    [_play setTintColor:[UIColor whiteColor]];
    [_play setImage:[[UIImage imageNamed:@"play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_play setImage:nil forState:UIControlStateDisabled];
    [_play addTarget:self action:@selector(playTap:) forControlEvents:UIControlEventTouchUpInside];
    [_controlsBg addSubview:_play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (void)cancel:(UIButton *)sender {
    if (_recorder == nil || _recorder.isRecording == NO) {
        [UIView animateWithDuration:0.5 animations:^{
            _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y + self.view.frame.size.height);
        } completion:^(BOOL finished) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(audioNoteRecorderDidCancel:)]) {
                [self.delegate audioNoteRecorderDidCancel:self];
            }
            if (self.finishedBlock) {
                self.finishedBlock ( NO, nil );
            }
        }];
    }
}

- (void)done:(UIButton *)sender {
    if (_recorder && _recorder.isRecording == NO) {
        [UIView animateWithDuration:0.5 animations:^{
            _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y + self.view.frame.size.height);
        } completion:^(BOOL finished) {
            if (self.delegate) {
                [self.delegate audioNoteRecorderDidTapDone:self withRecordedURL:_recorder.url];
            }
            if (self.finishedBlock) {
                self.finishedBlock ( YES, _recorder.url );
            }
        }];
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
        _play.enabled = NO;
        _doneBtn.enabled = NO;
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
        NSString *targetURL = [NSURL fileURLWithPath:[cachesDir stringByAppendingPathComponent:filename]];
        self.recorder = [[AVAudioRecorder alloc] initWithURL:targetURL settings:recorderSettings error:&error];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        UInt32 doChangeDefault = 1;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);
        
        self.recorder.delegate = self;
        [self.recorder record];
        self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recordingTimerUpdate:) userInfo:nil repeats:YES];
        [_recordingTimer fire];
    }
    sender.selected = !sender.selected;
    
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

- (void)recordingTimerUpdate:(id)sender {
    int minute = (int)(_recorder.currentTime / 60);
    int second = (int)(_recorder.currentTime) % 60;
    int micro = (int)(_recorder.currentTime * 100) % 100;
    self.recordLengthLabel.text = [NSString stringWithFormat:@"%02d:%02d.%02d", minute, second, micro];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    isPlaying = NO;
}

@end
