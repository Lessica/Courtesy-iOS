//
//  CourtesyAlbumTabbarViewController.m
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyAlbumTabbarViewController.h"

@interface CourtesyAlbumTabbarViewController () <JVFloatingDrawerCenterViewController, UITabBarControllerDelegate>

@end

@implementation CourtesyAlbumTabbarViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.title = @"发件箱";
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
