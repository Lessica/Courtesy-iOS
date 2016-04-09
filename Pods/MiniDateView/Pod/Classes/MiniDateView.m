//
//  MiniDateView.m
//  MiniDateView-Demo
//
//  Created by Zheng on 3/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "MiniDateView.h"

@interface MiniDateView ()
@property (nonatomic, strong) NSDateComponents *comps;
@property (nonatomic, assign) NSInteger unitFlags;

@end

@implementation MiniDateView

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 64, 64);
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor grayColor];
    self.unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
}

- (NSDate *)date {
    if (!_date) {
        _date = [NSDate date];
    }
    return _date;
}

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return _calendar;
}

- (NSDateComponents *)comps {
    return [self.calendar components:self.unitFlags fromDate:self.date];
}

- (void)drawRect:(CGRect)rect {
    [self.tintColor set];
    
    // Draw Day Of Month
    int dayOfMonth = (int)[self.comps day];
    int dayOfMonth_A = dayOfMonth / 10;
    int dayOfMonth_B = dayOfMonth % 10;
    if (dayOfMonth_A == 0) {
        UIImage *day_image_b = MiniDateViewSrcVar(@"chosen_day_%d", dayOfMonth_B);
        [day_image_b drawInRect:CGRectMake(27, 0, 18, 27)];
    } else {
        UIImage *day_image_a = MiniDateViewSrcVar(@"chosen_day_%d", dayOfMonth_A);
        [day_image_a drawInRect:CGRectMake(17, 0, 18, 27)];
        UIImage *day_image_b = MiniDateViewSrcVar(@"chosen_day_%d", dayOfMonth_B);
        [day_image_b drawInRect:CGRectMake(36, 0, 18, 27)];
    }
    
    // Draw Weekday
    int weekday = (int)[self.comps weekday];
    UIImage *weekday_image = MiniDateViewSrcVar(@"chosen_weekday_%d", weekday);
    [weekday_image drawInRect:CGRectMake(0, 30, 50.5, 12.5)];
    
    // Draw Month Of Year
    int monthOfYear = (int)[self.comps month];
    UIImage *month_image = MiniDateViewSrcVar(@"chosen_month_%d", monthOfYear);
    [month_image drawInRect:CGRectMake(54, 27, 10, 34)];
    
    // Draw Zero
//    UIImage *zero = MiniDateViewSrc(@"chosen_zero");
//    [zero drawInRect:CGRectMake(28, 48, 16, 16)];
}

@end
