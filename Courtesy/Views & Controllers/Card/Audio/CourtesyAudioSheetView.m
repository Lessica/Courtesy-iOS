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
        
        self.backgroundColor = self.style.toolbarColor;
        self.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        self.layer.borderWidth = 0.5;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height)];
        leftView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        leftView.layer.borderWidth = 0.5;
        [self addSubview:leftView];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 0.5, 0, self.frame.size.width / 2, self.frame.size.height)];
        rightView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        rightView.layer.borderWidth = 0.5;
        [self addSubview:rightView];
        
        UIButton *recordBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, leftView.frame.size.width / 4, leftView.frame.size.width / 4)];
        recordBtn.tintColor = self.style.toolbarTintColor;
        recordBtn.backgroundColor = [UIColor clearColor];
        recordBtn.center = CGPointMake(leftView.frame.size.width / 2, leftView.frame.size.height / 2);
        [recordBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [recordBtn setImage:[[UIImage imageNamed:@"52-record-btn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [recordBtn addTarget:self.delegate action:@selector(audioSheetViewRecordButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:recordBtn];
        
        UIButton *musicBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rightView.frame.size.width / 4, rightView.frame.size.width / 4)];
        musicBtn.tintColor = self.style.toolbarTintColor;
        musicBtn.backgroundColor = [UIColor clearColor];
        musicBtn.center = CGPointMake(rightView.frame.size.width / 2, rightView.frame.size.height / 2);
        [musicBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [musicBtn setImage:[[UIImage imageNamed:@"53-music-btn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [musicBtn addTarget:self.delegate action:@selector(audioSheetViewMusicButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:musicBtn];
    }
    return self;
}

- (void)dealloc {
    CYLog(@"");
}

@end
