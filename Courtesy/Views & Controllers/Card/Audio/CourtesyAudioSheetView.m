//
//  CourtesyAudioSheetView.m
//  Courtesy
//
//  Created by Zheng on 3/17/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAudioSheetView.h"

@implementation CourtesyAudioSheetView

- (CourtesyCardDataModel *)cdata {
    return self.delegate.card.local_template;
}

- (CourtesyCardStyleModel *)style {
    return self.delegate.card.local_template.style;
}

- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController<CourtesyAudioSheetViewDelegate> *)viewController {
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
        [leftView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(audioSheetViewRecordButtonTapped:)]];
        [self addSubview:leftView];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 0.5, 0, self.frame.size.width / 2, self.frame.size.height)];
        rightView.layer.borderColor = cgColor;
        rightView.layer.borderWidth = 0.5;
        [rightView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(audioSheetViewMusicButtonTapped:)]];
        [self addSubview:rightView];
        
        UIButton *recordBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, leftView.frame.size.width / 4, leftView.frame.size.width / 4)];
        recordBtn.tintColor = self.style.toolbarTintColor;
        recordBtn.backgroundColor = [UIColor clearColor];
        recordBtn.center = CGPointMake(leftView.frame.size.width / 2, leftView.frame.size.height / 2);
        [recordBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [recordBtn setImage:[[UIImage imageNamed:@"52-record-btn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [recordBtn addTarget:self.delegate action:@selector(audioSheetViewRecordButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:recordBtn];
        
        UILabel *leftViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, recordBtn.bottom, leftView.frame.size.width, 24)];
        leftViewLabel.text = @"录音机";
        leftViewLabel.textColor = self.style.toolbarTintColor;
        leftViewLabel.font = [UIFont systemFontOfSize:12.0];
        leftViewLabel.textAlignment = NSTextAlignmentCenter;
        [leftView addSubview:leftViewLabel];
        
        UIButton *musicBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rightView.frame.size.width / 4, rightView.frame.size.width / 4)];
        musicBtn.tintColor = self.style.toolbarTintColor;
        musicBtn.backgroundColor = [UIColor clearColor];
        musicBtn.center = CGPointMake(rightView.frame.size.width / 2, rightView.frame.size.height / 2);
        [musicBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [musicBtn setImage:[[UIImage imageNamed:@"53-music-btn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [musicBtn addTarget:self.delegate action:@selector(audioSheetViewMusicButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:musicBtn];
        
        UILabel *rightViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, musicBtn.bottom, rightView.frame.size.width, 24)];
        rightViewLabel.text = @"音乐库";
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
