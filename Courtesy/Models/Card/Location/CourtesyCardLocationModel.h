//
//  CourtesyCardLocationModel.h
//  Courtesy
//
//  Created by Zheng on 5/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <AMapSearchKit/AMapSearchKit.h>

@interface CourtesyCardLocationModel : JSONModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) float latitude;

@end
