//
//  AreaCitiesModel.h
//  CNCityPickerView
//
//  Created by btw on 15/3/16.
//  Copyright (c) 2015年 Weiming Bi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNCityAreaCitiesModel : NSObject

/**
 *  包含字符串
 */
@property (strong, nonatomic) NSArray *areas;
@property (strong, nonatomic) NSString *state;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
