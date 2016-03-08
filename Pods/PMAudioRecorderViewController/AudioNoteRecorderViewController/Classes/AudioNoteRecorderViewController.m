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

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, strong) UIView *controlsBg;
@end

@implementation AudioNoteRecorderViewController

#pragma mark - public methods
+ (id) showRecorderMasterViewController:(UIViewController *)masterViewController withFinishedBlock:(AudioNoteRecorderFinishBlock)finishedBlock
{
    AudioNoteRecorderViewController *avc = [[AudioNoteRecorderViewController alloc] initWithMasterViewController:masterViewController];
    avc.finishedBlock = finishedBlock;
    [masterViewController presentViewController:avc animated:YES completion:nil];
    return avc;
}
+ (id) showRecorderWithMasterViewController:(UIViewController *)masterViewController withDelegate:(id<AudioNoteRecorderDelegate>)delegate
{
    AudioNoteRecorderViewController *avc = [[AudioNoteRecorderViewController alloc] initWithMasterViewController:masterViewController];
    avc.delegate = delegate;
    [masterViewController presentViewController:avc animated:YES completion:nil];
    return avc;
}

- (id) initWithMasterViewController:(UIViewController *) masterViewController
{
    if (self = [super init]) {
        // make screenshot
        CGSize imageSize = CGSizeMake(masterViewController.view.window.bounds.size.width, masterViewController.view.window.bounds.size.height);
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
        [masterViewController.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.background = [[UIImageView alloc] initWithImage:viewImage];
        [self.view addSubview:_background];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void) viewDidAppear:(BOOL)animated
{

    // create the controls
    CGFloat height = 240.f;
    CGFloat barHeight = 84.0f;
    
    self.controlsBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, barHeight)];
    // buttons
    UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
    [done setTintColor:[UIColor whiteColor]];
    [done setImage:[[UIImage imageNamed:@"approve"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setTintColor:[UIColor whiteColor]];
    [cancel setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [done sizeToFit];
    [cancel sizeToFit];
    cancel.frame = CGRectMake(10, 10, 48, 48);
    done.frame = CGRectMake(self.view.frame.size.width - 10 - 48, 10, 48, 48);
    [topBar addSubview:done];
    [topBar addSubview:cancel];
    
    // gray background for the controls
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    [bg setBackgroundColor:[UIColor blackColor]];
    [bg setAlpha:0.65];
    [_controlsBg addSubview:bg];
    [_controlsBg addSubview:topBar];
    
    _controlsBg.frame = CGRectMake(0, self.view.frame.size.height - _controlsBg.frame.size.height, _controlsBg.frame.size.width, _controlsBg.frame.size.height);

    [self.view addSubview:_controlsBg];
    
    // recording controls...
    self.recordLengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, barHeight + 10, self.view.frame.size.width - 20, 64)];
    _recordLengthLabel.text = @"00:00.00";
    _recordLengthLabel.font = [UIFont systemFontOfSize:48.0 weight:UIFontWeightUltraLight];
    _recordLengthLabel.textAlignment = NSTextAlignmentCenter;
    [_recordLengthLabel setTextColor:[UIColor whiteColor]];
    [_controlsBg addSubview:_recordLengthLabel];
    
    self.record = [UIButton buttonWithType:UIButtonTypeCustom];
    [_record setTintColor:[UIColor whiteColor]];
    [_record setImage:[[UIImage imageNamed:@"record"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_record setImage:[[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    _record.frame = CGRectMake(0, 0, 64, 64);
    _record.center = CGPointMake(24 + _record.frame.size.width / 2, 0.5 * (height - barHeight) + barHeight );
    
    self.play = [UIButton buttonWithType:UIButtonTypeCustom];
    [_play setTintColor:[UIColor whiteColor]];
    [_play setImage:[[UIImage imageNamed:@"play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_play setImage:nil forState:UIControlStateDisabled];
    _play.frame = CGRectMake(0, 0, 64, 64);
    _play.center = CGPointMake(self.view.frame.size.width - 24 - _play.frame.size.width / 2, 0.5 * (height - barHeight) + barHeight );
    _play.enabled = NO;
    [_controlsBg addSubview:_record];
    [_controlsBg addSubview:_play];
    
    // actions
    [_record addTarget:self action:@selector(recordTap:) forControlEvents:UIControlEventTouchUpInside];
    [_play addTarget:self action:@selector(playTap:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y + self.view.frame.size.height);
    [UIView animateWithDuration:0.5f animations:^{
        _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y - self.view.frame.size.height);
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (void) cancel :(UIButton *)sender
{
    if (_recorder == nil || _recorder.isRecording == NO) {
        [UIView animateWithDuration:0.5 animations:^{
            _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y + self.view.frame.size.height);
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.delegate) {
                    [self.delegate audioNoteRecorderDidCancel:self];
                }
                if (self.finishedBlock) {
                    self.finishedBlock ( NO, nil );
                }
            }];
        }];
    }
}
- (void) done:(UIButton *) sender
{
    if (_recorder && _recorder.isRecording == NO) {

        [UIView animateWithDuration:0.5 animations:^{
            _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y + self.view.frame.size.height);
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.delegate) {
                    [self.delegate audioNoteRecorderDidTapDone:self withRecordedURL:_recorder.url];
                }
                if (self.finishedBlock) {
                    self.finishedBlock ( YES, _recorder.url );
                }
            }];
        }];
    }
}
- (void) recordTap:(UIButton *) sender
{
    if (sender.selected) {
        [self.recorder stop];
        _play.enabled = YES;
        [self.recordingTimer invalidate];
        self.recordingTimer = nil;
    } else {
        _play.enabled = NO;
        
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
        NSString *targetURL = [NSURL URLWithString:[cachesDir stringByAppendingPathComponent:filename]];
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
- (void) playTap:(UIButton *) sender
{
    NSError* error = nil;

    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recorder.url error:&error];
    _player.volume = 1.0f;
    _player.numberOfLoops = 0;
    _player.delegate = self;
    [_player play];
}
- (void) recordingTimerUpdate:(id) sender
{
    int minute = (int)(_recorder.currentTime / 60);
    int second = (int)(_recorder.currentTime) % 60;
    int micro = (int)(_recorder.currentTime * 100) % 100;
    self.recordLengthLabel.text = [NSString stringWithFormat:@"%02d:%02d.%02d", minute, second, micro];
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}

@end
