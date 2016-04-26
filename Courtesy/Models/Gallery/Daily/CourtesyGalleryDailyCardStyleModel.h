//
//  CourtesyGalleryDailyCardStyle.h
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

typedef enum : NSUInteger {
    kCourtesyGalleryDailyCardStyleDefault = 0,
    kCourtesyGalleryDailyCardStyleZero    = 1, // 首张卡片
    kCourtesyGalleryDailyCardStyleGroup   = 2, // 卡片套组
    kCourtesyGalleryDailyCardStyleArticle = 3, // 长文
    kCourtesyGalleryDailyCardStyleLink    = 4, // 外链
} CourtesyGalleryDailyCardStyleType;

@interface CourtesyGalleryDailyCardStyleModel : JSONModel
@property (nonatomic, assign) CourtesyGalleryDailyCardStyleType style_id;
@property (nonatomic, copy) NSString *style_name;

@end
