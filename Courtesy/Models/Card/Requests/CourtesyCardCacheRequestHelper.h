//
//  CourtesyCardCacheRequestHelper.h
//  Courtesy
//
//  Created by Zheng on 5/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CourtesyCardModel.h"

typedef enum : NSUInteger {
    CourtesyCardCacheStandardError = 0,
} CourtesyCardCacheErrorCode;

@class CourtesyCardCacheRequestHelper;

@protocol CourtesyCardCacheRequestHelperDelegate <NSObject>
@optional
- (void)cardCacheQuerySucceed:(CourtesyCardCacheRequestHelper *)helper;
@optional
- (void)cardCacheQueryFailed:(CourtesyCardCacheRequestHelper *)helper withError:(NSError *)error;

@optional
- (void)cardCachedSucceed:(CourtesyCardCacheRequestHelper *)helper;
@optional
- (void)cardCachedFailed:(CourtesyCardCacheRequestHelper *)helper withError:(NSError *)error;
@optional
- (void)cardCaching:(CourtesyCardCacheRequestHelper *)helper withProgress:(float)progress;

@end

@interface CourtesyCardCacheRequestHelper : NSObject
@property (nonatomic, strong) CourtesyCardModel *card;
@property (nonatomic, assign) NSUInteger totalBytes;
@property (nonatomic, assign) NSUInteger logicalBytes;

@property (nonatomic, weak) id<CourtesyCardCacheRequestHelperDelegate> delegate;

- (void)sendAsyncCacheRequest;
- (void)sendAsyncQueryRequest;
- (void)stop;
@end
