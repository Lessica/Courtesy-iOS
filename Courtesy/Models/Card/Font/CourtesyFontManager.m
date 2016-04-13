//
//  CourtesyFontManager.m
//  Courtesy
//
//  Created by Zheng on 3/13/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyFontManager.h"

@implementation CourtesyFontManager

+ (id)sharedManager {
    static CourtesyFontManager *sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        CourtesyFontModel *fontSystem = [CourtesyFontModel new];
        fontSystem.remoteURL = nil;
        fontSystem.localURL = nil;
        fontSystem.fontName = @"默认字体";
        fontSystem.defaultSize = 16.0;
        fontSystem.font = [UIFont systemFontOfSize:fontSystem.defaultSize];
        fontSystem.fontPreview = [[UIImage imageNamed:@"font-applepf"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
        fontSystem.delegate = self;
        fontSystem.type = kCourtesyFontDefault;
        fontSystem.status = CourtesyFontDownloadingTaskStatusDone; // 默认字体是处于下载完成状态的
        
        CourtesyFontModel *fontSong = [[CourtesyFontModel alloc] initWithLocalURL:[NSURL fileURLWithPath:[[[UIApplication sharedApplication] libraryPath] stringByAppendingPathComponent:@"Fonts/FZSSK.TTF"]]];
        fontSong.remoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_FONT, @"FZSSK.TTF.zip"]];
        fontSong.fontName = @"方正书宋";
        fontSong.fileSize = 5430465.0;
        fontSong.defaultSize = 16.0;
        fontSong.fontPreview = [[UIImage imageNamed:@"font-fzssk"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        fontSong.delegate = self;
        fontSong.type = kCourtesyFontFZSSK;
        
        CourtesyFontModel *fontKai = [[CourtesyFontModel alloc] initWithLocalURL:[NSURL fileURLWithPath:[[[UIApplication sharedApplication] libraryPath] stringByAppendingPathComponent:@"Fonts/FZKTK.TTF"]]];
        fontKai.remoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_FONT, @"FZKTK.TTF.zip"]];
        fontKai.fontName = @"方正楷体";
        fontKai.defaultSize = 16.0;
        fontKai.fileSize = 7314268.0;
        fontKai.fontPreview = [[UIImage imageNamed:@"font-fzktk"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        fontKai.delegate = self;
        fontKai.type = kCourtesyFontFZKTK;
        
        CourtesyFontModel *fontHei = [[CourtesyFontModel alloc] initWithLocalURL:[NSURL fileURLWithPath:[[[UIApplication sharedApplication] libraryPath] stringByAppendingPathComponent:@"Fonts/FZHTK.TTF"]]];
        fontHei.remoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_FONT, @"FZHTK.TTF.zip"]];
        fontHei.fontName = @"方正黑体";
        fontHei.defaultSize = 16.0;
        fontHei.fileSize = 4990672.0;
        fontHei.fontPreview = [[UIImage imageNamed:@"font-fzhtk"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        fontHei.delegate = self;
        fontHei.type = kCourtesyFontFZHTK;
        
        CourtesyFontModel *fontXinXi = [[CourtesyFontModel alloc] initWithLocalURL:[NSURL fileURLWithPath:[[[UIApplication sharedApplication] libraryPath] stringByAppendingPathComponent:@"Fonts/XXMTK.TTF"]]];
        fontXinXi.remoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_FONT, @"XXMTK.TTF.zip"]];
        fontXinXi.fontName = @"微软新细明体";
        fontXinXi.defaultSize = 16.0;
        fontXinXi.fileSize = 5340326.0;
        fontXinXi.fontPreview = [[UIImage imageNamed:@"font-xxmtk"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        fontXinXi.delegate = self;
        fontXinXi.type = kCourtesyFontXXMTK;
        
        _fontList = @[fontSystem, fontHei, fontKai, fontSong, fontXinXi];
    }
    return self;
}

- (void)downloadFont:(CourtesyFontModel *)font {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [font startDownloadTask];
    });
}

- (void)pauseDownloadFont:(CourtesyFontModel *)font {
    [font pauseDownloadTask];
    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"暂停下载 %@", font.fontName]
                               dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleDefault];
}

#pragma mark - CourtesyFontDownloadDelegate

- (void)fontDownloadDidSucceed:(CourtesyFontModel *)font {
    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@ 下载成功", font.fontName]
                               dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleSuccess];
}

- (void)fontDownloadDidFailed:(CourtesyFontModel *)font
             withErrorMessage:(NSString *)message {
    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@ 下载失败 - %@", font.fontName, message]
                               dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleError];
}

- (void)fontDownloadProgressNotify:(CourtesyFontModel *)font {
    CYLog(@"Font %@, Progress = %f", font.fontName, font.downloadProgress);
}

- (CourtesyFontModel *)fontModelWithID:(CourtesyFontType)fontType {
    for (CourtesyFontModel *font in self.fontList) {
        if (font.type == fontType) {
            return font;
        }
    }
    return nil;
}

- (UIFont *)fontWithID:(CourtesyFontType)fontType {
    for (CourtesyFontModel *font in self.fontList) {
        if (font.type == fontType) {
            return font.font;
        }
    }
    return nil;
}

@end
