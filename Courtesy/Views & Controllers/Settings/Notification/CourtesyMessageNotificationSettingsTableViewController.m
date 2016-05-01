//
//  CourtesyMessageNotificationSettingsTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/22/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyMessageNotificationSettingsTableViewController.h"

@interface CourtesyMessageNotificationSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *allowNewNotificationsLabel;

@end

@implementation CourtesyMessageNotificationSettingsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeStatusLabel];
}

- (void)changeStatusLabel {
    if ([sharedSettings hasNotificationPermission]) {
        _allowNewNotificationsLabel.text = @"已开启";
    } else {
        _allowNewNotificationsLabel.text = @"已关闭";
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"提示"
                                                            message:@"如果你要关闭或开启礼记的新消息通知，请在「设置 - 通知」中，找到应用程序「礼记」更改。"
                                                              style:LGAlertViewStyleAlert
                                                       buttonTitles:nil
                                                  cancelButtonTitle:@"好"
                                             destructiveButtonTitle:nil];
        SetCourtesyAleryViewStyle(alertView, self.view)
        [alertView showAnimated:YES completionHandler:^() {
            [self changeStatusLabel];
        }];
    }
}

@end
