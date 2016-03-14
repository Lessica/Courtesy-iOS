//
//  CourtesyCardStyleManager.h
//  Courtesy
//
//  Created by Zheng on 3/14/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardStyleModel.h"
#import <Foundation/Foundation.h>

@interface CourtesyCardStyleManager : NSObject
+ (id)sharedManager;
- (CourtesyCardStyleModel *)styleWithID:(CourtesyCardStyleID)styleID;

@end
