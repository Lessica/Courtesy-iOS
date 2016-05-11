//
//  CourtesyGalleryDailyCardModel.h
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyGalleryDailyCardStyleModel.h"
#import "CourtesyGalleryDailyCardImageModel.h"
#import "CourtesyGalleryDailyCardVideoModel.h"
#import "CourtesyGalleryDailyCardAudioModel.h"

@interface CourtesyGalleryDailyCardModel : JSONModel
@property (nonatomic, strong) CourtesyGalleryDailyCardStyleModel *style;
@property (nonatomic, copy)   NSString *string;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) CourtesyGalleryDailyCardImageModel<Optional> *image;
@property (nonatomic, strong) CourtesyGalleryDailyCardVideoModel<Optional> *video;
@property (nonatomic, strong) CourtesyGalleryDailyCardAudioModel<Optional> *audio;
@property (nonatomic, copy)   NSString<Optional> *url;
@property (nonatomic, copy)   NSString<Optional> *type;

@end
