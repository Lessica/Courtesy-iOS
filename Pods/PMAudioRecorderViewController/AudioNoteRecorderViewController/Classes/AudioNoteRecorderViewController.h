//
//  AudioNoteRecordedViewController.h
//
//  Created by Pawel Maczewski on 29/01/14.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AudioNoteRecorderViewController;

typedef void (^AudioNoteRecorderFinishBlock) (BOOL wasRecordingTaken, NSURL *recordingURL) ;


@protocol AudioNoteRecorderDelegate <NSObject>

- (void) audioNoteRecorderDidCancel:(AudioNoteRecorderViewController *)audioNoteRecorder;
- (void) audioNoteRecorderDidTapDone:(AudioNoteRecorderViewController *)audioNoteRecorder withRecordedURL:(NSURL *) recordedURL;

@end

@interface AudioNoteRecorderViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, weak) id<AudioNoteRecorderDelegate> delegate;

@property (nonatomic, copy) AudioNoteRecorderFinishBlock finishedBlock;

//- (id) initWithMasterViewController:(UIViewController *) masterViewController;

+ (id) showRecorderWithMasterViewController:(UIViewController *) masterViewController withDelegate:(id<AudioNoteRecorderDelegate>) delegate;
+ (id) showRecorderMasterViewController:(UIViewController *) masterViewController withFinishedBlock:(AudioNoteRecorderFinishBlock) finishedBlock;

@end
