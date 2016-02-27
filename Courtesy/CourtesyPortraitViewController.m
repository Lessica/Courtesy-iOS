//
//  CourtesyPortraitViewController.m
//  Courtesy
//
//  Created by Zheng on 2/27/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyPortraitViewController.h"

@interface CourtesyPortraitViewController ()

@end

@implementation CourtesyPortraitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:YES animated:NO];
}

- (BOOL)shouldAutorotate
{
    if ([[UIDevice currentDevice] isPad]) {
        return YES;
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] isPad]) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([[UIDevice currentDevice] isPad]) {
        return [super preferredInterfaceOrientationForPresentation];
    }
    return UIInterfaceOrientationPortrait;
}

@end
