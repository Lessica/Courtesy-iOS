//
//  CourtesyCardDataModel.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardAttachmentModel.h"
#import "CourtesyCardStyleManager.h"
#import "CourtesyCardLocationModel.h"
//#import "CourtesyCardPreviewStyleManager.h"

@protocol CourtesyCardAttachmentModel
@end

@interface CourtesyCardDataModel : JSONModel
@property (nonatomic, copy) NSString<Optional> *qrcode;
@property (nonatomic, strong, readonly) NSString<Ignore> *mainTitle; // 20 chars
@property (nonatomic, strong, readonly) NSString<Ignore> *briefTitle; // 50 chars
@property (nonatomic, strong, readonly) NSURL<Ignore> *smallThumbnailURL; // From the first attachment image
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray<CourtesyCardAttachmentModel, Optional> *attachments;
@property (nonatomic, strong) NSArray<NSString *> *attachments_hashes;
@property (nonatomic, assign) CourtesyCardStyleID styleID;
//@property (nonatomic, assign) CourtesyCardPreviewStyleType previewType;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CourtesyFontType fontType;
@property (nonatomic, assign) NSTextAlignment alignmentType;
@property (nonatomic, strong) CourtesyCardStyleModel<Ignore> *style;
//@property (nonatomic, strong) CourtesyCardPreviewStyleModel<Ignore> *previewStyle;
@property (nonatomic, assign) BOOL shouldAutoPlayAudio;
@property (nonatomic, copy) NSString *card_token;
@property (nonatomic, copy) CourtesyCardLocationModel *geoLocation;

- (NSString *)savedAttachmentsPath;

@end
