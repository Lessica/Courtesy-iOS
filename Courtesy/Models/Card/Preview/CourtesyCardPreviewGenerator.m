//
//  CourtesyCardPreviewGenerator.m
//  Courtesy
//
//  Created by Zheng on 3/11/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPreviewGenerator.h"

@implementation CourtesyCardPreviewGenerator

- (void)generate {
    if (!self.contentView) {
        return;
    }
    @autoreleasepool {
        // TODO: Edit footer text
        UIImage *preview_head = self.previewStyle.previewHeader;
        UIImage *preview_body = self.previewStyle.previewBody;
        UIImage *preview_footer = self.previewStyle.previewFooter;
        
        CGSize contentSize = self.contentView.bounds.size;
        UIGraphicsBeginImageContextWithOptions(contentSize, NO, 0.0);
        [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *content = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat contentWidth = (CGFloat)screenWidth - 64;
        CGFloat contentScale = (CGFloat)contentSize.width / contentWidth;
        CGFloat contentHeight = (CGFloat)contentSize.height / contentScale;
        CGFloat headScale = (CGFloat)preview_head.size.width / screenWidth;
        CGFloat headHeight = (CGFloat)preview_head.size.height / headScale;
        CGFloat footerScale = (CGFloat)preview_footer.size.width / screenWidth;
        CGFloat footerHeight = (CGFloat)preview_footer.size.height / footerScale;
        CGFloat totalHeight = (CGFloat)contentHeight + headHeight + footerHeight;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(screenWidth, totalHeight), NO, 0.0);
        [preview_head drawInRect:CGRectMake(0, 0, screenWidth, headHeight)];
        [preview_body drawInRect:CGRectMake(0, headHeight - 1, screenWidth, contentHeight)];
        [preview_footer drawInRect:CGRectMake(0, headHeight + contentHeight - 1, screenWidth, footerHeight)];
        [content drawInRect:CGRectMake(32, headHeight, contentWidth, contentHeight)];
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(generatorDidFinishWorking:result:)]) {
            [self.delegate generatorDidFinishWorking:self result:finalImage];
        }
    }
}

@end
