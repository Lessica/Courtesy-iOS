//
//  CourtesyCardLocationModel.m
//  Courtesy
//
//  Created by Zheng on 5/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardLocationModel.h"

@implementation CourtesyCardLocationModel

- (NSString *)address {
    if (!_address) {
        _address = @"";
    }
    return _address;
}

- (BOOL)hasLocation {
    if (_latitude == 0) {
        return NO;
    }
    return YES;
}

- (void)clearLocation {
    _latitude = 0.0;
    _longitude = 0.0;
    _address = @"";
}

@end
