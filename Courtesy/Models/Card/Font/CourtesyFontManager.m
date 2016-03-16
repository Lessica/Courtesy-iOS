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
        fontSystem.fontName = @"苹方";
        fontSystem.defaultSize = 16.0;
        fontSystem.font = [UIFont systemFontOfSize:fontSystem.defaultSize];
        fontSystem.fontPreview = [[UIImage imageNamed:@"font-applepf"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
        fontSystem.delegate = self;
        fontSystem.type = kCourtesyFontDefault;
        
        CourtesyFontModel *fontSong = [CourtesyFontModel new];
        fontSong.remoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_FONT, @"FZSSK.TTF.zip"]];
        fontSong.localURL = [NSURL fileURLWithPath:[[[UIApplication sharedApplication] documentsPath] stringByAppendingPathComponent:@"Fonts/FZSSK.TTF"]];
        fontSong.fontName = @"方正书宋";
        fontSong.fileSize = 5430465.0;
        fontSong.defaultSize = 16.0;
        fontSong.font = nil;
        fontSong.fontPreview = [[UIImage imageNamed:@"font-fzssk"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        fontSong.delegate = self;
        fontSong.type = kCourtesyFontFZSSK;
        
        CourtesyFontModel *fontKai = [CourtesyFontModel new];
        fontKai.remoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_FONT, @"FZKTK.TTF.zip"]];
        fontKai.localURL = [NSURL fileURLWithPath:[[[UIApplication sharedApplication] documentsPath] stringByAppendingPathComponent:@"Fonts/FZKTK.TTF"]];;
        fontKai.fontName = @"方正楷体";
        fontKai.defaultSize = 16.0;
        fontKai.fileSize = 7314268.0;
        fontKai.font = nil;
        fontKai.fontPreview = [[UIImage imageNamed:@"font-fzktk"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        fontKai.delegate = self;
        fontKai.type = kCourtesyFontFZKTK;
        
        CourtesyFontModel *fontHei = [CourtesyFontModel new];
        fontHei.remoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_FONT, @"FZHTK.TTF.zip"]];
        fontHei.localURL = [NSURL fileURLWithPath:[[[UIApplication sharedApplication] documentsPath] stringByAppendingPathComponent:@"Fonts/FZHTK.TTF"]];;
        fontHei.fontName = @"方正黑体";
        fontHei.defaultSize = 16.0;
        fontHei.fileSize = 4990672.0;
        fontHei.font = nil;
        fontHei.fontPreview = [[UIImage imageNamed:@"font-fzhtk"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        fontHei.delegate = self;
        fontHei.type = kCourtesyFontFZHTK;
        
        _fontList = @[fontSystem, fontHei, fontKai, fontSong];
    }
    return self;
}

- (void)downloadFont:(CourtesyFontModel *)font {
    if (_downloadingModel && _downloadingModel != font) {
        [self pauseDownloadFont:_downloadingModel];
        [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"暂停下载 %@ | 正在下载 %@", _downloadingModel.fontName, font.fontName]
                                      styleName:JDStatusBarStyleDefault];
        _downloadingModel = font;
    } else {
        [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"正在下载 %@", font.fontName]
                                      styleName:JDStatusBarStyleDefault];
        _downloadingModel = font;
    }
    
    [JDStatusBarNotification showActivityIndicator:YES
                                    indicatorStyle:UIActivityIndicatorViewStyleGray];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [font downloadFont];
    });
}

- (void)pauseDownloadFont:(CourtesyFontModel *)font {
    [font pauseDownloadFont];
    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"暂停下载 %@", font.fontName]
                               dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleDefault];
}

#pragma mark - CourtesyFontDownloadDelegate

- (void)fontDownloadDidSucceed:(CourtesyFontModel *)font {
    if (_delegate && [_delegate respondsToSelector:@selector(fontManager:shouldReloadData:)]) {
        [_delegate fontManager:self shouldReloadData:YES];
    }
    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@ 下载成功", font.fontName]
                               dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleSuccess];
    _downloadingModel = nil;
}

- (void)fontDownloadDidFailed:(CourtesyFontModel *)font
             withErrorMessage:(NSString *)message {
    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"%@ 下载失败 - %@", font.fontName, message]
                               dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleError];
    _downloadingModel = nil;
}

- (void)fontDownload:(CourtesyFontModel *)font
        withProgress:(float)progress {
    if (font == _downloadingModel) {
        // This is not called back on the main queue.
        // You are responsible for dispatching to the main queue for UI updates
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            [JDStatusBarNotification showProgress:progress];
        });
    }
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
