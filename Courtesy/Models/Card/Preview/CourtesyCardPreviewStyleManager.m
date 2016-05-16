//
//  CourtesyCardPreviewStyleManager.m
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPreviewStyleManager.h"

@implementation CourtesyCardPreviewStyleManager

+ (id)sharedManager {
    static CourtesyCardPreviewStyleManager *sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (NSArray <NSString *> *)previewNames {
    if (!_previewNames) {
        _previewNames = @[
                          @"经典锤子",
                          @"经典日历",
                          @"绿意盎然",
                          @"扑克牌",
                          @"悦动音符",
                          @"BLOOD",
                          // More Long Image Names
                          
                          ];
    }
    return _previewNames;
}

- (NSArray <UIImage *> *)previewImages {
    if (!_previewImages) {
        _previewImages = @[
                           [UIImage imageNamed:@"default-preview"],
                           [UIImage imageNamed:@"calendar-preview"],
                           [UIImage imageNamed:@"leaf-preview"],
                           [UIImage imageNamed:@"poker-preview"],
                           [UIImage imageNamed:@"melody-preview"],
                           [UIImage imageNamed:@"blood-preview"]
                           // More Long Image
                           
                           ];
    }
    return _previewImages;
}

- (NSArray <UIImage *> *)previewCheckmarks {
    if (!_previewCheckmarks) {
        _previewCheckmarks = @[
                               [UIImage imageNamed:@"default-checkmark"],
                               [UIImage imageNamed:@"calendar-checkmark"],
                               [UIImage imageNamed:@"leaf-checkmark"],
                               [UIImage imageNamed:@"poker-checkmark"],
                               [UIImage imageNamed:@"melody-checkmark"],
                               [UIImage imageNamed:@"blood-checkmark"]
                               // More Checkmark
                               
                               ];
    }
    return _previewCheckmarks;
}

- (CourtesyCardPreviewStyleModel *)previewStyleWithType:(CourtesyCardPreviewStyleType)type {
    if (type == kCourtesyCardPreviewStyleDefault)
    {
        CourtesyCardPreviewStyleModel *previewStyle = [CourtesyCardPreviewStyleModel new];
        previewStyle.previewCheckmark = [UIImage imageNamed:@"default-checkmark"];
        previewStyle.previewHeader = [UIImage imageNamed:@"default-preview-header"];
        previewStyle.previewBody = [UIImage imageNamed:@"default-preview-body"];
        previewStyle.previewFooter = [UIImage imageNamed:@"default-preview-footer"];
        previewStyle.previewFooterText = @"由礼记生成并发送 via Courtesy";
        previewStyle.bodyMethod = kCourtesyCardPreviewBodyStretch;
        previewStyle.originPoint = CGPointMake(0, 0);
        return previewStyle;
    }
    else if (type == kCourtesyCardPreviewStyleLeaf)
    {
        CourtesyCardPreviewStyleModel *previewStyle = [CourtesyCardPreviewStyleModel new];
        previewStyle.previewCheckmark = [UIImage imageNamed:@"leaf-checkmark"];
        previewStyle.previewHeader = [UIImage imageNamed:@"leaf-preview-header"];
        previewStyle.previewBody = [UIImage imageNamed:@"leaf-preview-body"];
        previewStyle.previewFooter = [UIImage imageNamed:@"leaf-preview-footer"];
        previewStyle.previewFooterText = @"由礼记生成并发送 via Courtesy";
        previewStyle.bodyMethod = kCourtesyCardPreviewBodyStretch;
        previewStyle.originPoint = CGPointMake(0, 0);
        return previewStyle;
    }
    else if (type == kCourtesyCardPreviewStylePoker)
    {
        CourtesyCardPreviewStyleModel *previewStyle = [CourtesyCardPreviewStyleModel new];
        previewStyle.previewCheckmark = [UIImage imageNamed:@"poker-checkmark"];
        previewStyle.previewHeader = [UIImage imageNamed:@"poker-preview-header"];
        previewStyle.previewBody = [UIImage imageNamed:@"poker-preview-body"];
        previewStyle.previewFooter = [UIImage imageNamed:@"poker-preview-footer"];
        previewStyle.previewFooterText = @"由礼记生成并发送 via Courtesy";
        previewStyle.bodyMethod = kCourtesyCardPreviewBodyRepeat;
        previewStyle.originPoint = CGPointMake(0, 0);
        return previewStyle;
    }
    else if (type == kCourtesyCardPreviewStyleMelody)
    {
        CourtesyCardPreviewStyleModel *previewStyle = [CourtesyCardPreviewStyleModel new];
        previewStyle.previewCheckmark = [UIImage imageNamed:@"melody-checkmark"];
        previewStyle.previewHeader = [UIImage imageNamed:@"melody-preview-header"];
        previewStyle.previewBody = [UIImage imageNamed:@"melody-preview-body"];
        previewStyle.previewFooter = [UIImage imageNamed:@"melody-preview-footer"];
        previewStyle.previewFooterText = @"由礼记生成并发送 via Courtesy";
        previewStyle.bodyMethod = kCourtesyCardPreviewBodyRepeat;
        previewStyle.originPoint = CGPointMake(8, 0);
        return previewStyle;
    }
    else if (type == kCourtesyCardPreviewStyleBlood)
    {
        CourtesyCardPreviewStyleModel *previewStyle = [CourtesyCardPreviewStyleModel new];
        previewStyle.previewCheckmark = [UIImage imageNamed:@"blood-checkmark"];
        previewStyle.previewHeader = [UIImage imageNamed:@"blood-preview-header"];
        previewStyle.previewBody = [UIImage imageNamed:@"blood-preview-body"];
        previewStyle.previewFooter = [UIImage imageNamed:@"blood-preview-footer"];
        previewStyle.previewFooterText = @"由礼记生成并发送 via Courtesy";
        previewStyle.bodyMethod = kCourtesyCardPreviewBodyStretch;
        previewStyle.originPoint = CGPointMake(0, 0);
        return previewStyle;
    }
    else if (type == kCourtesyCardPreviewStyleCalendar)
    {
        CourtesyCardPreviewStyleModel *previewStyle = [CourtesyCardPreviewStyleModel new];
        previewStyle.previewCheckmark = [UIImage imageNamed:@"calendar-checkmark"];
        previewStyle.previewHeader = [UIImage imageNamed:@"calendar-preview-header"];
        previewStyle.previewBody = [UIImage imageNamed:@"calendar-preview-body"];
        previewStyle.previewFooter = [UIImage imageNamed:@"calendar-preview-footer"];
        previewStyle.previewFooterText = @"由礼记生成并发送 via Courtesy";
        previewStyle.bodyMethod = kCourtesyCardPreviewBodyStretch;
        previewStyle.originPoint = CGPointMake(0, 0);
        return previewStyle;
    }
    return nil;
}

@end
