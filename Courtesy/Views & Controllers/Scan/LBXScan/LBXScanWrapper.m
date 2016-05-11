#import "LBXScanWrapper.h"
#import "ZXingWrapper.h"
#import "ZXBarcodeFormat.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface LBXScanWrapper()
@property (nonatomic, strong) ZXingWrapper *scanZXingObj;
@property (nonatomic, strong) NSArray *arrayBarCodeType;

@end

@implementation LBXScanWrapper

- (instancetype)initZXingWithPreView:(UIView *)preView success:(void(^)(NSArray<LBXScanResult *> *array))blockScanResult
{
    if (self = [super init]) {
        _scanZXingObj = [[ZXingWrapper alloc] initWithPreView:preView block:^(ZXBarcodeFormat barcodeFormat, NSString *str, UIImage *scanImg) {
            if (blockScanResult) {
                NSString *barCodeType = [LBXScanWrapper convertZXBarcodeFormat:barcodeFormat];
                LBXScanResult *result = [[LBXScanResult alloc] initWithScanString:str imgScan:scanImg barCodeType:barCodeType];
                blockScanResult(@[result]);
            }            
        }];
    }
    return self;
}

- (void)startScan {
    [_scanZXingObj start];
}

- (void)stopScan {
    [_scanZXingObj stop];
}

- (void)openFlash:(BOOL)bOpen {
    AVCaptureDevice *device =  [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]) {
        [_scanZXingObj openTorch:bOpen];
    }
}

+ (void)recognizeImage:(UIImage*)image success:(void(^)(NSArray<LBXScanResult*> *array))block {
    __block UIImage* tmpImg = image;
    [ZXingWrapper recognizeImage:image block:^(ZXBarcodeFormat barCodeFormat, NSString* str) {
         NSString *barCodeType = [LBXScanWrapper convertZXBarcodeFormat:barCodeFormat];
         if (block) {
             LBXScanResult *result = [[LBXScanResult alloc]initWithScanString:str imgScan:tmpImg barCodeType:barCodeType];
             block(@[result]);
         }
    }];
}

#define SOUNDID  1109

+ (void)systemVibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)systemSound {
    AudioServicesPlaySystemSound(SOUNDID);
}

+ (BOOL)isGetCameraPermission {
    BOOL isCameraValid = YES;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        isCameraValid = NO;
    }
    return isCameraValid;
}


+ (BOOL)isGetPhotoPermission {
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if (authorStatus == PHAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

+ (NSString*)convertZXBarcodeFormat:(ZXBarcodeFormat)barCodeFormat {
    NSString *strAVMetadataObjectType = nil;
    
    switch (barCodeFormat) {
        case kBarcodeFormatQRCode:
            strAVMetadataObjectType = AVMetadataObjectTypeQRCode;
            break;
        case kBarcodeFormatEan13:
            strAVMetadataObjectType = AVMetadataObjectTypeEAN13Code;
            break;
        case kBarcodeFormatEan8:
            strAVMetadataObjectType = AVMetadataObjectTypeEAN8Code;
            break;
        case kBarcodeFormatPDF417:
            strAVMetadataObjectType = AVMetadataObjectTypePDF417Code;
            break;
        case kBarcodeFormatAztec:
            strAVMetadataObjectType = AVMetadataObjectTypeAztecCode;
            break;
        case kBarcodeFormatCode39:
            strAVMetadataObjectType = AVMetadataObjectTypeCode39Code;
            break;
        case kBarcodeFormatCode93:
            strAVMetadataObjectType = AVMetadataObjectTypeCode93Code;
            break;
        case kBarcodeFormatCode128:
            strAVMetadataObjectType = AVMetadataObjectTypeCode128Code;
            break;
        case kBarcodeFormatDataMatrix:
            strAVMetadataObjectType = AVMetadataObjectTypeDataMatrixCode;
            break;
        case kBarcodeFormatITF:
            strAVMetadataObjectType = AVMetadataObjectTypeITF14Code;
            break;
        case kBarcodeFormatRSS14:
            break;
        case kBarcodeFormatRSSExpanded:
            break;
        case kBarcodeFormatUPCA:
            break;
        case kBarcodeFormatUPCE:
            strAVMetadataObjectType = AVMetadataObjectTypeUPCECode;
            break;
        default:
            break;
    }
    
    return strAVMetadataObjectType;
}

+ (ZXBarcodeFormat)convertCodeFomratToZXBarcodeFormat:(NSString*)strCodeType {
    if ([strCodeType isEqualToString:AVMetadataObjectTypeQRCode])
    {
        return kBarcodeFormatQRCode;
    }
    if ([strCodeType isEqualToString:AVMetadataObjectTypeEAN13Code])
    {
        return kBarcodeFormatEan13;
    }
    if ([strCodeType isEqualToString:AVMetadataObjectTypeEAN8Code])
    {
        return kBarcodeFormatEan8;
    }
    if ([strCodeType isEqualToString:AVMetadataObjectTypePDF417Code])
    {
        return kBarcodeFormatPDF417;
    }
    if ([strCodeType isEqualToString:AVMetadataObjectTypeAztecCode])
    {
        return kBarcodeFormatAztec;
    }
    if ([strCodeType isEqualToString:AVMetadataObjectTypeCode39Code])
    {
        return kBarcodeFormatCode39;
    }
    if ([strCodeType isEqualToString:AVMetadataObjectTypeCode93Code])
    {
        return kBarcodeFormatCode93;
    }
    if ([strCodeType isEqualToString:AVMetadataObjectTypeCode128Code])
    {
        return kBarcodeFormatCode128;
    }
    if ([strCodeType isEqualToString:AVMetadataObjectTypeDataMatrixCode])
    {
        return kBarcodeFormatDataMatrix;
    }
    if ([strCodeType isEqualToString:AVMetadataObjectTypeUPCECode])
    {
        return kBarcodeFormatUPCE;
    }
    return kBarcodeFormatQRCode;
}

+ (UIImage *)createQRWithString:(NSString *)str size:(CGSize)size {
    return  [ZXingWrapper createCodeWithString:str size:size CodeFomart:kBarcodeFormatQRCode];
}


+ (UIImage *)createCodeWithString:(NSString *)str size:(CGSize)size CodeFomart:(NSString *)format {
    ZXBarcodeFormat zxformat = [LBXScanWrapper convertCodeFomratToZXBarcodeFormat:format];
    return  [ZXingWrapper createCodeWithString:str size:size CodeFomart:zxformat];
}

+ (UIImage*)addImageLogo:(UIImage*)srcImg centerLogoImage:(UIImage*)LogoImage logoSize:(CGSize)logoSize {
    UIGraphicsBeginImageContext(srcImg.size);
    [srcImg drawInRect:CGRectMake(0, 0, srcImg.size.width, srcImg.size.height)];
    
    CGRect rect = CGRectMake(srcImg.size.width / 2 - logoSize.width / 2, srcImg.size.height / 2 - logoSize.height / 2, logoSize.width, logoSize.height);
    [LogoImage drawInRect:rect];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

+ (UIImage *)roundedCornerImageWithCornerRadius:(CGFloat)cornerRadius srcImg:(UIImage*)srcImg
{
    CGFloat w = srcImg.size.width;
    CGFloat h = srcImg.size.height;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (cornerRadius < 0)
        cornerRadius = 0;
    else if (cornerRadius > MIN(w, h))
        cornerRadius = MIN(w, h) / 2.;
    
    UIImage *image = nil;
    CGRect imageFrame = CGRectMake(0., 0., w, h);
    UIGraphicsBeginImageContextWithOptions(srcImg.size, NO, scale);
    [[UIBezierPath bezierPathWithRoundedRect:imageFrame cornerRadius:cornerRadius] addClip];
    [srcImg drawInRect:imageFrame];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    UIImage *uImage =[UIImage imageWithCGImage:scaledImage];
    CGColorSpaceRelease(cs);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGImageRelease(scaledImage);
    return uImage;
}

+ (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    return qrFilter.outputImage;
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue {
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; // 0 ~ 255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

#pragma mark - 生成二维码，背景色及二维码颜色设置

+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size QRColor:(UIColor*)qrColor bkColor:(UIColor*)bkColor {
    
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:qrColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:bkColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return codeImage;
}
@end
