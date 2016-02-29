//
//  CourtesyMyTabBarController.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyMyTabBarController.h"

@interface CourtesyMyTabBarController ()

@end

@implementation CourtesyMyTabBarController

#pragma mark - CourtesyQRCodeScanDelegate

- (void)scanWithResult:(CourtesyQRCodeModel *)qrcode {
    if (!qrcode) {
        return;
    }
    // 发布、修改或查看
    if (qrcode.is_recorded == NO) {
        // 发布新卡片界面
    }
}

#pragma mark - 收藏夹收件箱导航栏按钮

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionScanQRCode:(id)sender {
    CourtesyQRScanViewController *vc = [CourtesyQRScanViewController new];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
