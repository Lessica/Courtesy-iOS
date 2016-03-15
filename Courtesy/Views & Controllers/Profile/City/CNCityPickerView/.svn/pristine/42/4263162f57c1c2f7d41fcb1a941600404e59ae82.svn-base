//
//  AreaModel.m
//  CNCityPickerView
//
//  Created by btw on 15/3/16.
//  Copyright (c) 2015年 Weiming Bi. All rights reserved.
//

#import "CNCityAreaModel.h"
#import "CNCityAreaCitiesModel.h"

@implementation CNCityAreaModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        NSMutableArray *areaCitiesArray = [[NSMutableArray alloc] init];
        [dictionary[@"cities"] enumerateObjectsUsingBlock:^(NSDictionary* dict, NSUInteger idx, BOOL *stop) {
            CNCityAreaCitiesModel *areaCitiesModel = [[CNCityAreaCitiesModel alloc] initWithDictionary:dict];
            [areaCitiesArray addObject:areaCitiesModel];
        }];
        self.cities = areaCitiesArray;
        
        self.state = dictionary[@"state"];
    }
    return self;
}


@end
