//
//  CourtesyGalleryTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/22/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyGalleryTableViewController.h"
#import "CourtesyGalleryEmptyTipTableViewCell.h"
#import "CourtesyCardComposeViewController.h"

static NSString * const kCourtesyGalleryEmptyTipCellReuseIdentifier = @"CourtesyGalleryEmptyTipCellReuseIdentifier";

@interface CourtesyGalleryTableViewController ()

@end

@implementation CourtesyGalleryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 探索导航栏按钮

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionToggleRightDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleRightDrawer:self animated:YES];
}

#pragma mark - 探索主界面表格数据源

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // if no network
    if (indexPath.section == 0) {
        return tableView.frame.size.height - 64.0;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // if no network
    if (section == 0) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // if no network
    if (indexPath.section == 0 && indexPath.row == 0) {
        CourtesyGalleryEmptyTipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyGalleryEmptyTipCellReuseIdentifier forIndexPath:indexPath];
        cell.iconImage = [UIImage imageNamed:@"16-no-network"];
        cell.titleText = @"网络连接失败\n请打开无线局域网或蜂窝数据连接";
        return cell;
    }
    return nil;
}

@end
