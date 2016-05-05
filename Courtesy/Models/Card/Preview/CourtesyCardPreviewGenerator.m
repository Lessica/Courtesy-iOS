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
    if (!self.contentView) {
        return;
    }
    @autoreleasepool {
        // TODO: Edit footer text
        UIImage *preview_head = self.previewStyle.previewHeader;
        UIImage *preview_body = self.previewStyle.previewBody;
        UIImage *preview_footer = self.previewStyle.previewFooter;
        
        CGSize headerSize = self.headerView.bounds.size;
        UIGraphicsBeginImageContextWithOptions(headerSize, NO, 0.0);
        [self.headerView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *header = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGSize contentSize = self.contentView.bounds.size;
        UIGraphicsBeginImageContextWithOptions(contentSize, NO, 0.0);
        [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *content = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        CGFloat headerWidth = (CGFloat)headerSize.width;
        CGFloat headerHeight = (CGFloat)headerSize.height;
        
        CGFloat contentWidth = (CGFloat)screenWidth - 64;
        CGFloat contentScale = (CGFloat)contentSize.width / contentWidth;
        CGFloat contentHeight = (CGFloat)contentSize.height / contentScale;
        
        CGFloat headScale = (CGFloat)preview_head.size.width / screenWidth;
        CGFloat headHeight = (CGFloat)(preview_head.size.height) / headScale;
        
        CGFloat footerScale = (CGFloat)preview_footer.size.width / screenWidth;
        CGFloat footerHeight = (CGFloat)(preview_footer.size.height) / footerScale;
        
        CGFloat totalHeight = (CGFloat)(headerHeight + contentHeight + headHeight + footerHeight);
        
        CGFloat bodyScale = (CGFloat)preview_body.size.width / screenWidth;
        CGFloat bodyHeight = (CGFloat)(preview_body.size.height) / bodyScale;
        
        NSUInteger bodyRepeatTimes = (NSUInteger)((headerHeight + contentHeight) / bodyHeight);
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(screenWidth, totalHeight), NO, 0.0);
        [preview_head drawInRect:CGRectMake(0, 0, screenWidth, headHeight)];
        if (self.previewStyle.bodyMethod == kCourtesyCardPreviewBodyStretch) {
            [preview_body drawInRect:CGRectMake(0, headHeight, screenWidth, contentHeight)];
            [preview_footer drawInRect:CGRectMake(0, headHeight + contentHeight, screenWidth, footerHeight)];
        } else if (self.previewStyle.bodyMethod == kCourtesyCardPreviewBodyRepeat) {
            CGFloat startY = headHeight;
            for (int i = 0; i < bodyRepeatTimes; i++) {
                [preview_body drawInRect:CGRectMake(0, startY + i * bodyHeight, screenWidth, bodyHeight + 0.20f)];
            }
            CGFloat finalY = startY + bodyRepeatTimes * bodyHeight;
            [preview_footer drawInRect:CGRectMake(0, finalY, screenWidth, footerHeight)];
        }
        
        CGFloat headerX = (screenWidth - headerWidth) / 2 + self.previewStyle.originPoint.x;
        CGFloat contentX = 32 + self.previewStyle.originPoint.x;
        
        [header drawInRect:CGRectMake(headerX, headHeight, headerWidth, headerHeight)];
        [content drawInRect:CGRectMake(contentX, headHeight + headerHeight, contentWidth, contentHeight)];
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(generatorDidFinishWorking:result:)]) {
            [self.delegate generatorDidFinishWorking:self result:finalImage];
        }
    }
}

@end
