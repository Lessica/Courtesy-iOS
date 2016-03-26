//
//  CourtesyCardDataModel.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardDataModel.h"
#import "CourtesyCardAttachmentModel.h"

@implementation CourtesyCardDataModel

- (void)setContent:(NSString *)content {
    _content = content;
    BOOL mainTitled = NO;
    BOOL briefTitled = NO;
    content = [content stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""];
    NSRange breakPos = [content rangeOfString:@"\n"];
    while (breakPos.length > 0) {
        NSString *sub = [[content substringToIndex:breakPos.location] stringByTrim];
        if (sub.length > 0) {
            if (!mainTitled) {
                mainTitled = YES;
                _mainTitle = sub;
            } else {
                briefTitled = YES;
                _briefTitle = sub;
                return;
            }
        }
        content = [[content substringFromIndex:breakPos.location] stringByTrim];
        breakPos = [content rangeOfString:@"\n"];
    }
    if (!mainTitled) {
        _mainTitle = @"无标题卡片";
    }
    if (!briefTitled) {
        _briefTitle = content;
    }
}

- (void)setAttachments:(NSArray<Ignore> *)attachments {
    _attachments = attachments;
    NSMutableArray *newAttachmentsArr = [NSMutableArray new];
    for (CourtesyCardAttachmentModel *m in attachments) {
        [newAttachmentsArr addObject:[m toDictionary]];
    }
    _attachments_info = newAttachmentsArr;
}

- (NSURL *)smallThumbnailURL {
    if ([[self attachments] count] == 0) {
        return nil;
    }
    for (CourtesyCardAttachmentModel *m in self.attachments) {
        if (m.type == CourtesyAttachmentImage && m.local_url) {
#warning TODO: Other types of media should also have thumbnail images
            return m.local_url;
        }
    }
    return nil;
}

@end
