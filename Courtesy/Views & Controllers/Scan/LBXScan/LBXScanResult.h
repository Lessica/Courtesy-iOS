#import <Foundation/Foundation.h>

@interface LBXScanResult : NSObject
@property (nonatomic, copy) NSString* strScanned;
@property (nonatomic, strong) UIImage* imgScanned;
@property (nonatomic, copy) NSString* strBarCodeType;

- (instancetype)initWithScanString:(NSString*)str
                           imgScan:(UIImage*)img
                       barCodeType:(NSString*)type;

@end
