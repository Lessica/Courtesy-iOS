//
//  CourtesyVideoSheetView.m
//  Courtesy
//
//  Created by Zheng on 3/17/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyVideoSheetView.h"

@implementation CourtesyVideoSheetView

- (CourtesyCardDataModel *)cdata {
    return self.delegate.card.local_template;
}

- (CourtesyCardStyleModel *)style {
    return self.delegate.card.local_template.style;
}

- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController<CourtesyVideoSheetViewDelegate> *)viewController {
    if (self = [super initWithFrame:frame]) {
        self.delegate = viewController;
        
        self.backgroundColor = self.style.toolbarColor;
        self.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        self.layer.borderWidth = 0.5;
        
        UIView *leftUpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height / 2)];
        leftUpView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        leftUpView.layer.borderWidth = 0.5;
        [leftUpView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(videoSheetViewShortCameraButtonTapped:)]];
        [self addSubview:leftUpView];
        
        UIView *leftDownView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 2 - 0.5, self.frame.size.width / 2, self.frame.size.height / 2)];
        leftDownView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        leftDownView.layer.borderWidth = 0.5;
        [leftDownView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(videoSheetViewCameraButtonTapped:)]];
        [self addSubview:leftDownView];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 0.5, 0, self.frame.size.width / 2, self.frame.size.height)];
        rightView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        rightView.layer.borderWidth = 0.5;
        [rightView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(videoSheetViewAlbumButtonTapped:)]];
        [self addSubview:rightView];
        
        UIButton *shortCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, leftUpView.frame.size.width / 4, leftUpView.frame.size.width / 4)];
        shortCameraBtn.tintColor = self.style.toolbarTintColor;
        shortCameraBtn.backgroundColor = [UIColor clearColor];
        shortCameraBtn.center = CGPointMake(leftUpView.frame.size.width / 2, leftUpView.frame.size.height / 2);
        [shortCameraBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [shortCameraBtn setImage:[[UIImage imageNamed:@"58-wechat-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [shortCameraBtn addTarget:self.delegate action:@selector(videoSheetViewShortCameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [leftUpView addSubview:shortCameraBtn];
        
        UIButton *cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, leftUpView.frame.size.width / 4, leftUpView.frame.size.width / 4)];
        cameraBtn.tintColor = self.style.toolbarTintColor;
        cameraBtn.backgroundColor = [UIColor clearColor];
        cameraBtn.center = CGPointMake(leftUpView.frame.size.width / 2, leftUpView.frame.size.height / 2);
        [cameraBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cameraBtn setImage:[[UIImage imageNamed:@"55-video-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [cameraBtn addTarget:self.delegate action:@selector(videoSheetViewCameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [leftDownView addSubview:cameraBtn];
        
        UIButton *albumBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rightView.frame.size.width / 4, rightView.frame.size.width / 4)];
        albumBtn.tintColor = self.style.toolbarTintColor;
        albumBtn.backgroundColor = [UIColor clearColor];
        albumBtn.center = CGPointMake(rightView.frame.size.width / 2, rightView.frame.size.height / 2);
        [albumBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [albumBtn setImage:[[UIImage imageNamed:@"56-video-album"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [albumBtn addTarget:self.delegate action:@selector(videoSheetViewAlbumButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:albumBtn];
    }
    return self;
}

- (void)dealloc {
    CYLog(@"");
}

@end
