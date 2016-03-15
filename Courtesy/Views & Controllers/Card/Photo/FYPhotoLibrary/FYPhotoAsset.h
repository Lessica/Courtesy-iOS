//
//  FYPhotoAsset.h
//  FYPhotoLibrary
//
//  Created by Francisco Yarad on 4/7/15.
//  Copyright (c) 2015 Francisco Yarad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FYPhotoLibrary.h"
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "UIImage+ProportionalFill.h"

typedef void (^FYPhotoAssetGetImage)(UIImage *image);
typedef void (^FYPhotoAssetGetImageData)(NSData *imageData);
typedef void (^FYPhotoAssetGetCoordinates)(CLLocationCoordinate2D coordinates);

@interface FYPhotoAsset : NSObject

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
@property (nonatomic, strong) ALAsset *alAsset;
@property (nonatomic, strong) PHAsset *phAsset;

- (id)initWithALAsset:(ALAsset*)asset;
- (id)initWithPHAsset:(PHAsset*)asset;
#pragma clang diagnostic pop

- (void)getThumbnail:(FYPhotoAssetGetImage)result size:(CGSize)size;
- (void)getScaledImage:(FYPhotoAssetGetImage)result height:(CGFloat)height;
- (void)getOriginalImageData:(FYPhotoAssetGetImageData)result;

- (void)getCoordinates:(FYPhotoAssetGetCoordinates)result errorBlock:(VoidBlock)errorBlock;

- (NSDate*)creationDate;

@end
