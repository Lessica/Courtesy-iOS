#import <Foundation/Foundation.h>

typedef enum LBXScanViewAnimationStyle {
    LBXScanViewAnimationStyle_LineMove, // 线条上下移动
    LBXScanViewAnimationStyle_LineStill, // 线条停止在扫码区域中央
    LBXScanViewAnimationStyle_None // 无动画
    
} LBXScanViewAnimationStyle;

typedef enum LBXScanViewPhotoframeAngleStyle {
    LBXScanViewPhotoframeAngleStyle_Inner, // 内嵌，一般不显示矩形框情况下
    LBXScanViewPhotoframeAngleStyle_Outer, // 外嵌，包围在矩形框的4个角
    LBXScanViewPhotoframeAngleStyle_On // 在矩形框的4个角上，覆盖
} LBXScanViewPhotoframeAngleStyle;

@interface LBXScanViewStyle : NSObject
@property (nonatomic, assign) BOOL isNeedShowRetangle;
@property (nonatomic, assign) CGFloat whRatio;
@property (nonatomic, assign) CGFloat centerUpOffset;
@property (nonatomic, assign) CGFloat xScanRetangleOffset;
@property (nonatomic, strong) UIColor *colorRetangleLine;
@property (nonatomic, assign) LBXScanViewPhotoframeAngleStyle photoframeAngleStyle;
@property (nonatomic, strong) UIColor* colorAngle;
@property (nonatomic, assign) CGFloat photoframeAngleW;
@property (nonatomic, assign) CGFloat photoframeAngleH;
@property (nonatomic, assign) CGFloat photoframeLineW;
@property (nonatomic, assign) LBXScanViewAnimationStyle animationStyle;
@property (nonatomic, strong) UIImage *animationImage;
@property (nonatomic, assign) CGFloat red_notRecoginitonArea;
@property (nonatomic, assign) CGFloat green_notRecoginitonArea;
@property (nonatomic, assign) CGFloat blue_notRecoginitonArea;
@property (nonatomic, assign) CGFloat alpa_notRecoginitonArea;

@end
