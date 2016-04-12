//
//  CourtesyCardAttachmentModel.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardAttachmentModel.h"
#import "AppStorage.h"
#import "FCFileManager.h" 

#define kCourtesyAttachmentPrefix @"kCourtesyAttachmentPrefix-%@"
#define kCourtesyThumbnailPrefix @"kCourtesyThumbnailPrefix-%@-%d-%d"

@interface CourtesyCardAttachmentModel ()

@end

@implementation CourtesyCardAttachmentModel {
    NSString *_attachmentPath;
    NSURL *_attachmentURL;
}

#pragma mark - paths

+ (NSString *)savedAttachmentsPathWithCardToken:(NSString *)token {
    static NSString *tPath = nil;
    NSString *documentPath = [[UIApplication sharedApplication] documentsPath];
    NSString *savedAttachmentsDirectoryPath = [documentPath stringByAppendingPathComponent:@"SavedAttachments"];
    NSString *savedAttachmentsDirectoryHashPath = [savedAttachmentsDirectoryPath stringByAppendingPathComponent:token];
    tPath = [[NSURL fileURLWithPath:savedAttachmentsDirectoryHashPath] path];
    if (![FCFileManager isDirectoryItemAtPath:tPath])
        [FCFileManager createDirectoriesForPath:tPath error:nil];
    return tPath;
}

- (NSString *)attachmentPath {
    if (!_attachmentPath) {
        NSString *attachmentPath = [[[self class] savedAttachmentsPathWithCardToken:self.card_token] stringByAppendingPathComponent:[NSString stringWithFormat:kCourtesyAttachmentPrefix, self.salt_hash]];
        if (self.type == CourtesyAttachmentImage) {
            attachmentPath = [attachmentPath stringByAppendingPathExtension:@"png"];
        } else if (self.type == CourtesyAttachmentAnimatedImage) {
            attachmentPath = [attachmentPath stringByAppendingPathExtension:@"gif"];
        } else if (self.type == CourtesyAttachmentVideo) {
            attachmentPath = [attachmentPath stringByAppendingPathExtension:@"mov"];
        } else if (self.type == CourtesyAttachmentAudio) {
            attachmentPath = [attachmentPath stringByAppendingPathExtension:@"caf"];
        } else {
            
        }
        _attachmentPath = attachmentPath;
    }
    CYLog(@"%@", _attachmentPath);
    return _attachmentPath;
}

- (NSURL *)attachmentURL {
    if (!_attachmentURL) {
        _attachmentURL = [NSURL fileURLWithPath:[self attachmentPath]];
    }
    return _attachmentURL;
}

- (NSString *)thumbnailPathWithSize:(CGSize)size {
    NSString *thumbnailPath = [[[self class] savedAttachmentsPathWithCardToken:self.card_token] stringByAppendingPathComponent:[NSString stringWithFormat:kCourtesyThumbnailPrefix, self.salt_hash, (int)size.width, (int)size.height]];
    thumbnailPath = [thumbnailPath stringByAppendingPathExtension:@"jpg"];
    CYLog(@"%@", thumbnailPath);
    return thumbnailPath;
}

#pragma mark - Init

- (instancetype)initWithSaltHash:(NSString *)salt andCardToken:(NSString *)token fromDatabase:(BOOL)fromDatabase {
    NSAssert(salt != nil && token != nil, @"Empty salt hash or card token!");
    if (fromDatabase) {
        id obj = [[self appStorage] objectForKey:[NSString stringWithFormat:kCourtesyAttachmentPrefix, salt]];
        if (!obj) {
            return nil;
        }
        NSError *err = nil;
        NSDictionary *aDict = obj;
        if (self = [super initWithDictionary:aDict error:&err]) {
            _salt_hash = salt;
            _card_token = token;
        }
        NSAssert(err == nil, @"Error occured when parsing attachment model with its hash!");
    } else {
        if (self = [super init]) {
            _salt_hash = salt;
            _card_token = token;
        }
    }
    return self;
}

#pragma mark - Getter / Setter

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
}

- (void)setUploaded_at:(NSUInteger)uploaded_at {
    _uploaded_at = uploaded_at;
    _uploaded_at_object = [NSDate dateWithTimeIntervalSince1970:_uploaded_at];
}

- (void)setCreated_at:(NSUInteger)created_at {
    _created_at = created_at;
    _created_at_object = [NSDate dateWithTimeIntervalSince1970:_created_at];
}

#pragma mark - Card Storage

- (BOOL)hasLocalRecord {
    if (!self.salt_hash) {
        return NO;
    }
    id obj = [[self appStorage] objectForKey:[NSString stringWithFormat:kCourtesyAttachmentPrefix, self.salt_hash]];
    if (!obj) {
        return NO;
    }
    return YES;
}

- (NSString *)saveToLocalDatabase {
    NSDictionary *cardDict = [self toDictionary];
    NSAssert(cardDict != nil && self.salt_hash != nil, @"Attachment cannot be saved to the database!");
    [[self appStorage] setObject:cardDict forKey:[NSString stringWithFormat:kCourtesyAttachmentPrefix, self.salt_hash]];
    return self.salt_hash;
}

- (void)removeFromLocalDatabase {
    CYLog(@"Old attachment removed: %@", self.attachmentPath);
    [FCFileManager removeItemAtPath:self.attachmentPath];
    [[self appStorage] removeObjectForKey:[NSString stringWithFormat:kCourtesyAttachmentPrefix, self.salt_hash]];
}

#pragma mark - thumbnail engine

- (NSURL *)thumbnailImageURLWithSize:(CGSize)size {
    // TODO: Should handle remote cache request here
    if (self.type == CourtesyAttachmentImage || self.type == CourtesyAttachmentAnimatedImage) { // 图片
        // Find existing thumbnail
        NSError *error = nil;
        NSString *thumbnailPath = [self thumbnailPathWithSize:size];
        if ([FCFileManager existsItemAtPath:thumbnailPath]) {
            return [NSURL fileURLWithPath:thumbnailPath];
        }
        if ([self attachmentPath]) { // 本地缓存
            UIImage *originalImage = [UIImage imageWithContentsOfFile:[self attachmentPath]];
            UIImage *resizedImage = [originalImage imageByResizeToSize:size contentMode:UIViewContentModeScaleAspectFit];
            NSData *resizedData = UIImageJPEGRepresentation(resizedImage, 0.618);
            [resizedData writeToFile:thumbnailPath
                             options:NSDataWritingWithoutOverwriting
                               error:&error];
            if (error) {
                CYLog(@"Thumbnail write failed!");
            }
            return [NSURL fileURLWithPath:thumbnailPath];
        }
    } else if (self.type == CourtesyAttachmentVideo) { // 视频
        size = CGSizeMake(0, 0);
        if ([self attachmentPath]) { // 本地缓存
            NSString *thumbnailPath = [self thumbnailPathWithSize:size];
            if ([FCFileManager existsItemAtPath:thumbnailPath]) {
                return [NSURL fileURLWithPath:thumbnailPath];
            }
        }
    }
    return nil;
}

@end
