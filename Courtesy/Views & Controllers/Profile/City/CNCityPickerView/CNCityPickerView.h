//
//  CNCityPickerView.h
//  CNCityPickerView
//
//  Created by 伟明 毕 on 15/3/25.
//  Copyright (c) 2015年 Weiming Bi. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 一个基于UIPickerView的中国城市选择器，简单易用。 By Weiming Bi */
@interface CNCityPickerView : UIView

@property (strong, nonatomic, readonly) UIPickerView *pickerView;

/** 滚动Picker回调的块 */
@property (copy, nonatomic, readwrite) void (^valueChangedCallback)(NSString *province, NSString *city, NSString *area);

/** 设置滚动Picker回调的块 */
- (void)setValueChangedCallback:(void (^)(NSString *province, NSString *city, NSString *area))valueChangedCallback;

// 下面属性为可选设置：

/** 每行的高度， 默认为24.0f */
@property (assign, nonatomic, readwrite) CGFloat rowHeight;

/**
 文本属性
 
 赋值如：
 @{
    NSForegroundColorAttributeName : [UIColor grayColor],
    NSFontAttributeName : [UIFont boldSystemFontOfSize:18.0f]
  }
 */
@property (strong, nonatomic, readwrite) NSDictionary *textAttributes;

/**
 *  创建CNCityPickerView
 *
 *  @param frame                必须要设置设置的frame
 *  @param valueChangedCallback 当滚动PickerView之后的回调块，返回参数分别是省份、城市、区的字符串
 *
 *  @return A CNCityPickerView Object
 */
+ (instancetype)createPickerViewWithFrame:(CGRect)frame valueChangedCallback:(void (^)(NSString *province, NSString *city, NSString *area))valueChangedCallback;

@end
