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

@protocol CourtesyFontManagerDelegate <NSObject>

@optional
- (void)fontManager:(CourtesyFontManager *)fontManager
   shouldReloadData:(BOOL)reload;

@end

@interface CourtesyFontManager : NSObject <CourtesyFontDownloadDelegate>
@property (nonatomic, strong, readonly) NSArray<CourtesyFontModel *> *fontList;
@property (nonatomic, weak) id<CourtesyFontManagerDelegate> delegate;
@property (nonatomic, assign) CourtesyFontModel *downloadingModel;

+ (id)sharedManager;
- (void)downloadFont:(CourtesyFontModel *)font;
- (void)pauseDownloadFont:(CourtesyFontModel *)font;

@end
