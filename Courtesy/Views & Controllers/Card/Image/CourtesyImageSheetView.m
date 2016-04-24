//
//  CourtesyImageSheetView.m
//  Courtesy
//
//  Created by Zheng on 3/17/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyImageSheetView.h"

@implementation CourtesyImageSheetView

- (CourtesyCardDataModel *)cdata {
    return self.delegate.card.local_template;
}

- (CourtesyCardStyleModel *)style {
    return self.delegate.card.local_template.style;
}

- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController<CourtesyImageSheetViewDelegate> *)viewController {
    if (self = [super initWithFrame:frame]) {
        self.delegate = viewController;
        
        UIColor *color = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        CGColorRef cgColor = color.CGColor;
        
        self.backgroundColor = self.style.toolbarColor;
        self.layer.borderColor = cgColor;
        self.layer.borderWidth = 0.5;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height)];
        leftView.layer.borderColor = cgColor;
        leftView.layer.borderWidth = 0.5;
        [leftView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(imageSheetViewCameraButtonTapped:)]];
        [self addSubview:leftView];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 0.5, 0, self.frame.size.width / 2, self.frame.size.height)];
        rightView.layer.borderColor = cgColor;
        rightView.layer.borderWidth = 0.5;
        [rightView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(imageSheetViewAlbumButtonTapped:)]];
        [self addSubview:rightView];
        
        UIButton *cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, leftView.frame.size.width / 4, leftView.frame.size.width / 4)];
        cameraBtn.tintColor = self.style.toolbarTintColor;
        cameraBtn.backgroundColor = [UIColor clearColor];
        cameraBtn.center = CGPointMake(leftView.frame.size.width / 2, leftView.frame.size.height / 2);
        [cameraBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cameraBtn setImage:[[UIImage imageNamed:@"54-photo-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [cameraBtn addTarget:self.delegate action:@selector(imageSheetViewCameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:cameraBtn];
        
        UILabel *leftViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, cameraBtn.bottom, leftView.frame.size.width, 24)];
        leftViewLabel.text = @"照相机";
        leftViewLabel.textColor = self.style.toolbarTintColor;
        leftViewLabel.font = [UIFont systemFontOfSize:12.0];
        leftViewLabel.textAlignment = NSTextAlignmentCenter;
        [leftView addSubview:leftViewLabel];
        
        UIButton *albumBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rightView.frame.size.width / 4, rightView.frame.size.width / 4)];
        albumBtn.tintColor = self.style.toolbarTintColor;
        albumBtn.backgroundColor = [UIColor clearColor];
        albumBtn.center = CGPointMake(rightView.frame.size.width / 2, rightView.frame.size.height / 2);
        [albumBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [albumBtn setImage:[[UIImage imageNamed:@"57-photo-album"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [albumBtn addTarget:self.delegate action:@selector(imageSheetViewAlbumButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:albumBtn];
        
        UILabel *rightViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, albumBtn.bottom, rightView.frame.size.width, 24)];
        rightViewLabel.text = @"图片相册";
        rightViewLabel.textColor = self.style.toolbarTintColor;
        rightViewLabel.font = [UIFont systemFontOfSize:12.0];
        rightViewLabel.textAlignment = NSTextAlignmentCenter;
        [rightView addSubview:rightViewLabel];
    }
    return self;
}

- (void)dealloc {
    CYLog(@"");
}

@end
