//
//  CourtesyCardAttachmentModel.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "JSONModel.h"

typedef NS_ENUM(NSInteger, CourtesyAttachmentType) {
    CourtesyAttachmentImage = 0,
    CourtesyAttachmentAudio = 1,
    CourtesyAttachmentVideo = 2,
    CourtesyAttachmentDraw  = 3,
    CourtesyAttachmentAnimatedImage = 4,
    CourtesyAttachmentLivePhoto     = 5
};

@interface CourtesyCardAttachmentModel : JSONModel
@property (nonatomic, assign) CourtesyAttachmentType type;
@property (nonatomic, copy) NSString<Optional> *title;
@property (nonatomic, strong) NSURL<Optional> *remote_url;
@property (nonatomic, strong) NSURL<Optional> *local_url;
@property (nonatomic, copy) NSString *attachment_id;
@property (nonatomic, copy) NSString *salt_hash;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) NSUInteger created_at;
@property (nonatomic, strong) NSDate<Optional> *created_at_object;
@property (nonatomic, assign) NSUInteger uploaded_at;
@property (nonatomic, strong) NSDate<Optional> *uploaded_at_object;

@end
