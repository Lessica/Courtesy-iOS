//
//  AreaModel.h
//  CNCityPickerView
//
//  Created by btw on 15/3/16.
//  Copyright (c) 2015年 Weiming Bi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNCityAreaModel : NSObject

/**
 *  包含CNCityAreaCitiesModel的数组
 */
@property (strong, nonatomic) NSArray *cities;
@property (strong, nonatomic) NSString *state;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
