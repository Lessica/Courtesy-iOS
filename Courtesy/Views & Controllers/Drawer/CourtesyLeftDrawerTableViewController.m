//
//  CourtesyLeftDrawerTableViewController.m
//  Courtesy
//
//  Created by i_82 on 2016-02-20.
//  Copyright (c) 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyCardManager.h"
#import "CourtesyCardStyleManager.h"
#import "CourtesyLeftDrawerTableViewController.h"
#import "CourtesyLeftDrawerMenuTableViewCell.h"
#import "CourtesyLeftDrawerAvatarTableViewCell.h"
#import "CourtesyPortraitViewController.h"
#import "CourtesyLoginRegisterViewController.h"
#import "JVFloatingDrawerViewController.h"

enum {
    kAvatarSection = 0,
    kMenuSection = 1
};

enum {
    kProfileSettingsIndex     = 0
};

enum {
    kCourtesyScanIndex        = 0,
    kCourtesyGalleryIndex     = 1,
    kCourtesyAlbumIndex       = 2,
    kCourtesySettingsIndex    = 3
};

static const CGFloat kJVTableViewTopInset = 80.0;
static NSString * const kCourtesyDrawerAvatarViewCellReuseIdentifier = @"CourtesyDrawerAvatarViewCellReuseIdentifier";
static NSString * const kJVDrawerCellReuseIdentifier = @"JVDrawerCellReuseIdentifier";

@interface CourtesyLeftDrawerTableViewController ()

@property (nonatomic, strong) CourtesyLeftDrawerAvatarTableViewCell *avatarCell;

@end

@implementation CourtesyLeftDrawerTableViewController {
    CourtesyPortraitViewController *qrscanView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(kJVTableViewTopInset, 0.0, 0.0, 0.0);
    self.clearsSelectionOnViewWillAppear = NO;
    // 注册接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLocalNotification:)
                                                 name:kCourtesyNotificationInfo object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *globalDelegate = [AppDelegate globalDelegate];
    UIViewController *centerViewController = globalDelegate.drawerViewController.centerViewController;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:kCourtesyGalleryIndex inSection:kMenuSection];
    if (centerViewController == globalDelegate.profileViewController) {
        indexPath = [NSIndexPath indexPathForItem:kProfileSettingsIndex inSection:kAvatarSection];
    } else if (centerViewController == globalDelegate.albumViewController) {
        indexPath = [NSIndexPath indexPathForItem:kCourtesyAlbumIndex inSection:kMenuSection];
    } else if (centerViewController == globalDelegate.settingsViewController) {
        indexPath = [NSIndexPath indexPathForItem:kCourtesySettingsIndex inSection:kMenuSection];
    }
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self showActivityMessage:@"登录中"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 响应通知事件

- (void)didReceiveLocalNotification:(NSNotification *)notification {
    if (!notification.userInfo || ![notification.userInfo hasKey:@"action"]) {
        return;
    }
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqualToString:kActionLogin] ||
        [action isEqualToString:kActionProfileEdited]) {
        [self reloadAvatar:YES];
    } else if ([action isEqualToString:kActionLogout]) {
        [self reloadAvatar:NO];
    } else if ([action isEqualToString:kActionFetchSucceed]) {
        [self reloadAvatar:YES];
        [JDStatusBarNotification showWithStatus:@"登录成功"
                                   dismissAfter:kStatusBarNotificationTime
                                      styleName:JDStatusBarStyleSuccess];
    } else if ([action isEqualToString:kActionFetchFailed]) {
        NSString *message = [notification.userInfo hasKey:@"message"] ? [notification.userInfo objectForKey:@"message"] : @"";
        [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"登录失败 - %@", message]
                                   dismissAfter:kStatusBarNotificationTime
                                      styleName:JDStatusBarStyleError];
    } else if ([action isEqualToString:kActionFetching]) {
        [self showActivityMessage:@"登录中"];
    }
}

#pragma mark - 动态更新数据源

- (void)reloadAvatar:(BOOL)login {
    if (!_avatarCell) {
        return;
    }
    if (login) {
        [_avatarCell setNickLabelText:kAccount.profile.nick];
        if (!kAccount.profile.avatar) {
            [_avatarCell setAvatarImage:[UIImage imageNamed:@"3-avatar"]];
        } else {
            [_avatarCell loadRemoteImage];
        }
    } else {
        [_avatarCell setNickLabelText:@"未登录"];
        [_avatarCell setAvatarImage:[UIImage imageNamed:@"3-avatar"]];
    }
}

- (void)showActivityMessage:(NSString *)message {
    if (kLogin && [kAccount isRequestingFetchAccountInfo]) {
        [JDStatusBarNotification showWithStatus:message
                                      styleName:JDStatusBarStyleDefault];
        [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleGray];
    }
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kMenuSection) {
        CourtesyLeftDrawerMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJVDrawerCellReuseIdentifier forIndexPath:indexPath];
        if (indexPath.row == kCourtesyGalleryIndex) {
            cell.titleText = @"探索";
            cell.iconImage = [UIImage imageNamed:@"5-gallery"];
        } else if (indexPath.row == kCourtesySettingsIndex) {
            cell.titleText = @"设置";
            cell.iconImage = [UIImage imageNamed:@"665-gear"];
        } else if (indexPath.row == kCourtesyAlbumIndex) {
            cell.titleText = @"我的卡片";
            cell.iconImage = [UIImage imageNamed:@"19-star"];
        } else if (indexPath.row == kCourtesyScanIndex) {
            cell.titleText = @"扫一扫";
            cell.iconImage = [UIImage imageNamed:@"38-scan"];
        }
        
        return cell;
    }
    CourtesyLeftDrawerAvatarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyDrawerAvatarViewCellReuseIdentifier forIndexPath:indexPath];
    self.avatarCell = cell;
    [self reloadAvatar:kLogin];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kMenuSection) {
        UIViewController *destinationViewController = nil;
        /*
        if (indexPath.row == kCourtesyMainIndex) {
            destinationViewController = [[AppDelegate globalDelegate] myViewController];
        } else */
        if (indexPath.row == kCourtesyGalleryIndex) {
            destinationViewController = [[AppDelegate globalDelegate] galleryViewController];
        } else if (indexPath.row == kCourtesySettingsIndex) {
            destinationViewController = [[AppDelegate globalDelegate] settingsViewController];
        } else if (indexPath.row == kCourtesyAlbumIndex) {
            destinationViewController = [[AppDelegate globalDelegate] albumViewController];
        } else if (indexPath.row == kCourtesyScanIndex) {
            destinationViewController = [self scanPortraitView];
        }
        
        if (!destinationViewController) {
            return;
        }
        [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:destinationViewController];
        [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    } else if (indexPath.section == kAvatarSection) {
        if (!kLogin) {
            CourtesyLoginRegisterViewController *vc = [CourtesyLoginRegisterViewController new];
            CourtesyPortraitViewController *navc = [[CourtesyPortraitViewController alloc] initWithRootViewController:vc];
            [self presentViewController:navc animated:YES completion:nil];
            return;
        }
        UIViewController *destinationViewController = nil;
        
        if (indexPath.row == kProfileSettingsIndex) {
            destinationViewController = [[AppDelegate globalDelegate] profileViewController];
        }
        
        if (!destinationViewController) {
            return;
        }
        [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:destinationViewController];
        [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
    }
}

#pragma mark - CourtesyQRCodeScanDelegate

- (void)scanWithResult:(CourtesyQRCodeModel *)qrcode {
    if (!qrcode) {
        return;
    }
    // 发布、修改或查看
    if (qrcode.is_recorded == NO) {
        if (![sharedSettings hasLogin]) { // 未登录
            [self.view makeToast:@"登录后才能发布新卡片"
                        duration:2.0
                        position:CSToastPositionCenter];
            return;
        }
        // 发布新卡片界面
        CourtesyCardModel *newCard = [[CourtesyCardManager sharedManager] composeNewCardWithViewController:self];
        newCard.qr_id = qrcode.unique_id;
    }
}

#pragma mark - Views

- (CourtesyPortraitViewController *)scanPortraitView {
    if (!qrscanView) {
        CourtesyQRScanViewController *vc = [CourtesyQRScanViewController new];
        vc.delegate = self;
        qrscanView = [[CourtesyPortraitViewController alloc] initWithRootViewController:vc];
    }
    return qrscanView;
}

#pragma mark - ShortCuts

- (BOOL)shortcutScan {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:NO];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[self scanPortraitView]];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:kCourtesyScanIndex inSection:kMenuSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:NO];
    return YES;
}

- (BOOL)shortcutCompose {
    if (![sharedSettings fetchedCurrentAccount]) {
        return NO;
    } else if (![sharedSettings hasLogin]) {
        [self.view makeToast:@"登录后才能发布新卡片"
                    duration:2.0
                    position:CSToastPositionCenter];
        return NO;
    }
    [[CourtesyCardManager sharedManager] composeNewCardWithViewController:self];
    return YES;
}

- (BOOL)shortcutShare {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:NO];
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:[[AppDelegate globalDelegate] albumViewController]];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:kCourtesyAlbumIndex inSection:kMenuSection] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:NO];
    return YES;
}

@end
