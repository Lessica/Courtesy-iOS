//
//  CourtesyAudioSheetView.h
//  Courtesy
//
//  Created by Zheng on 3/17/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourtesyCardModel.h"
#import "CourtesyCardComposeViewController.h"

@class CourtesyAudioSheetView;

@protocol CourtesyAudioSheetViewDelegate <NSObject>
@property (nonatomic, strong) CourtesyCardModel *card;

- (void)audioSheetViewRecordButtonTapped:(CourtesyAudioSheetView *)audioSheetView;
- (void)audioSheetViewMusicButtonTapped:(CourtesyAudioSheetView *)audioSheetView;

@end

@interface CourtesyAudioSheetView : UIView
@property (nonatomic, weak) CourtesyCardComposeViewController <CourtesyAudioSheetViewDelegate> *delegate;
- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController<CourtesyAudioSheetViewDelegate> *)viewController;

@end
