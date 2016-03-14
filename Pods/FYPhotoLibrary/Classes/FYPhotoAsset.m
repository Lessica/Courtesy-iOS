//
//  FYPhotoAsset.m
//  FYPhotoLibrary
//
//  Created by Francisco Yarad on 4/7/15.
//  Copyright (c) 2015 Francisco Yarad. All rights reserved.
//

#import "FYPhotoAsset.h"
#import <ImageIO/ImageIO.h>

@interface FYPhotoAsset ()

@property (nonatomic, strong) UIImage *cachedThumbnail;

@end

@implementation FYPhotoAsset

- (id)initWithALAsset:(ALAsset *)asset {
    self = [super init];
    if (self) {
        self.alAsset = asset;
    }
    return self;
}
- (id)initWithPHAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        self.phAsset = asset;
    }
    return self;
}
- (void)getThumbnail:(FYPhotoAssetGetImage)result size:(CGSize)size {
    
    VoidBlock returnBlock = ^{
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(self.cachedThumbnail);
            });
        }
    };
    
    
    if (self.cachedThumbnail == nil) {
        
        FYPhotoLibrary *library = [FYPhotoLibrary sharedInstance];
        
        if (self.alAsset) {
            self.cachedThumbnail = [UIImage imageWithCGImage:self.alAsset.aspectRatioThumbnail];
            returnBlock();
        }
        else {
            [library.queue addOperationWithBlock:^{
                
                CGFloat scale = [UIScreen mainScreen].scale;
                
                PHImageManager *manager = [PHImageManager defaultManager];
                [manager requestImageForAsset:self.phAsset targetSize:CGSizeMake(size.width * scale, size.height * scale) contentMode:PHImageContentModeAspectFill options:[self PHResizeOptions] resultHandler:^(UIImage *image, NSDictionary *info) {
                    self.cachedThumbnail = image;
                    returnBlock();
                }];
                
            }];
        }
        
    }
    else {
        returnBlock();
    }
    
}
- (void)getScaledImage:(FYPhotoAssetGetImage)result height:(CGFloat)height {
    FYPhotoLibrary *library = [FYPhotoLibrary sharedInstance];
    
    if (self.alAsset) {
        [library.queue addOperationWithBlock:^{
            
            UIImage *original = [self thumbnailForALAsset:self.alAsset maxPixelSize:2500];
            UIImage *scaled = [original imageScaledToFitSize:CGSizeMake((original.size.width * height) / original.size.height, height)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) result(scaled);
            });
            
        }];
    }
    else {
        
        [library.queue addOperationWithBlock:^{
            
            CGSize targetSize = CGSizeMake((self.phAsset.pixelWidth * height) / self.phAsset.pixelHeight, height);
            
            PHImageManager *manager = [PHImageManager defaultManager];
            [manager requestImageForAsset:self.phAsset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:[self PHResizeOptions] resultHandler:^(UIImage *image, NSDictionary *info) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (result) result(image);
                });
            }];
            
        }];
        
    }
    
}
- (void)getOriginalImageData:(FYPhotoAssetGetImageData)result {
    
    FYPhotoLibrary *library = [FYPhotoLibrary sharedInstance];
    
    if (self.alAsset) {
        [library.queue addOperationWithBlock:^{
            
            UIImage *original = [self thumbnailForALAsset:self.alAsset maxPixelSize:2500];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) result(UIImagePNGRepresentation(original));
            });
            
        }];
    }
    else {
        
        [library.queue addOperationWithBlock:^{
            
            PHImageManager *manager = [PHImageManager defaultManager];
            [manager requestImageDataForAsset:self.phAsset options:[self PHResizeOptions] resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (result) result(imageData);
                });
                
            }];
            
        }];
        
    }
    
    
}

#pragma mark - MetaData

- (void)getCoordinates:(FYPhotoAssetGetCoordinates)result errorBlock:(VoidBlock)errorBlock {
    
    if (self.alAsset) {
        if ([self.alAsset valueForProperty:ALAssetPropertyLocation]) {
            if (result) result([[self.alAsset valueForProperty:ALAssetPropertyLocation] coordinate]);
        }
        else {
            if (errorBlock) errorBlock();
        }
    }
    
    else {
        if (self.phAsset.location) {
            if (result) result(self.phAsset.location.coordinate);
        }
        else {
            if (errorBlock) errorBlock();
        }
    }
}
- (NSDate*)creationDate {
    if (self.alAsset) {
        if ([self.alAsset valueForProperty:ALAssetPropertyDate]) {
            return [self.alAsset valueForProperty:ALAssetPropertyDate];
        }
    }
    else {
        return self.phAsset.creationDate;
    }
    
    return [NSDate date];
}

#pragma mark - PHAsset resize

- (PHImageRequestOptions*)PHResizeOptions {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    [options setDeliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat];
    [options setResizeMode:PHImageRequestOptionsResizeModeExact];
    return options;
}

#pragma mark - ALAsset resize

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    return [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:nil];
}
static void releaseAssetCallback(void *info) {
    CFRelease(info);
}
- (UIImage *)thumbnailForALAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size {
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                                                      (NSString *)kCGImageSourceThumbnailMaxPixelSize : @(size),
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                                                                      });
    releaseAssetCallback(source);
    releaseAssetCallback(provider);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    releaseAssetCallback(imageRef);
    
    return toReturn;
}

@end
