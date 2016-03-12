//
//  CourtesyMyInboxTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyMyInboxTableViewController.h"
#import "CourtesyMyInboxEmptyTipTableViewCell.h"

static NSString * const kCourtesyMyInboxEmptyTipCellReuseIdentifier = @"CourtesyMyInboxEmptyTipCellReuseIdentifier";

@interface CourtesyMyInboxTableViewController ()

@end

@implementation CourtesyMyInboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
        CourtesyMyInboxEmptyTipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyMyInboxEmptyTipCellReuseIdentifier forIndexPath:indexPath];
        cell.iconImage = [UIImage imageNamed:@"15-no-login"];
        cell.titleText = @"你尚未登录\n登录后才能查看收件箱喔";
        return cell;
    }
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        CourtesyMyInboxEmptyTipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyMyInboxEmptyTipCellReuseIdentifier forIndexPath:indexPath];
//        cell.iconImage = [UIImage imageNamed:@"4-big-gift"];
//        cell.titleText = @"轻按右上角的➕\n接收你的专属「礼记」卡片";
//        return cell;
//    }
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        CourtesyMyInboxEmptyTipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyMyInboxEmptyTipCellReuseIdentifier forIndexPath:indexPath];
//        cell.iconImage = [UIImage imageNamed:@"16-no-network"];
//        cell.titleText = @"网络连接失败\n请打开无线局域网或蜂窝数据连接";
//        return cell;
//    }
    return nil;
}

@end
