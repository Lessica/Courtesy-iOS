//
//  CourtesyMyTabBarController.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyCardStyleManager.h"
#import "CourtesyMyTabBarController.h"
#import "CourtesyPortraitViewController.h"
#import "CourtesyLoginRegisterViewController.h"
#import "CourtesyCardComposeViewController.h"

@interface CourtesyMyTabBarController ()

@end

@implementation CourtesyMyTabBarController

#pragma mark - 收藏夹收件箱导航栏按钮

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionComposeNewCard:(id)sender {
    if (![sharedSettings hasLogin]) { // 未登录
        CourtesyLoginRegisterViewController *vc = [CourtesyLoginRegisterViewController new];
        CourtesyPortraitViewController *navc = [[CourtesyPortraitViewController alloc] initWithRootViewController:vc];
        [self presentViewController:navc animated:YES completion:nil];
        return;
    }
    CourtesyCardComposeViewController *vc = [[CourtesyCardComposeViewController alloc] initWithCardStyle:[[CourtesyCardStyleManager sharedManager] styleWithID:kCourtesyCardStyleDefault]];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
