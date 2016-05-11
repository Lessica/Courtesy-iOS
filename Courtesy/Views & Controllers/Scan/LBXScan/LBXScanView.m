#import "LBXScanView.h"

@interface LBXScanView()
@property (nonatomic, strong) LBXScanViewStyle* viewStyle;
@property (nonatomic,assign)CGRect scanRetangleRect;
@property (nonatomic,strong)LBXScanLineAnimation *scanLineAnimation;
@property (nonatomic,strong)UIImageView *scanLineStill;
@property(nonatomic,strong)UIActivityIndicatorView* activityView;
@property(nonatomic,strong)UILabel *labelReadying;

@end

@implementation LBXScanView

- (id)initWithFrame:(CGRect)frame
              style:(LBXScanViewStyle *)style {
    if (self = [super initWithFrame:frame]) {
        self.viewStyle = style;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self drawScanRect];
}

- (void)startDeviceReadyingWithText:(NSString *)text {
    int XRetangleLeft = _viewStyle.xScanRetangleOffset;
    CGFloat width = self.frame.size.width;
    CGSize sizeRetangle = CGSizeMake(width - XRetangleLeft*2, width- XRetangleLeft*2);
    
    if (!_viewStyle.isNeedShowRetangle) {
        
        CGFloat w = sizeRetangle.width;
        CGFloat h = w / _viewStyle.whRatio;
        
        NSInteger hInt = (NSInteger)h;
        h  = hInt;
        
        sizeRetangle = CGSizeMake(w, h);
    }
    
    CGFloat YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - _viewStyle.centerUpOffset;
    
    if (!_activityView)
    {
        self.activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_activityView setCenter:CGPointMake(XRetangleLeft +  sizeRetangle.width/2 - 50, YMinRetangle + sizeRetangle.height/2)];
        
        [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:_activityView];
        
        CGRect labelReadyRect = CGRectMake(_activityView.frame.origin.x + _activityView.frame.size.width + 10, _activityView.frame.origin.y, 100, 30);
        self.labelReadying = [[UILabel alloc]initWithFrame:labelReadyRect];
        _labelReadying.backgroundColor = [UIColor clearColor];
        _labelReadying.textColor  = [UIColor whiteColor];
        _labelReadying.font = [UIFont systemFontOfSize:18.];
        _labelReadying.text = text;
        
        [self addSubview:_labelReadying];
        
        [_activityView startAnimating];
    }

}

- (void)stopDeviceReadying
{
    if (_activityView) {
        
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
        [_labelReadying removeFromSuperview];
        
        self.activityView = nil;
        self.labelReadying = nil;
    }
}

- (void)startScanAnimation
{
    switch (_viewStyle.animationStyle)
    {
        case LBXScanViewAnimationStyle_LineMove:
        {
            if (!_scanLineAnimation)
                self.scanLineAnimation = [[LBXScanLineAnimation alloc]init];
            [_scanLineAnimation startAnimatingWithRect:_scanRetangleRect
                                                InView:self
                                                 Image:_viewStyle.animationImage];
        } break;
        case LBXScanViewAnimationStyle_LineStill:
        {
            if (!_scanLineStill) {
                
                CGRect stillRect = CGRectMake(_scanRetangleRect.origin.x+20,
                                              _scanRetangleRect.origin.y + _scanRetangleRect.size.height/2,
                                              _scanRetangleRect.size.width-40,
                                              2);
                _scanLineStill = [[UIImageView alloc]initWithFrame:stillRect];
                _scanLineStill.image = _viewStyle.animationImage;
            }
            [self addSubview:_scanLineStill];
        } break;
        default:
            break;
    }
}

- (void)stopScanAnimation
{
    if (_scanLineAnimation) {
        [_scanLineAnimation stopAnimating];
    }
    if (_scanLineStill) {
        [_scanLineStill removeFromSuperview];
    }
}


- (void)drawScanRect
{
    int XRetangleLeft = _viewStyle.xScanRetangleOffset;
    CGSize sizeRetangle = CGSizeMake(self.frame.size.width - XRetangleLeft*2, self.frame.size.width - XRetangleLeft*2);
    if (_viewStyle.whRatio != 1)
    {        
        CGFloat w = sizeRetangle.width;
        CGFloat h = w / _viewStyle.whRatio;
        
        NSInteger hInt = (NSInteger)h;
        h  = hInt;
        
        sizeRetangle = CGSizeMake(w, h);
    }
    
    CGFloat YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - _viewStyle.centerUpOffset;
    CGFloat YMaxRetangle = YMinRetangle + sizeRetangle.height;
    CGFloat XRetangleRight = self.frame.size.width - XRetangleLeft;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    {
        CGContextSetRGBFillColor(context, _viewStyle.red_notRecoginitonArea, _viewStyle.green_notRecoginitonArea,
                                 _viewStyle.blue_notRecoginitonArea, _viewStyle.alpa_notRecoginitonArea);
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, YMinRetangle);
        CGContextFillRect(context, rect);
        rect = CGRectMake(0, YMinRetangle, XRetangleLeft,sizeRetangle.height);
        CGContextFillRect(context, rect);
        rect = CGRectMake(XRetangleRight, YMinRetangle, XRetangleLeft,sizeRetangle.height);
        CGContextFillRect(context, rect);
        rect = CGRectMake(0, YMaxRetangle, self.frame.size.width,self.frame.size.height - YMaxRetangle);
        CGContextFillRect(context, rect);
        CGContextStrokePath(context);
    }
    
    if (_viewStyle.isNeedShowRetangle)
    {
        CGContextSetStrokeColorWithColor(context, _viewStyle.colorRetangleLine.CGColor);
        CGContextSetLineWidth(context, 1);
        CGContextAddRect(context, CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height));
        CGContextStrokePath(context);
       
    }
    _scanRetangleRect = CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height);
    int wAngle = _viewStyle.photoframeAngleW;
    int hAngle = _viewStyle.photoframeAngleH;
    CGFloat linewidthAngle = _viewStyle.photoframeLineW;
    CGFloat diffAngle = linewidthAngle / 3;
    
    switch (_viewStyle.photoframeAngleStyle)
    {
        case LBXScanViewPhotoframeAngleStyle_Outer:
        {
            diffAngle = linewidthAngle / 3;
        } break;
        case LBXScanViewPhotoframeAngleStyle_On:
        {
            diffAngle = 0;
        } break;
        case LBXScanViewPhotoframeAngleStyle_Inner:
        {           
            diffAngle = -_viewStyle.photoframeLineW/2;
            
        } break;
        default:
            break;
    }
    
    CGContextSetStrokeColorWithColor(context, _viewStyle.colorAngle.CGColor);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, linewidthAngle);
    
    CGFloat leftX = XRetangleLeft - diffAngle;
    CGFloat topY = YMinRetangle - diffAngle;
    CGFloat rightX = XRetangleRight + diffAngle;
    CGFloat bottomY = YMaxRetangle + diffAngle;
    
    CGContextMoveToPoint(context, leftX-linewidthAngle / 2, topY);
    CGContextAddLineToPoint(context, leftX + wAngle, topY);
    CGContextMoveToPoint(context, leftX, topY - linewidthAngle / 2);
    CGContextAddLineToPoint(context, leftX, topY + hAngle);
    
    CGContextMoveToPoint(context, leftX-linewidthAngle / 2, bottomY);
    CGContextAddLineToPoint(context, leftX + wAngle, bottomY);
    
    CGContextMoveToPoint(context, leftX, bottomY+linewidthAngle / 2);
    CGContextAddLineToPoint(context, leftX, bottomY - hAngle);
    
    CGContextMoveToPoint(context, rightX+linewidthAngle / 2, topY);
    CGContextAddLineToPoint(context, rightX - wAngle, topY);
    
    CGContextMoveToPoint(context, rightX, topY-linewidthAngle / 2);
    CGContextAddLineToPoint(context, rightX, topY + hAngle);
    
    CGContextMoveToPoint(context, rightX+linewidthAngle / 2, bottomY);
    CGContextAddLineToPoint(context, rightX - wAngle, bottomY);
    
    CGContextMoveToPoint(context, rightX, bottomY + linewidthAngle / 2);
    CGContextAddLineToPoint(context, rightX, bottomY - hAngle);
    
    CGContextStrokePath(context);
}

+ (CGRect)getScanRectWithPreView:(UIView*)view style:(LBXScanViewStyle*)style {
    int XRetangleLeft = style.xScanRetangleOffset;
    CGSize sizeRetangle = CGSizeMake(view.frame.size.width - XRetangleLeft*2, view.frame.size.width - XRetangleLeft*2);
    if (style.whRatio != 1) {
        CGFloat w = sizeRetangle.width;
        CGFloat h = w / style.whRatio;
        NSInteger hInt = (NSInteger)h;
        h  = hInt;
        sizeRetangle = CGSizeMake(w, h);
    }
    CGFloat YMinRetangle = view.frame.size.height / 2.0 - sizeRetangle.height/2.0 - style.centerUpOffset;
    CGRect cropRect =  CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height);
    CGRect rectOfInterest;
    CGSize size = view.bounds.size;
    CGFloat p1 = size.height / size.width;
    CGFloat p2 = 1920.f / 1080.f;
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920.f / 1080.f;
        CGFloat fixPadding = (fixHeight - size.height) / 2;
        rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding) / fixHeight,
                                           cropRect.origin.x / size.width,
                                           cropRect.size.height / fixHeight,
                                           cropRect.size.width / size.width);
       
        
    } else {
        CGFloat fixWidth = size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width) / 2;
        rectOfInterest = CGRectMake(cropRect.origin.y / size.height,
                                           (cropRect.origin.x + fixPadding) / fixWidth,
                                           cropRect.size.height / size.height,
                                           cropRect.size.width / fixWidth);
        
        
    }
    return rectOfInterest;
}

@end
