//
//  CourtesyCardResourcesVerificationModel.m
//  Courtesy
//
//  Created by Zheng on 4/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardResourcesVerificationModel.h"
#import "FCFileManager.h"
#import "NSString+Mime.h"

@implementation CourtesyCardResourcesVerificationModel

- (NSString *)action {
    return @"rsync_statics";
}

- (instancetype)initWithCard:(CourtesyCardModel *)card {
    if (self = [super init]) {
        _card_token = card.token;
        _synced_at = [[NSDate date] timeIntervalSince1970];
        NSMutableArray *resourcesArr = [NSMutableArray new];
        for (CourtesyCardAttachmentModel *attachment in card.local_template.attachments) {
            attachment.uploaded_at = _synced_at; // 更新附件上传时间
            CourtesyCardResourceModel *newModel = [CourtesyCardResourceModel new];
            NSString *newAttachmentPath = [attachment attachmentPath];
            newModel.filename = [newAttachmentPath lastPathComponent];
            newModel.sha256 = attachment.salt_hash;
            newModel.mime = [newAttachmentPath mime];
            newModel.type = attachment.type;
            newModel.size = [newAttachmentPath filesize]; // Get file size by fetching file attributes
            [resourcesArr addObject:newModel];
#ifdef API_USE_LOCAL_THUMBNAIL
            [attachment generateThumbnails];
            if (attachment.thumbnails) {
                [resourcesArr addObjectsFromArray:attachment.thumbnails];
            }
#endif
        }
        _statics = [resourcesArr copy];
    }
    return self;
}

- (void)generateVerificationInfo {
    NSString *jsonString = [self toJSONString];
    CYLog(@"%@", jsonString);
    NSString *card_path = [CourtesyCardAttachmentModel savedAttachmentsPathWithCardToken:self.card_token];
    NSString *json_path = [card_path stringByAppendingPathComponent:@"Contents.json"];
    NSData *json_data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    [json_data writeToFile:json_path
                   options:NSDataWritingAtomic
                     error:&error];
    if (error) {
        CYLog(@"Cannot write to: %@, %@", json_path, [error localizedDescription]);
    }
    return;
}

@end
