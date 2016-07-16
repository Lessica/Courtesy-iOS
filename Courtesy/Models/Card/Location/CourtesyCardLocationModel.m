//
//  CourtesyCardLocationModel.m
//  Courtesy
//
//  Created by Zheng on 5/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardLocationModel.h"

@implementation CourtesyCardLocationModel

- (NSString *)name {
    if (!_name) {
        _name = @"";
    }
    return _name;
}

- (NSString *)address {
    if (!_address) {
        _address = @"";
    }
    return _address;
}

- (NSString *)city {
    if (!_city) {
        _city = @"";
    }
    return _city;
}

- (NSString *)displayName {
    if (self.name.length > 0) {
        return self.name;
    } else {
        return self.city;
    }
    return @"";
}

@end
