//
//  CourtesyStyleTableViewController.m
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyStyleTableViewController.h"
#import "CourtesyStyleTableViewCell.h"
#import "CourtesyCardStyleManager.h"
#import <MJRefresh/MJRefresh.h>

static NSString * const kCourtesyStyleTableViewCellReuseIdentifier = @"CourtesyStyleTableViewCellReuseIdentifier";

@interface CourtesyStyleTableViewController ()
@property (nonatomic, assign) NSUInteger preferredStyleID;
@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader;

@end

@implementation CourtesyStyleTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSArray <NSString *> *)styleNames {
    return [[CourtesyCardStyleManager sharedManager] styleNames];
}

- (NSArray<UIImage *> *)styleImages {
    return [[CourtesyCardStyleManager sharedManager] styleImages];
}

- (NSArray<UIImage *> *)styleCheckmarks {
    return [[CourtesyCardStyleManager sharedManager] styleCheckmarks];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"主题";
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    // 设置底部 Tabbar 边距
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
//    self.tableView.mj_header = self.refreshHeader;
    self.preferredStyleID = [sharedSettings preferredStyleID];
}


- (MJRefreshNormalHeader *)refreshHeader {
    if (!_refreshHeader) {
        /* Init of MJRefresh */
        MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadTableView)];
        [normalHeader setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
        [normalHeader setTitle:@"释放更新" forState:MJRefreshStatePulling];
        [normalHeader setTitle:@"加载中……" forState:MJRefreshStateRefreshing];
        normalHeader.stateLabel.font = [UIFont systemFontOfSize:12.0];
        normalHeader.stateLabel.textColor = [UIColor lightGrayColor];
        normalHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.0];
        normalHeader.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
        [normalHeader beginRefreshing];
        _refreshHeader = normalHeader;
    }
    return _refreshHeader;
}

- (void)reloadTableView {
    [self performSelector:@selector(endRefresh) withObject:nil afterDelay:1.0];
}

- (void)endRefresh {
    [self.refreshHeader endRefreshing];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section < self.styleNames.count) {
        for (int index = 0; index < self.styleNames.count; index++) {
            CourtesyStyleTableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
            [cell setStyleSelected:NO];
        }
        CourtesyStyleTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setStyleSelected:YES];
        self.preferredStyleID = indexPath.section;
        [sharedSettings setPreferredStyleID:indexPath.section];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.styleImages.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section < self.styleNames.count) {
//        return [self.styleNames objectAtIndex:section];
//    }
//    return nil;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.styleImages.count) {
        CourtesyStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyStyleTableViewCellReuseIdentifier forIndexPath:indexPath];
        UIColor *tintColor = [[CourtesyCardStyleManager sharedManager] styleWithID:indexPath.section].cardTextColor;
        [cell setStyleTintColor:tintColor];
        [cell setStyleImage:[self.styleImages objectAtIndex:indexPath.section]];
        [cell setStyleCheckmark:[self.styleCheckmarks objectAtIndex:indexPath.section]];
        if (indexPath.section == self.preferredStyleID) {
            [cell setStyleSelected:YES];
        } else {
            [cell setStyleSelected:NO];
        }
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.styleImages.count) {
        CGSize size = self.styleImages[indexPath.section].size;
        CGFloat ratio = size.height / size.width;
        return tableView.frame.size.width * ratio;
    }
    return 0;
}

@end
