//
//  FYPhotoLibrary.m
//  FYPhotoLibrary
//
//  Created by Francisco Yarad on 4/7/15.
//  Copyright (c) 2015 Francisco Yarad. All rights reserved.
//

#import "FYPhotoLibrary.h"
#import "FYPhotoAsset.h"

#define kPanoramaRatio 1.9

@implementation FYPhotoLibrary

+ (instancetype)sharedInstance {
    static FYPhotoLibrary *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[FYPhotoLibrary alloc] init];
        _sharedInstance.queue = [[NSOperationQueue alloc] init];
        _sharedInstance.assetsLibrary = (PHKitExists) ? nil : [[ALAssetsLibrary alloc] init];
    });
    return _sharedInstance;
}

- (void)requestLibraryAccessHandler:(FYPhotoLibraryAccessHandler)handler {
    
    if (PHKitExists) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [self executeInMainThread:^{
                if (handler) handler([self permissionStatusFromPH:status]);
            }];
        }];
        
    }
    else {

        [self.queue addOperationWithBlock:^{

            VoidBlock checkPermissions = ^{
                [self executeInMainThread:^{
                    if (handler) handler([self permissionStatusFromAL:[ALAssetsLibrary authorizationStatus]]);
                }];
            };
            
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                checkPermissions();
            } failureBlock:^(NSError *error) {
                checkPermissions();
            }];

        }];
        
    }
    
}
- (void)getImagesOfType:(FYPhotoLibraryAssetType)type finishBlock:(FYPhotoLibraryAccessHandlerGetImagesBlock)success {
    
    [self.queue addOperationWithBlock:^{
        
        FYPhotoLibraryPermissionStatus status = [self permissionStatus];
        
        if (status == FYPhotoLibraryPermissionStatusGranted) {
            
            NSMutableArray *assetsResult = [[NSMutableArray alloc] init];
            
            if (PHKitExists) {

                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                
                if (type == FYPhotoLibraryAssetTypePhotos || type == FYPhotoLibraryAssetTypePanoramas) {                    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
                }
                else if (type == FYPhotoLibraryAssetTypeVideos) {
                    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeVideo];
                }

                PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
                [albums enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger idx, BOOL *stop) {
                    [[PHAsset fetchAssetsInAssetCollection:assetCollection options:options] enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx2, BOOL *stop2) {
                        if (type == FYPhotoLibraryAssetTypePanoramas) {
                            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoPanorama || (asset.pixelWidth/asset.pixelHeight > kPanoramaRatio)) {
                                [assetsResult addObject:[[FYPhotoAsset alloc] initWithPHAsset:asset]];
                            }
                        }
                        else {
                            [assetsResult addObject:[[FYPhotoAsset alloc] initWithPHAsset:asset]];
                        }
                    }];
                }];
                
                [self executeInMainThread:^{
                    if (success) success(assetsResult);
                }];

                
            }
            else {

                [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    if (group) {
                        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
                            
                            BOOL add = (type == FYPhotoLibraryAssetTypeAll);
                            
                            if (type == FYPhotoLibraryAssetTypePhotos) {
                                add = ([result valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto);
                            }
                            else if (type == FYPhotoLibraryAssetTypeVideos) {
                                add = ([result valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo);
                            }
                            else if (type == FYPhotoLibraryAssetTypePanoramas) {
                                add = ([result valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto && result.defaultRepresentation.dimensions.width/result.defaultRepresentation.dimensions.height > kPanoramaRatio);
                            }
                            
                            if (add) {
                                [assetsResult insertObject:[[FYPhotoAsset alloc] initWithALAsset:result] atIndex:0];
                            }
                        }];
                    }

                    [self executeInMainThread:^{
                        if (success) success(assetsResult);
                    }];
                    
                } failureBlock:^(NSError *error) {
                    [self executeInMainThread:^{
                        if (success) success(nil);
                    }];
                }];
            }
            

        }
        else {
            [self executeInMainThread:^{
                if (success) success(nil);
            }];
        }
        
    }];

    
}

#pragma mark - Helpers

- (FYPhotoLibraryPermissionStatus)permissionStatus {
    if (PHKitExists) {
        return [self permissionStatusFromPH:[PHPhotoLibrary authorizationStatus]];
    }
    else {
        return [self permissionStatusFromAL:[ALAssetsLibrary authorizationStatus]];
    }
}
- (FYPhotoLibraryPermissionStatus)permissionStatusFromPH:(PHAuthorizationStatus)status {
    if (status == PHAuthorizationStatusAuthorized) return FYPhotoLibraryPermissionStatusGranted;
    else if (status == PHAuthorizationStatusNotDetermined) return FYPhotoLibraryPermissionStatusPending;
    else return FYPhotoLibraryPermissionStatusDenied;
}
- (FYPhotoLibraryPermissionStatus)permissionStatusFromAL:(ALAuthorizationStatus)status {
    if (status == ALAuthorizationStatusAuthorized) return FYPhotoLibraryPermissionStatusGranted;
    else if (status == ALAuthorizationStatusNotDetermined) return FYPhotoLibraryPermissionStatusPending;
    else return FYPhotoLibraryPermissionStatusDenied;
}
- (void)executeInMainThread:(VoidBlock)block {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

@end
