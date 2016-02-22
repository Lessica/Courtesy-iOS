//
//  CourtesyMainTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyMainTableViewController.h"
#import "CourtesyMainProfileTableViewCell.h"
#import "AppDelegate.h"

enum {
    kNotLoginSection = 0
};

enum {
    kLoginTipIndex   = 0
};

enum {
    kProfileSection  = 0,
    kMainSection     = 1
};

static const CGFloat kMainTableViewTopInset = 60.0;
static NSString * const kCourtesyMainCellReuseIdentifier = @"courtesyMainProfileCellReuseIdentifier";

@interface CourtesyMainTableViewController ()

@end

@implementation CourtesyMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 首页导航栏按钮

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionScanQRCode:(id)sender {
    [[AppDelegate globalDelegate] toggleScanView:self animated:YES];
}

#pragma mark - 首页主界面表格数据源

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 尚未登录
    if (indexPath.section == kNotLoginSection) {
        // 个人信息高度
        return tableView.frame.size.height - kMainTableViewTopInset;
    } else {
        // 卡片单元高度
        return 0;
    }
    // 已登录
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 尚未登录
    if (section == kNotLoginSection) {
        return 1;
    }
    return 0;
    // 已登录
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 尚未登录
    CourtesyMainProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyMainCellReuseIdentifier forIndexPath:indexPath];
    if (indexPath.row == kLoginTipIndex) {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

@end
