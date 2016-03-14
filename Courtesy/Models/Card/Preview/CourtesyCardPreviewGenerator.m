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
    if (!self.contentImage) {
        return;
    }
#warning "Footer Text"
    UIImage *preview_head = self.previewStyle.previewHeader;
    UIImage *preview_body = self.previewStyle.previewBody;
    UIImage *preview_footer = self.previewStyle.previewFooter;
    UIImage *content = self.contentImage;
    CGFloat screen_width = [UIScreen mainScreen].bounds.size.width;
    
    // Draw Content
    CGFloat contentWidth = screen_width - 64;
    CGFloat contentScale = (CGFloat)content.size.width / contentWidth;
    CGFloat contentHeight = content.size.height / contentScale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(contentWidth, contentHeight), NO, 0.0);
    [content drawInRect:CGRectMake(0, 0, contentWidth, contentHeight)];
    content = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Draw head
    CGFloat headWidth = screen_width;
    CGFloat headScale = (CGFloat)preview_head.size.width / headWidth;
    CGFloat headHeight = (CGFloat)preview_head.size.height / headScale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(headWidth, headHeight), NO, 0.0);
    [preview_head drawInRect:CGRectMake(0, 0, headWidth, headHeight)];
    preview_head = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Draw body
    CGFloat bodyWidth = screen_width;
    CGFloat bodyHeight = content.size.height;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(bodyWidth, bodyHeight), NO, 0.0);
    [preview_body drawInRect:CGRectMake(0, 0, bodyWidth, bodyHeight)];
    preview_body = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Draw Footer
    CGFloat footerWidth = screen_width;
    CGFloat footerScale = (CGFloat)preview_footer.size.width / footerWidth;
    CGFloat footerHeight = (CGFloat)preview_footer.size.height / footerScale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(footerWidth, footerHeight), NO, 0.0);
    [preview_footer drawInRect:CGRectMake(0, 0, footerWidth, footerHeight)];
    preview_footer = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Draw Total
    CGFloat totalWidth = screen_width;
    CGFloat totalHeight = content.size.height + preview_head.size.height + preview_footer.size.height;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(totalWidth, totalHeight), NO, 0.0);
    [preview_head drawInRect:CGRectMake(0, 0, totalWidth, headHeight)];
    [preview_body drawInRect:CGRectMake(0, headHeight - 1, totalWidth, bodyHeight)];
    [preview_footer drawInRect:CGRectMake(0, headHeight + bodyHeight - 1, totalWidth, footerHeight)];
    [content drawInRect:CGRectMake(32, headHeight, contentWidth, contentHeight)];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(generatorDidFinishWorking:result:)]) {
        [self.delegate generatorDidFinishWorking:self result:finalImage];
    }
}

@end
