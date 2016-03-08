//
//  AreaCitiesModel.m
//  CNCityPickerView
//
//  Created by btw on 15/3/16.
//  Copyright (c) 2015年 Weiming Bi. All rights reserved.
//

#import "CNCityAreaCitiesModel.h"

@implementation CNCityAreaCitiesModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        if(dictionary[@"state"]) {
            self.state = dictionary[@"state"];
        }
        
        if (dictionary[@"areas"]) {
            self.areas = dictionary[@"areas"];
        }
    }
    return self;
}

@end
