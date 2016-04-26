//
//  CourtesyGalleryDailyCardImageModel.h
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonResourceModel.h"

@interface CourtesyGalleryDailyCardImageModel : CourtesyCommonResourceModel
@property (nonatomic, assign) CGFloat width; // 图片宽度
@property (nonatomic, assign) CGFloat height; // 图片高度
@property (nonatomic, copy) NSString *title; // 图片标题

@end
