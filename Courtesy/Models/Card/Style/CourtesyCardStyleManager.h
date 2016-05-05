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
@property (nonatomic, strong) NSArray <NSString *> *styleNames;
@property (nonatomic, strong) NSArray <UIImage *> *styleImages;
@property (nonatomic, strong) NSArray <UIImage *> *styleCheckmarks;

+ (id)sharedManager;
- (CourtesyCardStyleModel *)styleWithID:(CourtesyCardStyleID)styleID;
@end
