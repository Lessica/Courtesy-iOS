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
#import "CourtesyLoginRegisterViewController.h"
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
    kCourtesyGalleryIndex     = 0,
    kCourtesyMainIndex        = 1,
    kCourtesyStarIndex        = 2,
    kCourtesySettingsIndex    = 3,
    kJVDrawerSettingsIndex    = 4,
    kJVGitHubProjectPageIndex = 5
};

static const CGFloat kJVTableViewTopInset = 80.0;
static NSString * const kCourtesyDrawerAvatarViewCellReuseIdentifier = @"CourtesyDrawerAvatarViewCellReuseIdentifier";
static NSString * const kJVDrawerCellReuseIdentifier = @"JVDrawerCellReuseIdentifier";

@interface CourtesyLeftDrawerTableViewController ()

@property (nonatomic, strong) CourtesyLeftDrawerAvatarTableViewCell *avatarCell;

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
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:kCourtesyGalleryIndex inSection:kMenuSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - 侧边栏表格数据源

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
    return 6;
}

- (void)reloadAvatar {
    if (!_avatarCell) {
        return;
    }
    _avatarCell.nickLabelText = @"未登录";
    _avatarCell.avatarImage = [UIImage imageNamed:@"3-avatar"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kMenuSection) {
        CourtesyLeftDrawerMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJVDrawerCellReuseIdentifier forIndexPath:indexPath];
        
        if (indexPath.row == kCourtesyMainIndex) {
            cell.titleText = @"我的";
            cell.iconImage = [UIImage imageNamed:@"1-gift"];
        } else if (indexPath.row == kCourtesyGalleryIndex) {
            cell.titleText = @"探索";
            cell.iconImage = [UIImage imageNamed:@"5-gallery"];
        } else if (indexPath.row == kCourtesySettingsIndex) {
            cell.titleText = @"设置";
            cell.iconImage = [UIImage imageNamed:@"665-gear"];
        } else if (indexPath.row == kJVDrawerSettingsIndex) {
            cell.titleText = @"动画";
            cell.iconImage = [UIImage imageNamed:@"2-magic"];
        } else if (indexPath.row == kJVGitHubProjectPageIndex) {
            cell.titleText = @"Github Page";
            cell.iconImage = [UIImage imageNamed:@"488-github"];
        } else if (indexPath.row == kCourtesyStarIndex) {
            cell.titleText = @"收藏";
            cell.iconImage = [UIImage imageNamed:@"19-star"];
        }
        
        return cell;
    }
    CourtesyLeftDrawerAvatarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyDrawerAvatarViewCellReuseIdentifier forIndexPath:indexPath];
    self.avatarCell = cell;
    [self reloadAvatar];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kMenuSection) {
        UIViewController *destinationViewController = nil;
        
        if (indexPath.row == kCourtesyMainIndex) {
            destinationViewController = [[AppDelegate globalDelegate] myViewController];
        } else if (indexPath.row == kCourtesyGalleryIndex) {
            destinationViewController = [[AppDelegate globalDelegate] galleryViewController];
        } else if (indexPath.row == kCourtesySettingsIndex) {
            destinationViewController = [[AppDelegate globalDelegate] settingsViewController];
        } else if (indexPath.row == kJVDrawerSettingsIndex) {
            destinationViewController = [[AppDelegate globalDelegate] drawerSettingsViewController];
        } else if (indexPath.row == kJVGitHubProjectPageIndex) {
            destinationViewController = [[AppDelegate globalDelegate] githubViewController];
        } else if (indexPath.row == kCourtesyStarIndex) {
            destinationViewController = [[AppDelegate globalDelegate] starViewController];
        }
        
        if (!destinationViewController) {
            return;
        }
        [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:destinationViewController];
        [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    } else if (indexPath.section == kAvatarSection) {
        CourtesyLoginRegisterViewController *vc = [CourtesyLoginRegisterViewController new];
        [self presentViewController:vc animated:YES completion:nil];
    }
    //TODO: Avatar Reuse
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
