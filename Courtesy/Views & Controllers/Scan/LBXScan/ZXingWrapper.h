#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZXBarcodeFormat.h"

@interface ZXingWrapper : NSObject
- (instancetype)initWithPreView:(UIView*)preView block:(void(^)(ZXBarcodeFormat barcodeFormat,NSString *str,UIImage *scanImg))block;
- (void)setScanRect:(CGRect)scanRect;
- (void)start;
- (void)stop;
- (void)openTorch:(BOOL)onoff;
+ (UIImage*)createCodeWithString:(NSString*)str size:(CGSize)size CodeFomart:(ZXBarcodeFormat)format;
+ (void)recognizeImage:(UIImage*)image block:(void(^)(ZXBarcodeFormat barcodeFormat,NSString *str))block;

@end
