//
//  CourtesyFontManager.h
//  Courtesy
//
//  Created by Zheng on 3/13/16.
//  Copyright © 2016 82Flex. All rights reserved.
//  It is a singleton.

#import <Foundation/Foundation.h>
#import "CourtesyFontModel.h"

@class CourtesyFontManager;

@interface CourtesyFontManager : NSObject <CourtesyFontDownloadDelegate>
@property (nonatomic, strong, readonly) NSArray<CourtesyFontModel *> *fontList;

+ (id)sharedManager;
- (void)downloadFont:(CourtesyFontModel *)font;
- (void)pauseDownloadFont:(CourtesyFontModel *)font;
- (UIFont *)fontWithID:(CourtesyFontType)fontType;
- (CourtesyFontModel *)fontModelWithID:(CourtesyFontType)fontType;

@end
