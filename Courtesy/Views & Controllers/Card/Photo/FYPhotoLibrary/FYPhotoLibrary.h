//
//  FYPhotoLibrary.h
//  FYPhotoLibrary
//
//  Created by Francisco Yarad on 4/7/15.
//  Copyright (c) 2015 Francisco Yarad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "UIImage+ProportionalFill.h"

#define PHKitExists ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)

typedef void (^VoidBlock)();
typedef enum {FYPhotoLibraryAssetTypeAll, FYPhotoLibraryAssetTypePanoramas, FYPhotoLibraryAssetTypePhotos, FYPhotoLibraryAssetTypeVideos} FYPhotoLibraryAssetType;
typedef enum {FYPhotoLibraryPermissionStatusDenied = 0, FYPhotoLibraryPermissionStatusGranted, FYPhotoLibraryPermissionStatusPending} FYPhotoLibraryPermissionStatus;

typedef void (^FYPhotoLibraryAccessHandler)(FYPhotoLibraryPermissionStatus status);
typedef void (^FYPhotoLibraryAccessHandlerGetImagesBlock)(NSArray *assets);

@interface FYPhotoLibrary : NSObject

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSOperationQueue *queue;

+ (FYPhotoLibrary*)sharedInstance;

// Permissions
- (FYPhotoLibraryPermissionStatus)permissionStatus;
- (void)requestLibraryAccessHandler:(FYPhotoLibraryAccessHandler)handler;

// Library
- (void)getImagesOfType:(FYPhotoLibraryAssetType)type finishBlock:(FYPhotoLibraryAccessHandlerGetImagesBlock)success;

@end
