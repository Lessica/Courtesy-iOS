//
//  CourtesyGalleryDailyCardStyle.h
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kCourtesyGalleryDailyCardStyleDefault = 0,
    kCourtesyGalleryDailyCardStyleZero    = 1
} CourtesyGalleryDailyCardStyleType;

@interface CourtesyGalleryDailyCardStyleModel : NSObject
@property (nonatomic, assign) CourtesyGalleryDailyCardStyleType style_id;
@property (nonatomic, copy) NSString *style_name;

@end
