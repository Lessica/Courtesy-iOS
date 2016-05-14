//
//  CourtesyGalleryDailyCardModel.m
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyGalleryDailyCardModel.h"

@implementation CourtesyGalleryDailyCardModel
- (NSString *)url {
    if (!_url) {
        _url = @"https://82flex.com";
    }
    return _url;
}

- (void)dealloc {
    CYLog(@"");
}

@end
