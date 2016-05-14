//
//  CourtesyGalleryDailyCardAudioModel.m
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyGalleryDailyCardAudioModel.h"

@implementation CourtesyGalleryDailyCardAudioModel
- (NSURL *)remoteUrl {
    if (!_remoteUrl) {
        _remoteUrl = [NSURL URLWithString:[NSString stringWithFormat:API_STATIC_NEWS_RESOURCES, @"voice", self.rid, @"m4a"]];
    }
    return _remoteUrl;
}

- (void)dealloc {
    CYLog(@"");
}
@end
