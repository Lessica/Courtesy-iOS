//
//  CourtesyCardStyleModel.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

typedef NS_ENUM(NSInteger, CourtesyCardStyleType) {
    CourtesyCardStyleDefault = 0
};

@interface CourtesyCardStyleModel : NSObject
@property (nonatomic, assign) CourtesyCardStyleType type;

@end
