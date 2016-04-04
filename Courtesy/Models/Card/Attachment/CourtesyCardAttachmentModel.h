//
//  CourtesyCardAttachmentModel.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "JSONModel.h"

#define kCardThumbnailImageExtraSmall CGSizeMake(80, 80)
#define kCardThumbnailImageSmall  CGSizeMake(160, 160)
#define kCardThumbnailImageMedium CGSizeMake(320, 320)
#define kCardThumbnailImageLarge  CGSizeMake(640, 640)
#define kCardThumbnailImageExtraLarge CGSizeMake(1280, 1280)

typedef NS_ENUM(NSInteger, CourtesyAttachmentType) {
    CourtesyAttachmentImage = 0,
    CourtesyAttachmentAudio = 1,
    CourtesyAttachmentVideo = 2,
//    CourtesyAttachmentDraw  = 3,
    CourtesyAttachmentAnimatedImage = 4,
//    CourtesyAttachmentLivePhoto     = 5
};

@interface CourtesyCardAttachmentModel : JSONModel
@property (nonatomic, assign) CourtesyAttachmentType type;
@property (nonatomic, copy)   NSString<Optional> *title;
@property (nonatomic, copy)   NSString<Optional> *remote_url_path;
@property (nonatomic, strong, readonly) NSURL<Ignore> *remote_url;
@property (nonatomic, copy)   NSString<Optional> *local_filename;
@property (nonatomic, strong, readonly) NSURL<Ignore> *local_url;
@property (nonatomic, copy)   NSString<Optional> *attachment_id; // Came from server
@property (nonatomic, copy)   NSString *salt_hash;
@property (nonatomic, assign) NSUInteger location;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, assign) NSUInteger created_at;
@property (nonatomic, strong, readonly) NSDate<Optional> *created_at_object;
@property (nonatomic, assign) NSUInteger uploaded_at;
@property (nonatomic, strong, readonly) NSDate<Optional> *uploaded_at_object;

- (instancetype)initWithSaltHash:(NSString *)salt;
- (NSString *)saveToLocalDatabase;
- (void)deleteInLocalDatabase;
+ (NSString *)savedAttachmentsPath;
+ (NSString *)savedThumbnailsPath;
- (NSURL *)thumbnailImageURLWithSize:(CGSize)size;
- (NSString *)thumbnailPathWithSize:(CGSize)size;

@end
