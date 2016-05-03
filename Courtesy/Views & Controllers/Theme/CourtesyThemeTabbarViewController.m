//
//  CourtesyThemeTabbarViewController.m
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyThemeTabbarViewController.h"

@interface CourtesyThemeTabbarViewController () <JVFloatingDrawerCenterViewController, UITabBarControllerDelegate>

@end

@implementation CourtesyThemeTabbarViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.title = @"主题";
    self.delegate = self;
}

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

#pragma mark - JVFloatingDrawerCenterViewController

- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide {
    if (drawerSide == JVFloatingDrawerSideLeft) return YES;
    return NO;
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    self.title = viewController.title;
}

@end
