//
//  CourtesyCardStyleManager.m
//  Courtesy
//
//  Created by Zheng on 3/14/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardStyleManager.h"

@implementation CourtesyCardStyleManager

+ (id)sharedManager {
    static CourtesyCardStyleManager *sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (CourtesyCardStyleModel *)styleWithID:(CourtesyCardStyleID)styleID {
    if (styleID == kCourtesyCardStyleDefault) {
        CourtesyCardStyleModel *newStyle = [CourtesyCardStyleModel new];
        
        newStyle.statusBarColor = [UIColor blackColor];
        newStyle.buttonTintColor = [UIColor whiteColor];
        newStyle.buttonBackgroundColor = [UIColor blackColor];
        
        newStyle.toolbarColor = [UIColor whiteColor];
        newStyle.toolbarBarTintColor = [UIColor whiteColor];
        newStyle.toolbarTintColor = [UIColor grayColor];
        
        newStyle.cardFontSize = [NSNumber numberWithFloat:16.0];
        newStyle.cardFont = [UIFont systemFontOfSize:[newStyle.cardFontSize floatValue]];
        newStyle.cardFontType = kCourtesyFontDefault;
        newStyle.cardTextColor = [UIColor darkGrayColor];
        newStyle.cardLineSpacing = [NSNumber numberWithFloat:8.0];
        newStyle.cardBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture"]];
        newStyle.cardLineHeight = [NSNumber numberWithFloat:28.0];
        newStyle.placeholderText = @"说点什么吧……";
        newStyle.placeholderColor = [UIColor lightGrayColor];
        newStyle.indicatorColor = [UIColor darkGrayColor];
        
        newStyle.cardTitleFontSize = [NSNumber numberWithFloat:12.0];
        newStyle.dateLabelTextColor = [UIColor darkGrayColor];
        newStyle.standardAlpha = [NSNumber numberWithFloat:0.618];
        
        newStyle.cardElementBackgroundColor = [UIColor whiteColor];
        newStyle.cardElementTintColor = [UIColor darkGrayColor];
        newStyle.cardElementTintFocusColor = [UIColor grayColor];
        newStyle.cardElementTextColor = [UIColor darkGrayColor];
        newStyle.cardElementShadowColor = [UIColor blackColor];
        
        newStyle.defaultAnimationDuration = [NSNumber numberWithFloat:0.5];
        newStyle.cardCreateTimeFormat = @"yyyy年M月d日 EEEE ah:mm";
        newStyle.maxAudioNum = [NSNumber numberWithInt:1];
        newStyle.maxVideoNum = [NSNumber numberWithInt:1];
        newStyle.maxImageNum = [NSNumber numberWithInt:10];
        newStyle.maxContentLength = [NSNumber numberWithInt:8192];
        
        newStyle.previewStyle = [CourtesyPreviewStyleModel new];
        newStyle.previewStyle.previewHeader = [UIImage imageNamed:@"preview-head"];
        newStyle.previewStyle.previewBody = [UIImage imageNamed:@"preview-body"];
        newStyle.previewStyle.previewFooter = [UIImage imageNamed:@"preview-footer"];
        newStyle.previewStyle.previewFooterText = @"由礼记生成并发送";
        newStyle.previewStyle.previewFooterOrigin = CGPointMake(0, 0);
        newStyle.previewStyle.previewFooterAttributes = @{};
        return newStyle;
    }
    return nil;
}

@end
