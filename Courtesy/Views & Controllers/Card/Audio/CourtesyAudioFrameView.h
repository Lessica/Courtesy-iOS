//
//  CourtesyAudioFrameView.h
//  Courtesy
//
//  Created by Zheng on 3/7/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "FDWaveformView.h"
#import "AFSoundManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CourtesyCardModel.h"
#import "CourtesyCardAttachmentModel.h"
#import "CourtesyCardComposeViewController.h"

#define kAudioFrameLabelHeight 32
#define kAudioFrameLabelTextHeight 24
#define kAudioFrameBorderWidth 6
#define kAudioFrameBtnWidth 44
#define kAudioFrameBtnInterval 12

@class CourtesyAudioFrameView;

@protocol CourtesyAudioFrameDelegate <NSObject>
@property (nonatomic, strong) CourtesyCardModel *card;

@optional
- (void)audioFrameTapped:(CourtesyAudioFrameView *)audioFrame;

@optional
- (void)audioFrameDidBeginPlaying:(CourtesyAudioFrameView *)audioFrame;

@optional
- (void)audioFrameDidEndPlaying:(CourtesyAudioFrameView *)audioFrame;

@optional
- (void)audioFrameDidBeginEditing:(CourtesyAudioFrameView *)audioFrame;

@optional
- (void)audioFrameDidEndEditing:(CourtesyAudioFrameView *)audioFrame;

@optional
- (void)audioFrameShouldDeleted:(CourtesyAudioFrameView *)audioFrame
                       animated:(BOOL)animated;

@end

@interface CourtesyAudioFrameView : UIView <UITextFieldDelegate, FDWaveformViewDelegate>
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak)   CourtesyCardComposeViewController<CourtesyAudioFrameDelegate> *delegate;
@property (nonatomic, assign) NSUInteger bindingLength;
@property (nonatomic, strong, readonly) NSDictionary *userinfo;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) FDWaveformView *waveform;
@property (nonatomic, strong) AFSoundItem *audioItem;
@property (nonatomic, strong) AFSoundPlayback *audioQueue;
@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, assign) float scale;

- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController <CourtesyAudioFrameDelegate>*)delegate
                  andUserinfo:(NSDictionary *)userinfo;
- (void)pausePlaying;
@end
