#import <UIKit/UIKit.h>
#import "LBXScanLineAnimation.h"
#import "LBXScanViewStyle.h"

@interface LBXScanView : UIView
- (id)initWithFrame:(CGRect)frame
              style:(LBXScanViewStyle *)style;
- (void)startDeviceReadyingWithText:(NSString *)text;
- (void)stopDeviceReadying;
- (void)startScanAnimation;
- (void)stopScanAnimation;
+ (CGRect)getScanRectWithPreView:(UIView *)view
                           style:(LBXScanViewStyle *)style;
@end
