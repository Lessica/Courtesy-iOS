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
#import "NSString+Mime.h"

#define kCourtesyAttachmentPrefix @"kCourtesyAttachmentPrefix-%@"
#define kCourtesyThumbnailPrefix @"kCourtesyThumbnailPrefix-%@-%d-%d"

@interface CourtesyCardAttachmentModel ()

@end

@implementation CourtesyCardAttachmentModel {
    NSString *_attachmentPath;
    NSURL *_attachmentURL;
    NSURL *_remoteAttachmentURL;
}

#pragma mark - paths

+ (NSString *)savedAttachmentsPathWithCardToken:(NSString *)token {
    static NSString *tPath = nil;
    NSString *documentPath = [[UIApplication sharedApplication] libraryPath];
    NSString *savedAttachmentsDirectoryPath = [documentPath stringByAppendingPathComponent:@"SavedAttachments"];
    NSString *savedAttachmentsDirectoryHashPath = [savedAttachmentsDirectoryPath stringByAppendingPathComponent:token];
    tPath = [[NSURL fileURLWithPath:savedAttachmentsDirectoryHashPath] path];
    if (![FCFileManager isDirectoryItemAtPath:tPath])
        [FCFileManager createDirectoriesForPath:tPath error:nil];
    return tPath;
}

+ (NSURL *)remoteAttachmentsURLWithCardToken:(NSString *)token {
    return [[NSURL URLWithString:API_STATIC_RESOURCES] URLByAppendingPathComponent:token];
}

- (NSString *)attachmentPath {
    if (!_attachmentPath) {
        NSAssert(self.card_token != nil, @"Card token is nil!");
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

- (NSURL *)remoteAttachmentURL {
    if (!_remoteAttachmentURL) {
        NSAssert(self.card_token != nil, @"Card token is nil!");
        NSURL *remoteAttachmentURL = [[[self class] remoteAttachmentsURLWithCardToken:self.card_token] URLByAppendingPathComponent:[NSString stringWithFormat:kCourtesyAttachmentPrefix, self.salt_hash]];
        if (self.type == CourtesyAttachmentImage) {
            remoteAttachmentURL = [remoteAttachmentURL URLByAppendingPathExtension:@"png"];
        } else if (self.type == CourtesyAttachmentAnimatedImage) {
            remoteAttachmentURL = [remoteAttachmentURL URLByAppendingPathExtension:@"gif"];
        } else if (self.type == CourtesyAttachmentVideo) {
            remoteAttachmentURL = [remoteAttachmentURL URLByAppendingPathExtension:@"mov"];
        } else if (self.type == CourtesyAttachmentAudio) {
            remoteAttachmentURL = [remoteAttachmentURL URLByAppendingPathExtension:@"caf"];
        } else {
            
        }
        _remoteAttachmentURL = remoteAttachmentURL;
    }
    CYLog(@"%@", _remoteAttachmentURL);
    return _remoteAttachmentURL;
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

- (NSURL *)remoteThumbnailURLWithSize:(CGSize)size {
    NSURL *remoteDir = [[self class] remoteAttachmentsURLWithCardToken:self.card_token];
    NSURL *remoteThumbnailURL = [remoteDir URLByAppendingPathComponent:[NSString stringWithFormat:kCourtesyThumbnailPrefix, self.salt_hash, (int)size.width, (int)size.height]];
    remoteThumbnailURL = [remoteThumbnailURL URLByAppendingPathExtension:@"jpg"];
    CYLog(@"%@", remoteThumbnailURL);
    return remoteThumbnailURL;
}

#pragma mark - Init

- (instancetype)initWithSaltHash:(NSString *)salt fromDatabase:(BOOL)fromDatabase {
    NSAssert(salt != nil, @"Empty salt hash!");
    if (fromDatabase) {
        id obj = [[self appStorage] objectForKey:[NSString stringWithFormat:kCourtesyAttachmentPrefix, salt]];
        if (!obj) {
            return nil;
        }
        NSError *err = nil;
        NSDictionary *aDict = obj;
        if (self = [super initWithDictionary:aDict error:&err]) {
            _salt_hash = salt;
        }
        NSAssert(err == nil, @"Error occured when parsing attachment model with its hash!");
    } else {
        if (self = [super init]) {
            _salt_hash = salt;
        }
    }
    return self;
}

#pragma mark - Getter / Setter

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
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
        if ([self attachmentPath]) {
            // 获取图像网络缩略图
            if (![FCFileManager existsItemAtPath:[self attachmentPath]]) {
                return [self remoteThumbnailURLWithSize:size];
            }
            // 本地缩略图缓存
            UIImage *originalImage = [UIImage imageWithContentsOfFile:[self attachmentPath]];
            UIImage *resizedImage = [originalImage imageByResizeToSize:size contentMode:UIViewContentModeScaleAspectFit];
            NSData *resizedData = UIImageJPEGRepresentation(resizedImage, kCourtesyQualityLow);
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
        if ([self attachmentPath]) {
            // 获取视频网络缩略图
            if (![FCFileManager existsItemAtPath:[self attachmentPath]]) {
                return [self remoteThumbnailURLWithSize:size];
            }
            // 本地缩略图缓存
            NSString *thumbnailPath = [self thumbnailPathWithSize:size];
            if ([FCFileManager existsItemAtPath:thumbnailPath]) {
                return [NSURL fileURLWithPath:thumbnailPath];
            }
        }
    }
    return nil;
}

- (void)generateThumbnails {
    if (self.type == CourtesyAttachmentImage || self.type == CourtesyAttachmentAnimatedImage) {
        CGSize size[] = {
            kCardThumbnailImageExtraSmall,
            kCardThumbnailImageSmall,
            kCardThumbnailImageMedium,
            kCardThumbnailImageLarge,
            kCardThumbnailImageExtraLarge
        };
        int count = sizeof(size) / sizeof(CGSize);
        NSMutableArray *resourcesArr = [NSMutableArray new];
        for (int i = 0; i < count; i++) {
            NSURL *newThumbnailURL = [self thumbnailImageURLWithSize:size[i]];
            if (newThumbnailURL != nil) {
                NSString *newThumbnailPath = [newThumbnailURL path];
                CourtesyCardResourceModel *newModel = [CourtesyCardResourceModel new];
                newModel.filename = [newThumbnailPath lastPathComponent];
                newModel.sha256 = [[NSData dataWithContentsOfFile:newThumbnailPath] sha256String];
                newModel.mime = [newThumbnailPath mime];
                newModel.type = CourtesyAttachmentThumbnailImage;
                newModel.size = [newThumbnailPath filesize];
                [resourcesArr addObject:newModel];
            }
        }
        _thumbnails = [resourcesArr copy];
    } else if (self.type == CourtesyAttachmentVideo) {
        NSURL *newThumbnailURL = [self thumbnailImageURLWithSize:CGSizeMake(0, 0)];
        if (newThumbnailURL != nil) {
            NSString *newThumbnailPath = [newThumbnailURL path];
            CourtesyCardResourceModel *newModel = [CourtesyCardResourceModel new];
            newModel.filename = [newThumbnailPath lastPathComponent];
            newModel.sha256 = [[NSData dataWithContentsOfFile:newThumbnailPath] sha256String];
            newModel.mime = [newThumbnailPath mime];
            newModel.type = CourtesyAttachmentThumbnailImage;
            newModel.size = [newThumbnailPath filesize];
            _thumbnails = [[NSArray arrayWithObject:newModel] copy];
        }
    }
}

@end
