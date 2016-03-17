//
//  CourtesyVideoSheetView.h
//  Courtesy
//
//  Created by Zheng on 3/17/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourtesyCardModel.h"
#import "CourtesyCardComposeViewController.h"

@class CourtesyVideoSheetView;

@protocol CourtesyVideoSheetViewDelegate <NSObject>
@property (nonatomic, strong) CourtesyCardModel *card;

- (void)videoSheetViewCameraButtonTapped:(CourtesyVideoSheetView *)videoSheetView;
- (void)videoSheetViewShortCameraButtonTapped:(CourtesyVideoSheetView *)videoSheetView;
- (void)videoSheetViewAlbumButtonTapped:(CourtesyVideoSheetView *)videoSheetView;

@end

@interface CourtesyVideoSheetView : UIView
@property (nonatomic, weak) CourtesyCardComposeViewController <CourtesyVideoSheetViewDelegate> *delegate;
- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController<CourtesyVideoSheetViewDelegate> *)viewController;

@end