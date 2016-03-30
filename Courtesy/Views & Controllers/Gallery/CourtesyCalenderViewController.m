//
//  CourtesyCalenderViewController.m
//  Courtesy
//
//  Created by Zheng on 3/29/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCalenderViewController.h"

@implementation CourtesyCalenderViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToSelectedDate:NO];
}

@end
