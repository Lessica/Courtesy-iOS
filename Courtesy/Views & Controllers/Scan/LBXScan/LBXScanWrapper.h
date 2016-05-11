#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LBXScanResult.h"

@interface LBXScanWrapper : NSObject

- (instancetype)initZXingWithPreView:(UIView *)preView success:(void(^)(NSArray<LBXScanResult*> *array))blockScanResult;
- (void)startScan;
- (void)stopScan;
- (void)openFlash:(BOOL)bOpen;
+ (UIImage*)createQRWithString:(NSString*)str size:(CGSize)size;
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;
+ (UIImage*)addImageLogo:(UIImage*)srcImg centerLogoImage:(UIImage*)LogoImage logoSize:(CGSize)logoSize;
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size QRColor:(UIColor*)qrColor bkColor:(UIColor*)bkColor;
+ (UIImage*)createCodeWithString:(NSString*)str size:(CGSize)size CodeFomart:(NSString*)format;
+ (void)recognizeImage:(UIImage*)image success:(void(^)(NSArray<LBXScanResult*> *array))block;
+ (void)systemVibrate;
+ (void)systemSound;
+ (BOOL)isGetCameraPermission;
+ (BOOL)isGetPhotoPermission;

@end




