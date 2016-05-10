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


- (NSArray <NSString *> *)styleNames {
    if (!_styleNames) {
        _styleNames = @[
                          @"经典白",
                          @"酷炫灰",
                          // More Long Image Names
                          
                          ];
    }
    return _styleNames;
}

- (NSArray <UIImage *> *)styleImages {
    if (!_styleImages) {
        _styleImages = @[
                           [UIImage imageNamed:@"default-style"],
                           [UIImage imageNamed:@"dark-style"],
                           // More Long Image
                           
                           ];
    }
    return _styleImages;
}

- (NSArray <UIImage *> *)styleCheckmarks {
    if (!_styleCheckmarks) {
        _styleCheckmarks = @[
                               [UIImage imageNamed:@"default-checkmark-2"],
                               [UIImage imageNamed:@"dark-checkmark"],
                               // More Checkmark
                               
                               ];
    }
    return _styleCheckmarks;
}

- (CourtesyCardStyleModel *)styleWithID:(CourtesyCardStyleID)styleID {
    if (styleID == kCourtesyCardStyleDefault) {
        CourtesyCardStyleModel *newStyle = [CourtesyCardStyleModel new];
        
        newStyle.cardBorderColor = [UIColor coolGrayColor];
        
        newStyle.statusBarColor = [UIColor blackColor];
        newStyle.buttonTintColor = [UIColor whiteColor];
        newStyle.buttonBackgroundColor = [UIColor blackColor];
        
        newStyle.toolbarColor = [UIColor whiteColor];
        newStyle.toolbarBarTintColor = [UIColor whiteColor];
        newStyle.toolbarTintColor = [UIColor grayColor];
        newStyle.toolbarHighlightColor = [UIColor blueberryColor];
        
        newStyle.cardTextColor = [UIColor darkGrayColor];
        newStyle.cardLineSpacing = 8.0;
        newStyle.cardBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"default-texture"]];
        newStyle.cardLineHeight = 32.0;
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
        newStyle.cardCreateTimeFormat = @"yy年LLLd日 EEEE ah:mm";
        newStyle.maxAudioNum = 3;
        newStyle.maxVideoNum = 3;
        newStyle.maxImageNum = 20;
        newStyle.maxContentLength = 4096;
        
        newStyle.headerFontSize = [NSNumber numberWithFloat:20.0];
        newStyle.controlTextColor = [UIColor magicColor];
        newStyle.headerTextColor = [UIColor blackColor];
        newStyle.inlineTextColor = newStyle.cardTextColor;
        newStyle.codeTextColor = newStyle.cardTextColor;
        newStyle.linkTextColor = [UIColor blueberryColor];
        
        newStyle.jotColorArray = @[];
        
        newStyle.darkStyle = NO;
        return newStyle;
    } else if (styleID == kCourtesyCardStyleDark) {
        CourtesyCardStyleModel *newStyle = [CourtesyCardStyleModel new];
        
        newStyle.cardBorderColor = [UIColor coolGrayColor];
        
        newStyle.statusBarColor = [UIColor blackColor];
        newStyle.buttonTintColor = [UIColor blackColor];
        newStyle.buttonBackgroundColor = [UIColor whiteColor];
        
        newStyle.toolbarColor = [UIColor whiteColor];
        newStyle.toolbarBarTintColor = [UIColor whiteColor];
        newStyle.toolbarTintColor = [UIColor grayColor];
        newStyle.toolbarHighlightColor = [UIColor blueberryColor];
        
        newStyle.cardTextColor = [UIColor whiteColor];
        newStyle.cardLineSpacing = 8.0;
        newStyle.cardBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark-texture"]];
        newStyle.cardLineHeight = 32.0;
        newStyle.placeholderText = @"说点什么吧……";
        newStyle.placeholderColor = [UIColor lightGrayColor];
        newStyle.indicatorColor = [UIColor whiteColor];
        
        newStyle.cardTitleFontSize = 12.0;
        newStyle.dateLabelTextColor = [UIColor whiteColor];
        newStyle.standardAlpha = 0.80;
        
        newStyle.cardElementBackgroundColor = [UIColor colorWithWhite:0.22 alpha:0.66];
        newStyle.cardElementTintColor = [UIColor lightGrayColor];
        newStyle.cardElementTintFocusColor = [UIColor grayColor];
        newStyle.cardElementTextColor = [UIColor whiteColor];
        newStyle.cardElementShadowColor = [UIColor clearColor];
        
        newStyle.defaultAnimationDuration = 0.5;
        newStyle.cardCreateTimeFormat = @"公元 yyyy年LLLd日 EEEE ah:mm";
        newStyle.maxAudioNum = 3;
        newStyle.maxVideoNum = 3;
        newStyle.maxImageNum = 20;
        newStyle.maxContentLength = 4096;
        
        newStyle.headerFontSize = [NSNumber numberWithFloat:20.0];
        newStyle.controlTextColor = [UIColor magicColor];
        newStyle.headerTextColor = [UIColor whiteColor];
        newStyle.inlineTextColor = newStyle.cardTextColor;
        newStyle.codeTextColor = newStyle.cardTextColor;
        newStyle.linkTextColor = [UIColor skyBlueColor];
        
        newStyle.jotColorArray = @[];
        newStyle.darkStyle = YES;
        return newStyle;
    }
    return nil;
}

@end
