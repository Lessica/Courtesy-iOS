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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarItem;

@end

@implementation CourtesyAlbumTabbarViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.title = @"发件箱";
    self.delegate = self;
}

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionEditButtonTapped:(UIBarButtonItem *)sender {
    UITableViewController *tableViewController = self.selectedViewController;
    if (tableViewController.tableView.isEditing) {
        sender.title = @"编辑";
        [tableViewController.tableView setEditing:NO animated:YES];
    } else {
        sender.title = @"完成";
        [tableViewController.tableView setEditing:YES animated:YES];
    }
}

#pragma mark - JVFloatingDrawerCenterViewController

- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide {
    if (drawerSide == JVFloatingDrawerSideLeft) return YES;
    return NO;
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UITableViewController *tableViewController = self.selectedViewController;
    if (tableViewController.tableView.isEditing) {
        [tableViewController.tableView setEditing:NO];
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    UITableViewController *tableViewController = self.selectedViewController;
    if (tableViewController.tableView.isEditing) {
        self.editBarItem.title = @"完成";
    } else {
        self.editBarItem.title = @"编辑";
    }
    self.title = viewController.title;
}

@end
