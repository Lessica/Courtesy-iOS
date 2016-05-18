
//
//  CourtesyCommonResourceModel.m
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonResourceModel.h"

@implementation CourtesyCommonResourceModel
- (NSString *)type {
    return @"common";
}

- (NSURL *)remoteUrl {
    if (!_remoteUrl) {
        _remoteUrl = [NSURL URLWithString:[NSString stringWithFormat:API_STATIC_NEWS_RESOURCES, self.type, self.rid, self.kind]];
    }
    return _remoteUrl;
}

@end
