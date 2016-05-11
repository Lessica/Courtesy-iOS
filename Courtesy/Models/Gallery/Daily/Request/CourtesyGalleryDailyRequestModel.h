//
//  CourtesyGalleryDailyRequestModel.h
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonRequestModel.h"
#import "CourtesyGalleryDailyCardModel.h"

typedef enum : NSUInteger {
    CourtesyGalleryDailyRequestStandardError = 0,
} CourtesyGalleryDailyRequestErrorCode;

@class CourtesyGalleryDailyRequestModel;

@protocol CourtesyGalleryDailyRequestDelegate <NSObject>
@optional
- (void)galleryDailyRequestSucceed:(CourtesyGalleryDailyRequestModel *)sender;
@optional
- (void)galleryDailyRequestFailed:(CourtesyGalleryDailyRequestModel *)sender
                        withError:(NSError *)error;

@end

@interface CourtesyGalleryDailyRequestModel : CourtesyCommonRequestModel
@property (nonatomic, copy) NSString *s_date;
@property (nonatomic, strong) NSArray <CourtesyGalleryDailyCardModel *> *cards;
@property (nonatomic, weak) id<Ignore, CourtesyGalleryDailyRequestDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate;
- (void)sendRequest;

@end
