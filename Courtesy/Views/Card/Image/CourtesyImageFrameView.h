//
//  CourtesyImageFrameView.h
//  Courtesy
//
//  Created by Zheng on 3/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "PECropViewController.h"

#define kImageFrameLabelHeight 24
#define kImageFrameLabelTextHeight 16
#define kImageFrameBorderWidth 6
#define kImageFrameBtnBorderWidth 16
#define kImageFrameBtnWidth 27
#define kImageFrameBtnInterval 12
#define kImageFrameMinHeight 80

@class CourtesyImageFrameView;

@protocol CourtesyImageFrameDelegate <NSObject>

@optional
- (void)imageFrameTapped:(CourtesyImageFrameView *)imageFrame;

@optional
- (void)imageFrameDidBeginEditing:(CourtesyImageFrameView *)imageFrame;

@optional
- (void)imageFrameShouldDeleted:(CourtesyImageFrameView *)imageFrame
                       animated:(BOOL)animated;

@optional
- (void)imageFrameShouldCropped:(CourtesyImageFrameView *)imageFrame;

@optional
- (void)imageFrameDidEndEditing:(CourtesyImageFrameView *)imageFrame;

@optional
- (void)imageFrameShouldReplaced:(CourtesyImageFrameView *)imageFrame
                              by:(UIImage *)image
                        userinfo:(NSDictionary *)userinfo;

@end

@interface CourtesyImageFrameView : UIView <UITextFieldDelegate, PECropViewControllerDelegate>
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIImage *centerImage;
@property (nonatomic, strong) UITextField *bottomLabel;
@property (nonatomic, weak) id<CourtesyImageFrameDelegate> delegate;
@property (nonatomic, assign) NSRange selfRange;
@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) UIImageView *deleteBtn;
@property (nonatomic, strong) UIImageView *editBtn;
@property (nonatomic, strong) UIImageView *cropBtn;
@property (nonatomic, assign) BOOL optionsOpen;
@property (nonatomic, assign) BOOL labelOpen;
@property (nonatomic, strong) NSArray *optionButtons;

- (void)toggleBottomLabelView:(BOOL)on;
- (NSString *)labelHolder;
- (void)frameTapped:(id)sender;
- (UIImageView *)centerBtn;

@end
