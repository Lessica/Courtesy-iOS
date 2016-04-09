//
//  CourtesyGalleryDailyCardModel.h
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CourtesyGalleryDailyCardStyleModel.h"
#import "CourtesyGalleryDailyCardImageModel.h"
#import "CourtesyGalleryDailyCardVideoModel.h"
#import "CourtesyGalleryDailyCardAudioModel.h"

@interface CourtesyGalleryDailyCardModel : NSObject
@property (nonatomic, strong) CourtesyGalleryDailyCardStyleModel *style;
@property (nonatomic, copy) NSString *string;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) CourtesyGalleryDailyCardImageModel *image;
@property (nonatomic, strong) CourtesyGalleryDailyCardVideoModel *video;
@property (nonatomic, strong) CourtesyGalleryDailyCardAudioModel *audio;

@end
