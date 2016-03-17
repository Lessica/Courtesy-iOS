//
//  CourtesyImageSheetView.h
//  Courtesy
//
//  Created by Zheng on 3/17/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourtesyCardModel.h"
#import "CourtesyCardComposeViewController.h"

@class CourtesyImageSheetView;

@protocol CourtesyImageSheetViewDelegate <NSObject>
@property (nonatomic, strong) CourtesyCardModel *card;

- (void)imageSheetViewCameraButtonTapped:(CourtesyImageSheetView *)imageSheetView;
- (void)imageSheetViewAlbumButtonTapped:(CourtesyImageSheetView *)imageSheetView;

@end

@interface CourtesyImageSheetView : UIView
@property (nonatomic, weak) CourtesyCardComposeViewController <CourtesyImageSheetViewDelegate> *delegate;
@property (nonatomic, strong) CourtesyCardModel *card;
- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController<CourtesyImageSheetViewDelegate> *)viewController;

@end
