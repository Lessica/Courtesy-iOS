//
//  CourtesyGalleryDailyCardImageModel.m
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyGalleryDailyCardImageModel.h"

@implementation CourtesyGalleryDailyCardImageModel
- (NSURL *)remoteUrl {
    if (!_remoteUrl) {
        _remoteUrl = [NSURL URLWithString:[NSString stringWithFormat:API_STATIC_NEWS_RESOURCES, @"image", self.rid, @"jpg"]];
    }
    return _remoteUrl;
}

- (void)dealloc {
    CYLog(@"");
}
@end
