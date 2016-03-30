//
//  MiniDateView.h
//  MiniDateView-Demo
//
//  Created by Zheng on 3/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MiniDateViewSrcName(file) [@"MiniDateView.bundle" stringByAppendingPathComponent:file]
#define MiniDateViewFrameworkSrcName(file) [@"Frameworks/MiniDateView.framework/MiniDateView.bundle" stringByAppendingPathComponent:file]
#define MiniDateViewSrc(name) [[UIImage imageNamed:MiniDateViewSrcName(name)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] ?: [[UIImage imageNamed:MiniDateViewFrameworkSrcName(name)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
#define MiniDateViewSrcVar(name, var) [[UIImage imageNamed:MiniDateViewSrcName(([NSString stringWithFormat:name, var]))] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] ?: [[UIImage imageNamed:MiniDateViewFrameworkSrcName(([NSString stringWithFormat:name, var]))] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

@interface MiniDateView : UIView
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSCalendar *calendar;

@end
