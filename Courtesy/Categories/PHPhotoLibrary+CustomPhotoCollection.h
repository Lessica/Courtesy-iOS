//
//  PHPhotoLibrary+CustomPhotoCollection.h
//  保存到自定义相册测试
//
//  Created by 云翼天 on 16/3/7.
//  Copyright © 2016年 MFK. All rights reserved.
//

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface PHPhotoLibrary (CustomPhotoCollection)

/**
 *  保存照片到自定义相册或相机胶卷
 *  注意:方法执行线程默认为子线程, 如果需要在回调里执行UI操作, 请
 *
 *       |image| : 图片, 不能为空
 *   |albumName| : 自定义相册的名字, 如果没有同名的相册, 将会创建一个新的相册, 内容为空时为保存到相机胶卷
 *  |completion| : 当保存图片到自定义相册成功时的回调, 返回一个BOOL值
 *     |failure| : 当保存图片到自定义相册失败时的回调, 返回一个自定义错误, 以判断是哪一处出错
 */
- (void)saveImage:(UIImage * _Nullable)image
          toAlbum:(NSString * _Nullable)albumName
       completion:(void(^ _Nullable)(BOOL success))completion
          failure:(void(^ _Nullable)(NSError * _Nullable error))failure;

@end
