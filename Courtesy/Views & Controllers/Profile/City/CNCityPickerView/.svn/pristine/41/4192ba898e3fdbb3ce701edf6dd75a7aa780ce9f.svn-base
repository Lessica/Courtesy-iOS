//
//  AreaFactory.m
//  CNCityPickerView
//
//  Created by 伟明 毕 on 15/3/17.
//  Copyright (c) 2015年 Weiming Bi. All rights reserved.
//

#import "CNCityAreaFactory.h"
#import "CNCityAreaModel.h"

@implementation CNCityAreaFactory

+ (NSArray *)getAreaArray {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist"];
    NSArray *resourceArray = [[NSArray alloc] initWithContentsOfFile:path];
    
    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    [resourceArray enumerateObjectsUsingBlock:^(NSDictionary* item, NSUInteger idx, BOOL *stop) {
        CNCityAreaModel *model = [[CNCityAreaModel alloc] initWithDictionary:item];
        [modelArray addObject:model];
    }];
    
    return modelArray;
}

@end
