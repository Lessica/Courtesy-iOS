//
//  PHPhotoLibrary+CustomPhotoCollection.m
//  保存到自定义相册测试
//
//  Created by 云翼天 on 16/3/7.
//  Copyright © 2016年 MFK. All rights reserved.
//

#import "PHPhotoLibrary+CustomPhotoCollection.h"

#define CustomErrorDomainForSave @"com.saveImage.error"
typedef NS_ENUM(NSInteger, SaveImageFailure) {
    SaveImageFailureFromCameraRoll = -10000,    //保存到相机胶卷时出错
    SaveImageFailureFromCustomPhotoCollection,  //保存到自定义相册时出错
    SaveImageFailureFromDenied,                 //未允许应用访问相册
    SaveImageFailureFromImageIsEmpty,           //图片为空
    SaveImageFailureFromImageIsError            //图片错误, 预留
};

#define CustomErrorDomainForLoad @"com.loadImage.error"
typedef NS_ENUM(NSInteger, LoadAlbumFailure) {
    LoadAlbumFailureFromNone = -20000          //相册名不存在
};

@implementation PHPhotoLibrary (CustomPhotoCollection)

- (void)saveImage:(UIImage *)image
          toAlbum:(NSString *)albumName
       completion:(void (^ _Nullable)(BOOL))completion
          failure:(void (^ _Nullable)(NSError * _Nullable))failure {
    
    __block NSError *saveImageError = nil;
    
    //判断是否未授权
    NSInteger status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized) {
        if (failure) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"不能访问相册" forKey:NSLocalizedDescriptionKey];
            saveImageError = [NSError errorWithDomain:CustomErrorDomainForSave code:SaveImageFailureFromDenied userInfo:userInfo];
            failure(saveImageError);
        }
        return;
    }
    
    //判断图片是否为空
    if (image == nil) {
        if (failure) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@"保存失败, 图片不能为空" forKey:NSLocalizedFailureReasonErrorKey];
            [userInfo setObject:@"建议添加图片" forKey:NSLocalizedRecoverySuggestionErrorKey];
            saveImageError = [NSError errorWithDomain:CustomErrorDomainForSave code:SaveImageFailureFromImageIsEmpty userInfo:userInfo];
            failure(saveImageError);
        }
        return;
    }

    //先保存到相机胶卷中, 顺便获得相片id
    //再将相片保存到自定义相册中
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        assetID = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"未保存到系统相册" forKey:NSLocalizedDescriptionKey];
                saveImageError = [NSError errorWithDomain:CustomErrorDomainForSave code:SaveImageFailureFromCameraRoll userInfo:userInfo];
                failure(saveImageError);
            }
            return;
        } else {
            
            //判断相册名是否为空
            if (albumName.length < 1) {
                if (completion) {
                    completion(success);
                }
                return;
            }
            
            // 开始保存到自定义相册中
            PHAssetCollection *album = [self searchAlbumWithName:albumName];
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:album];
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil].firstObject;
                [request addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    if (failure) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"未保存到自定义相册" forKey:NSLocalizedDescriptionKey];
                        saveImageError = [NSError errorWithDomain:CustomErrorDomainForSave code:SaveImageFailureFromCustomPhotoCollection userInfo:userInfo];
                        failure(saveImageError);
                    }
                    return;
                }
                
                if (completion) {
                    completion(success);
                }
            }];
        }
    }];
}

- (PHAssetCollection *)searchAlbumWithName:(NSString *)albumName {
    //查找相册
    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *album in result) {
        if ([album.localizedTitle isEqualToString:albumName]) {
            return album;
        }
    }
    
    //创建相册
    __block NSString *albumID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        albumID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumID] options:nil].firstObject;
}

@end
