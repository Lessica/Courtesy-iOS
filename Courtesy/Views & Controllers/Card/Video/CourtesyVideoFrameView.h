//
//  CourtesyVideoFrameView.h
//  Courtesy
//
//  Created by Zheng on 3/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyImageFrameView.h"

@interface CourtesyVideoFrameView : CourtesyImageFrameView <UITextFieldDelegate>

@property (nonatomic, copy) NSURL *videoURL;
@property (nonatomic, strong) UIImageView *playBtn;
@property (nonatomic, strong) UIImageView *centerBtn;

@end
