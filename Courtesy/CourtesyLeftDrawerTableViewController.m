//
//  CourtesyLeftDrawerTableViewController.m
//  Courtesy
//
//  Created by i_82 on 2016-02-20.
//  Copyright (c) 2016 82Flex. All rights reserved.
//

#import "CourtesyLeftDrawerTableViewController.h"
#import "CourtesyLeftDrawerMenuTableViewCell.h"
#import "CourtesyLeftDrawerAvatarTableViewCell.h"
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"

enum {
    kAvatarSection = 0,
    kMenuSection = 1
};

enum {
    kProfileSettingsIndex     = 0
};

enum {
    kCourtesyMainIndex        = 0,
    kJVDrawerSettingsIndex    = 1,
    kJVGitHubProjectPageIndex = 2
};

static const CGFloat kJVTableViewTopInset = 80.0;
static NSString * const kCourtesyDrawerAvatarViewCellReuseIdentifier = @"CourtesyDrawerAvatarViewCellReuseIdentifier";
static NSString * const kJVDrawerCellReuseIdentifier = @"JVDrawerCellReuseIdentifier";

@interface CourtesyLeftDrawerTableViewController ()

@end

@implementation CourtesyLeftDrawerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(kJVTableViewTopInset, 0.0, 0.0, 0.0);
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:kCourtesyMainIndex inSection:kMenuSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table View Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kAvatarSection) {
        return 124;
    }
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kAvatarSection) {
        return 1;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kMenuSection) {
        CourtesyLeftDrawerMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJVDrawerCellReuseIdentifier forIndexPath:indexPath];
        
        if (indexPath.row == kCourtesyMainIndex) {
            cell.titleText = @"首页";
            cell.iconImage = [UIImage imageNamed:@"1-gift"];
        } else if (indexPath.row == kJVDrawerSettingsIndex) {
            cell.titleText = @"动画设置";
            cell.iconImage = [UIImage imageNamed:@"2-magic"];
        } else {
            cell.titleText = @"Github Page";
            cell.iconImage = [UIImage imageNamed:@"488-github"];
        }
        
        return cell;
    }
    CourtesyLeftDrawerAvatarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyDrawerAvatarViewCellReuseIdentifier forIndexPath:indexPath];
    
    cell.nickLabelText = @"未登录";
    cell.avatarImage = [UIImage imageNamed:@"3-avatar"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kMenuSection) {
        UIViewController *destinationViewController = nil;
        
        if (indexPath.row == kCourtesyMainIndex) {
            destinationViewController = [[AppDelegate globalDelegate] mainViewController];
        } else if (indexPath.row == kJVDrawerSettingsIndex) {
            destinationViewController = [[AppDelegate globalDelegate] drawerSettingsViewController];
        } else {
            destinationViewController = [[AppDelegate globalDelegate] githubViewController];
        }
        
        [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:destinationViewController];
        [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    }
    //TODO: Avatar Reuse
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
