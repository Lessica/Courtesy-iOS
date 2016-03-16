//
//  CourtesyCardModel.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardModel.h"

@implementation CourtesyCardModel

- (void)setCreated_at_object:(NSDate<Ignore> *)created_at_object {
    _created_at_object = created_at_object;
    _created_at = [created_at_object timeIntervalSince1970];
}

- (void)setModified_at_object:(NSDate<Ignore> *)modified_at_object {
    _modified_at_object = modified_at_object;
    _modified_at = [modified_at_object timeIntervalSince1970];
}

- (void)setFirst_read_at_object:(NSDate<Ignore> *)first_read_at_object {
    _first_read_at_object = first_read_at_object;
    _first_read_at = [first_read_at_object timeIntervalSince1970];
}

@end
