//
//  CourtesyRequestModel.m
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonRequestModel.h"

@implementation CourtesyCommonRequestModel

- (instancetype)init {
    if (self = [super init]) {
        _version = [VERSION_BUILD integerValue];
    }
    return self;
}

@end
