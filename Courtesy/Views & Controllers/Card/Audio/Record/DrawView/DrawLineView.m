//
//  DrawLineView.m
//  Animations
//
//  Created by YouXianMing on 15/12/5.
//  Copyright © 2015年 YouXianMing. All rights reserved.
//

#import "DrawLineView.h"
#import "CGContextObject.h"
#import "DrawValues.h"

@interface DrawLineView ()

@property (nonatomic, strong) CGContextObject *contextObject;
@property (nonatomic, strong) DrawValues      *drawValues;

@end

@implementation DrawLineView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.drawValues               = [DrawValues new];
        self.drawValues.valueCapacity = (NSInteger)[UIScreen mainScreen].bounds.size.width;
        self.drawValues.middleValue   = 90.0f;
        [self.drawValues buildValues];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (_avgValue == 0) {
        return;
    }
    
    CGContextObjectConfig *config = [CGContextObjectConfig new];
    config.fillColor              = [RGBColor colorWithUIColor:[UIColor lightGrayColor]];
    config.strokeColor            = [RGBColor colorWithUIColor:[UIColor clearColor]];
    config.lineWidth              = 0.5f;
    config.lineCap                = kCGLineCapRound;
    
    _contextObject = [[CGContextObject alloc] initWithCGContext:UIGraphicsGetCurrentContext()
                                                         config:config];
    int value = (int)(35.0 + _avgValue);
    if (value > 40.0) {
        value = 40.0;
    } else if (value < 0) {
        value = 0;
    }
    [self.drawValues addValue:[NSNumber numberWithFloat:(value % 41)]];
    
    [self.contextObject contextConfig:nil drawFillBlock:^(CGContextObject *contextObject) {
        
        [_contextObject addRectPath:CGRectMake(0, 90.0f, [UIScreen mainScreen].bounds.size.width, 0.5f)];
        
        for (int i = 0; i < _drawValues.values.count; i++) {
            
            NSNumber *value = _drawValues.values[i];
            CGFloat   tmp   = value.floatValue;
            
            if (tmp >= 90.0) {
                
                [_contextObject addRectPath:CGRectMake(i, 90.0, 1.f, tmp - 90.0)];
                
            } else {
            
                [_contextObject addRectPath:CGRectMake(i, tmp, 1.f, 90.0 - tmp)];
            }
        }
    }];
}

@end
