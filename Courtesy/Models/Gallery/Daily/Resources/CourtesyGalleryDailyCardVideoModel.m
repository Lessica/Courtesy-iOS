//
//  CourtesyGalleryDailyCardVideoModel.m
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyGalleryDailyCardVideoModel.h"

@implementation CourtesyGalleryDailyCardVideoModel
- (NSURL *)remoteUrl {
    if (!_remoteUrl) {
        _remoteUrl = [NSURL URLWithString:[NSString stringWithFormat:API_STATIC_NEWS_RESOURCES, @"video", self.rid, @"mov"]];
    }
    return _remoteUrl;
}

- (void)dealloc {
    CYLog(@"");
}
@end
