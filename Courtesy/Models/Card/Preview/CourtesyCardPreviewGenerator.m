//
//  CourtesyCardPreviewGenerator.m
//  Courtesy
//
//  Created by Zheng on 3/11/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPreviewGenerator.h"

@implementation CourtesyCardPreviewGenerator

- (CourtesyCardPreviewStyleModel *)previewStyle {
    if (!_previewStyle) {
        _previewStyle = [[CourtesyCardPreviewStyleManager sharedManager] previewStyleWithType:[sharedSettings preferredPreviewStyleType]];
    }
    return _previewStyle;
}

- (void)generate {
    if (!self.contentView) return;
    
    @autoreleasepool {
        
        BOOL needShadows = [sharedSettings switchPreviewNeedsShadows];
        
        UIImage *preview_head   = self.previewStyle.previewHeader,
                *preview_body   = self.previewStyle.previewBody,
                *preview_footer = self.previewStyle.previewFooter,
                *finalImage     = nil;
        __block UIImage *header         = nil,
                        *content        = nil;
        
        CGSize contentSize      = self.contentView.bounds.size,                                        // 内容尺寸
               headerSize       = self.headerView.bounds.size;                                         // 作者信息头部尺寸
        
        CGFloat headerWidth     = headerSize.width,                                                    // 作者信息头部宽度
                headerHeight    = headerSize.height,                                                   // 作者信息头部高度
                screenWidth     = [UIScreen mainScreen].bounds.size.width,                             // 屏幕宽度
                contentWidth    = screenWidth - 64,                                                    // 内容设定宽度
                contentScale    = contentSize.width / contentWidth,                                    // 内容缩放比例
                contentHeight   = contentSize.height / contentScale,                                   // 内容高度
                headScale       = preview_head.size.width / screenWidth,                               // 边框头部缩放比例
                headHeight      = (preview_head.size.height) / headScale,                              // 边框头部高度
                footerScale     = preview_footer.size.width / screenWidth,                             // 边框尾部缩放比例
                footerHeight    = (preview_footer.size.height) / footerScale,                          // 边框尾部高度
                headerX         = (screenWidth - headerWidth) / 2 + self.previewStyle.originPoint.x,   // 作者信息头部横坐标
                contentX        = 32 + self.previewStyle.originPoint.x,                                // 内容横坐标
                totalHeight     = (headerHeight + contentHeight + headHeight + footerHeight),          // 总高度
                bodyScale       = preview_body.size.width / screenWidth,                               // 中部缩放比例
                bodyHeight      = (preview_body.size.height) / bodyScale,                              // 中部高度
                startY          = headHeight;                                                          // 起始渲染点
        
        NSUInteger bodyRepeatTimes = (NSUInteger)((headerHeight + contentHeight) / bodyHeight);        // 中部重复次数
        
        CGFloat finalY = startY + bodyRepeatTimes * bodyHeight;                                        // 终止渲染点
        
        dispatch_sync_on_main_queue(^{
            UIGraphicsBeginImageContextWithOptions(contentSize, NO, 0.0);
            if (needShadows) {
                [self.contentView.layer setLayerShadow:self.tintColor offset:CGSizeMake(-0.5, 0.5) radius:2.0];
            }
            [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
            content = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (needShadows) {
                [self.contentView.layer setLayerShadow:[UIColor clearColor] offset:CGSizeMake(0, 0) radius:0];
            }
        });
        
        if ([sharedSettings switchPreviewAvatar])
        {
            dispatch_sync_on_main_queue(^{
                UIGraphicsBeginImageContextWithOptions(headerSize, NO, 0.0);
                if (needShadows) {
                    [self.headerView.layer setLayerShadow:self.tintColor offset:CGSizeMake(-0.5, 0.5) radius:2.0];
                }
                [self.headerView.layer renderInContext:UIGraphicsGetCurrentContext()];
                header = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                if (needShadows) {
                    [self.headerView.layer setLayerShadow:[UIColor clearColor] offset:CGSizeMake(0, 0) radius:0];
                }
            });
        }
        else
        {
            headerWidth  = 0;
            headerHeight = 0;
            totalHeight  = (CGFloat)(contentHeight + headHeight + footerHeight);
        }
        
        if (self.previewStyle.bodyMethod == kCourtesyCardPreviewBodyStretch)
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(screenWidth, totalHeight), NO, 0.0);
            [preview_head drawInRect:CGRectMake(0, 0, screenWidth, headHeight)];
            [preview_body drawInRect:CGRectMake(0, headHeight, screenWidth, headerHeight + contentHeight)];
            [preview_footer drawInRect:CGRectMake(0, headHeight + headerHeight + contentHeight, screenWidth, footerHeight)];
            if (header) [header drawInRect:CGRectMake(headerX, headHeight, headerWidth, headerHeight)];
            if (content) [content drawInRect:CGRectMake(contentX, headHeight + headerHeight, contentWidth, contentHeight)];
            finalImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else if (self.previewStyle.bodyMethod == kCourtesyCardPreviewBodyRepeat)
        {
            totalHeight = (CGFloat)(bodyHeight * bodyRepeatTimes + headHeight + footerHeight);
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(screenWidth, totalHeight), NO, 0.0);
            [preview_head drawInRect:CGRectMake(0, 0, screenWidth, headHeight)];
            for (int i = 0; i < bodyRepeatTimes; i++)
                [preview_body drawInRect:CGRectMake(0, startY + i * bodyHeight, screenWidth, bodyHeight + 0.25f)];
            [preview_footer drawInRect:CGRectMake(0, finalY, screenWidth, footerHeight)];
            if (header) [header drawInRect:CGRectMake(headerX, headHeight, headerWidth, headerHeight)];
            if (content) [content drawInRect:CGRectMake(contentX, headHeight + headerHeight, contentWidth, contentHeight)];
            finalImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        if (
            self.delegate &&
            [self.delegate respondsToSelector:@selector(generatorDidFinishWorking:result:)]
            )
        {
            [self.delegate generatorDidFinishWorking:self
                                              result:finalImage];
        }
    }
}

@end
