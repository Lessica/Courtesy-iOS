//
//  AudioNoteRecordedViewController.h
//
//  Created by Pawel Maczewski on 29/01/14.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CourtesyCardModel.h"
#import "CourtesyCardComposeViewController.h"

@class CourtesyAudioNoteRecorderView;

@protocol CourtesyAudioNoteRecorderDelegate <NSObject>
@property (nonatomic, strong) CourtesyCardModel *card;

- (void) audioNoteRecorderDidCancel:(CourtesyAudioNoteRecorderView *)audioNoteRecorder;
- (void) audioNoteRecorderDidTapDone:(CourtesyAudioNoteRecorderView *)audioNoteRecorder withRecordedURL:(NSURL *) recordedURL;

@end

@interface CourtesyAudioNoteRecorderView : UIView <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (nonatomic, weak) CourtesyCardComposeViewController <CourtesyAudioNoteRecorderDelegate> *delegate;
- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController<CourtesyAudioNoteRecorderDelegate> *)viewController;

@end
