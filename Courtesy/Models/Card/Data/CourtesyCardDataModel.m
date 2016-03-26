//
//  CourtesyCardDataModel.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardDataModel.h"
#import "CourtesyCardAttachmentModel.h"
#import "CourtesyCardStyleManager.h"

@implementation CourtesyCardDataModel

#pragma mark - Getter / Setter

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
    NSMutableArray *newAttachmentsHashesArr = [NSMutableArray new];
    for (CourtesyCardAttachmentModel *m in attachments) {
        [newAttachmentsHashesArr addObject:m.salt_hash];
    }
    _attachments_hashes = newAttachmentsHashesArr;
}

- (void)setAttachments_hashes:(NSArray<NSString *> *)attachments_hashes {
    _attachments_hashes = attachments_hashes;
    NSMutableArray *newAttachmentsArr = [NSMutableArray new];
    for (NSString *hash in attachments_hashes) {
        CourtesyCardAttachmentModel *a = [[CourtesyCardAttachmentModel alloc] initWithSaltHash:hash];
        NSAssert(a != nil, @"Cannot load attachment hash!");
        [newAttachmentsArr addObject:a];
    }
    _attachments = newAttachmentsArr;
}

- (NSURL *)smallThumbnailURL {
    if ([[self attachments] count] == 0) {
        return nil;
    }
    for (CourtesyCardAttachmentModel *m in self.attachments) {
        if (m.type == CourtesyAttachmentImage && m.local_url) {
#warning TODO: Other types of media should also have thumbnail images
            NSURL *url = [NSURL fileURLWithPath:[m.local_url path]];
            return url;
        }
    }
    return nil;
}

- (CourtesyCardStyleModel *)style { // Lazy Loading
    if (!_style) {
        _style = [[CourtesyCardStyleManager sharedManager] styleWithID:self.styleID];
    }
    return _style;
}

@end
