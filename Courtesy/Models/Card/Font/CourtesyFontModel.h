//
//  CourtesyFontModel.h
//  Courtesy
//
//  Created by Zheng on 3/13/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "SSZipArchive.h"

typedef enum : NSUInteger {
    kCourtesyFontDefault = 0,
    kCourtesyFontFZSSK   = 1,
    kCourtesyFontFZHTK   = 2,
    kCourtesyFontFZKTK   = 3,
    kCourtesyFontXXMTK   = 4
} CourtesyFontType;

typedef enum : NSUInteger {
    CourtesyFontDownloadingTaskStatusNone     = 0,
    CourtesyFontDownloadingTaskStatusDownload = 1,
    CourtesyFontDownloadingTaskStatusSuspend  = 2,
    CourtesyFontDownloadingTaskStatusExtract  = 3,
    CourtesyFontDownloadingTaskStatusDone     = 4,
    CourtesyFontDownloadingTaskStatusReady    = 5
} CourtesyFontDownloadingTaskStatus;

@class CourtesyFontModel;

@protocol CourtesyFontDownloadDelegate <NSObject>

@optional
- (void)fontDownloadDidSucceed:(CourtesyFontModel *)font;

@optional
- (void)fontDownloadDidFailed:(CourtesyFontModel *)font
             withErrorMessage:(NSString *)message;

@optional
- (void)fontDownloadProgressNotify:(CourtesyFontModel *)font;

@end

@interface CourtesyFontModel : NSObject <SSZipArchiveDelegate>
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) UIImage *fontPreview;
@property (nonatomic, strong) NSURL *remoteURL;
@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic, assign) CGFloat defaultSize;
@property (nonatomic, assign) float fileSize;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CourtesyFontDownloadingTaskStatus status;
@property (nonatomic, assign, readonly) float downloadProgress;
@property (nonatomic, assign) CourtesyFontType type;
@property (nonatomic, weak) id<CourtesyFontDownloadDelegate> delegate;

- (instancetype)initWithLocalURL:(NSURL *)localURL;
- (void)startDownloadTask;
- (void)pauseDownloadTask;

@end
