//
//  CourtesyGalleryDailyCardView.h
//  Courtesy
//
//  Created by Zheng on 4/30/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyGalleryDailyCardModel.h"

@interface CourtesyGalleryDailyCardView : UIView
@property (nonatomic, strong) NSDate *targetDate;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) CourtesyGalleryDailyCardModel *dailyCard;

//- (void)setErrorMessage:(NSString *)errorMessage;

@end
