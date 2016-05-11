#import "LBXScanViewStyle.h"

@implementation LBXScanViewStyle

- (instancetype)init {
    if (self =  [super init]) {
        self.isNeedShowRetangle = YES;
        self.whRatio = 1.0;
        self.colorRetangleLine = [UIColor whiteColor];
        self.centerUpOffset = 44;
        self.xScanRetangleOffset = 60;
        self.animationStyle = LBXScanViewAnimationStyle_LineMove;
        self.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
        self.colorAngle = [UIColor colorWithRed:0. green:167./255. blue:231./255. alpha:1.0];
        self.red_notRecoginitonArea = 0.0;
        self.green_notRecoginitonArea = 0.0;
        self.blue_notRecoginitonArea = 0.0;
        self.alpa_notRecoginitonArea = 0.5;
        self.photoframeAngleW = 24;
        self.photoframeAngleH = 24;
        self.photoframeLineW = 7;
    }
    return self;
}

@end

