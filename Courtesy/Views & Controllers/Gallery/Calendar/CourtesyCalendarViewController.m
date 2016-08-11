//
//  CourtesyCalendarViewController.m
//  Courtesy
//
//  Created by Zheng on 3/29/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCalendarViewController.h"

@implementation CourtesyCalendarViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIModalTransitionStyle)modalTransitionStyle {
    return UIModalTransitionStyleFlipHorizontal;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    [[PDTSimpleCalendarViewCell appearance] setCircleDefaultColor:[UIColor clearColor]];
    [[PDTSimpleCalendarViewCell appearance] setCircleSelectedColor:[UIColor whiteColor]];
    [[PDTSimpleCalendarViewCell appearance] setCircleTodayColor:[UIColor whiteColor]];
    [[PDTSimpleCalendarViewCell appearance] setTextDefaultColor:[UIColor whiteColor]];
    [[PDTSimpleCalendarViewCell appearance] setTextSelectedColor:[UIColor whiteColor]];
    [[PDTSimpleCalendarViewCell appearance] setTextTodayColor:[UIColor whiteColor]];
    [[PDTSimpleCalendarViewCell appearance] setTextDisabledColor:[UIColor grayColor]];
    [[PDTSimpleCalendarViewCell appearance] setTextDefaultFont:[UIFont fontWithName:@"Avenir-Light" size:16.0]];
    
    [[PDTSimpleCalendarViewHeader appearance] setTextColor:[UIColor whiteColor]];
    [[PDTSimpleCalendarViewHeader appearance] setSeparatorColor:[UIColor clearColor]];
}

- (void)viewDidLoad {
    [self setup];
    
    [super viewDidLoad];

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundImageView.image = [UIImage imageNamed:@"date_bg_8"];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    UIImageView *monthImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, self.view.bounds.size.height - 96, 48, 40.5)];
    monthImageView.tintColor = [UIColor whiteColor];
    NSString *imageSrc = [NSString stringWithFormat:@"CourtesyCalendar.bundle/date_m_%02d", (int)[[self lastDate] month]];
    UIImage *image = [UIImage imageNamed:imageSrc];
    monthImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.view addSubview:monthImageView];
    
    UIImageView *closeCalendarView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 64, self.view.bounds.size.height - 84, 20, 24)];
    closeCalendarView.tintColor = [UIColor whiteColor];
    closeCalendarView.image = [UIImage imageNamed:@"CourtesyCalendar.bundle/daily_close_x"];
    closeCalendarView.userInteractionEnabled = YES;
    [closeCalendarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)]];
    [self.view addSubview:closeCalendarView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToSelectedDate:NO];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    CYLog(@"");
}

@end
