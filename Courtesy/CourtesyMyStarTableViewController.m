//
//  CourtesyMainTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyMyStarTableViewController.h"
#import "CourtesyMyStarEmptyTipTableViewCell.h"
#import "AppDelegate.h"

enum {
    kProfileSection  = 0,
    kMainSection     = 1
};

static NSString * const kCourtesyMyEmptyTipCellReuseIdentifier = @"CourtesyMyStarEmptyTipCellReuseIdentifier";

@interface CourtesyMyStarTableViewController ()

@end

@implementation CourtesyMyStarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 收藏夹导航栏按钮

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

#pragma mark - 收藏夹主界面表格数据源

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // if tip
    if (indexPath.section == 0) {
        return tableView.frame.size.height - 64.0;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // if tip
    if (section == 0) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // if not login
    if (indexPath.section == 0 && indexPath.row == 0) {
        CourtesyMyStarEmptyTipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyMyEmptyTipCellReuseIdentifier forIndexPath:indexPath];
        cell.iconImage = [UIImage imageNamed:@"15-no-login"];
        cell.titleText = @"你尚未登录\n登录后才能使用收藏夹喔";
        return cell;
    }
    // if no network
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        CourtesyMyStarEmptyTipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyMyStarEmptyTipCellReuseIdentifier forIndexPath:indexPath];
//        cell.iconImage = [UIImage imageNamed:@"16-no-network"];
//        cell.titleText = @"网络连接失败\n请打开无线局域网或蜂窝数据连接";
//        return cell;
//    }
    return nil;
}

@end
