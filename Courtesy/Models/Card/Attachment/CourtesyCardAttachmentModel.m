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

@implementation CourtesyCardAttachmentModel

#pragma mark - paths

+ (NSString *)savedAttachmentsPath {
    static NSString *tPath = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tPath = [[NSURL fileURLWithPath:[[[UIApplication sharedApplication] documentsPath] stringByAppendingPathComponent:@"SavedAttachments"]] path];
        if (![FCFileManager isDirectoryItemAtPath:tPath])
            [FCFileManager createDirectoriesForPath:tPath error:nil];
    });
    return tPath;
}

+ (NSString *)savedThumbnailsPath {
    static NSString *tPath = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tPath = [[NSURL fileURLWithPath:[[[UIApplication sharedApplication] documentsPath] stringByAppendingPathComponent:@"SavedThumbnails"]] path];
        if (![FCFileManager isDirectoryItemAtPath:tPath])
            [FCFileManager createDirectoriesForPath:tPath error:nil];
    });
    return tPath;
}

- (NSString *)thumbnailPathWithSize:(CGSize)size {
    if (self.type == CourtesyAttachmentImage || self.type == CourtesyAttachmentAnimatedImage) {
        return [[[self class] savedThumbnailsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d-%d", self.salt_hash, (int)size.width, (int)size.height]];
    } else if (self.type == CourtesyAttachmentVideo) {
        return [[[self class] savedThumbnailsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-preview", self.salt_hash]];
    }
    return nil;
}

#pragma mark - Init

- (instancetype)initWithSaltHash:(NSString *)salt {
    id obj = [[self appStorage] objectForKey:[NSString stringWithFormat:kCourtesyAttachmentPrefix, salt]];
    if (!obj) {
        return nil;
    }
    _salt_hash = salt;
    NSError *err = nil;
    NSDictionary *aDict = obj;
    if (self = [super initWithDictionary:aDict error:&err]) {

    }
    NSAssert(err == nil, @"Error occured when parsing attachment model with its hash!");
    return self;
}

#pragma mark - Getter / Setter

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
}

- (void)setLocal_filename:(NSString<Optional> *)local_filename {
    _local_filename = local_filename;
    if (_local_filename) {
        NSString *targetPath = [[NSURL fileURLWithPath:[[[UIApplication sharedApplication] documentsPath] stringByAppendingPathComponent:@"SavedAttachments"]] path];
        _local_url = [NSURL fileURLWithPath:[targetPath stringByAppendingPathComponent:_local_filename]];
    }
}

- (void)setRemote_url_path:(NSString<Optional> *)remote_url_path {
    _remote_url_path = remote_url_path;
    if (_remote_url_path) {
        _remote_url = [NSURL URLWithString:_remote_url_path];
    }
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

- (void)deleteInLocalDatabase {
    [FCFileManager removeItemAtPath:[_local_url path]];
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
        if (self.local_url) { // 本地缓存
            UIImage *originalImage = [UIImage imageWithContentsOfFile:[self.local_url path]];
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
        if (self.local_url) { // 本地缓存
            NSString *thumbnailPath = [self thumbnailPathWithSize:size];
            if ([FCFileManager existsItemAtPath:thumbnailPath]) {
                return [NSURL fileURLWithPath:thumbnailPath];
            }
        }
    }
    return nil;
}

@end
