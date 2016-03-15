//
//  CourtesyImageFrameView.h
//  Courtesy
//
//  Created by Zheng on 3/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "PECropViewController.h"
#import "CourtesyCardAttachmentModel.h"

#define kImageFrameLabelHeight 24
#define kImageFrameLabelTextHeight 16
#define kImageFrameBorderWidth 6
#define kImageFrameBtnBorderWidth 16
#define kImageFrameBtnWidth 27
#define kImageFrameBtnInterval 12
#define kImageFrameMinHeight 72

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
@property (nonatomic, strong) YYAnimatedImageView *centerImageView;
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
@property (nonatomic, assign, getter=isEditable) BOOL editable;
@property (nonatomic, strong) UIColor *cardBackgroundColor;
@property (nonatomic, strong) UIColor *cardTintColor;
@property (nonatomic, strong) UIColor *cardTextColor;
@property (nonatomic, strong) UIColor *cardShadowColor;
@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, assign) NSUInteger standardLineHeight;
@property (nonatomic, strong) NSURL *originalImageURL;

- (void)toggleBottomLabelView:(BOOL)on
                     animated:(BOOL)animated;
- (NSString *)labelHolder;
- (void)frameTapped:(id)sender;
- (UIImageView *)centerBtn;

@end
