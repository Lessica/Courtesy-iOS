//
//  CourtesyCardManager.h
//  Courtesy
//
//  Created by Zheng on 3/15/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CourtesyCardModel.h"

@interface CourtesyCardManager : NSObject
+ (id)sharedManager;
+ (CourtesyCardModel *)newCard;

@end
