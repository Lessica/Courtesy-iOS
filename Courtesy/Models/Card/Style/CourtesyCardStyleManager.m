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
        
        newStyle.cardFontSize = 16.0;
        newStyle.cardFont = [UIFont systemFontOfSize:newStyle.cardFontSize];
        newStyle.cardFontType = kCourtesyFontDefault;
        newStyle.cardTextColor = [UIColor darkGrayColor];
        newStyle.cardLineSpacing = 8.0;
        newStyle.cardBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture"]];
        newStyle.cardLineHeight = 28.0;
        newStyle.placeholderText = @"说点什么吧……";
        newStyle.placeholderColor = [UIColor lightGrayColor];
        newStyle.indicatorColor = [UIColor darkGrayColor];
        
        newStyle.cardTitleFontSize = 12.0;
        newStyle.dateLabelTextColor = [UIColor darkGrayColor];
        newStyle.standardAlpha = 0.618;
        
        newStyle.cardElementBackgroundColor = [UIColor whiteColor];
        newStyle.cardElementTintColor = [UIColor darkGrayColor];
        newStyle.cardElementTintFocusColor = [UIColor grayColor];
        newStyle.cardElementTextColor = [UIColor darkGrayColor];
        newStyle.cardElementShadowColor = [UIColor blackColor];
        
        newStyle.defaultAnimationDuration = 0.5;
        newStyle.cardCreateTimeFormat = @"yyyy年M月d日 EEEE ah:mm";
        newStyle.maxAudioNum = 1;
        newStyle.maxVideoNum = 1;
        newStyle.maxImageNum = 10;
        newStyle.maxContentLength = 4096;
        
        newStyle.headerFontSize = [NSNumber numberWithFloat:20.0];
        newStyle.controlTextColor = [UIColor indigoColor];
        newStyle.headerTextColor = [UIColor blackColor];
        newStyle.inlineTextColor = newStyle.cardTextColor;
        newStyle.codeTextColor = newStyle.cardTextColor;
        newStyle.linkTextColor = [UIColor blueberryColor];
        
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
