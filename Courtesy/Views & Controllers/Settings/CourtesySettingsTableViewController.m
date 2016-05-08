//
//  CourtesySettingsTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "FCFileManager.h"
#import "CourtesySettingsTableViewController.h"
#import <MessageUI/MessageUI.h>

#define kCourtesyImageCachePath ([[[UIApplication sharedApplication] cachesPath] stringByAppendingPathComponent:@"com.ibireme.yykit"])
#define kCourtesyFontsPath ([[[UIApplication sharedApplication] libraryPath] stringByAppendingPathComponent:@"Fonts"])
#define kCourtesySavedAttachmentsPath ([[[UIApplication sharedApplication] libraryPath] stringByAppendingPathComponent:@"SavedAttachments"])

// 表格分区及索引设置
enum {
    kAccountRelatedSection    = 0,
    kCustomizeSection         = 1,
    kServiceSection           = 2,
    kLogoutSection            = 3
};

enum {
    kAccountSettingsIndex     = 0,
    kDraftboxIndex            = 1,
};

enum {
    kMessageNotificationIndex = 0,
};

enum {
    kUserFeedbackIndex        = 0,
    kAboutCourtesyIndex       = 1,
    kUserAgreementIndex       = 2,
    kUserCleanCacheIndex      = 3
};

enum {
    kUserLogoutIndex          = 0
};

@interface CourtesySettingsTableViewController () <MFMailComposeViewControllerDelegate, JVFloatingDrawerCenterViewController>
@property (weak, nonatomic) IBOutlet UISwitch *autoPublicSwitch;
@property (weak, nonatomic) IBOutlet UILabel *cleanCacheTitleLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;

@end

@implementation CourtesySettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _aboutLabel.text = [NSString stringWithFormat:@"关于礼记 (V%@)", VERSION_STRING];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLocalNotification:)
                                                 name:kCourtesyNotificationInfo object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadCacheSizeLabelText:NO];
    [_logoutCell setHidden:!kLogin];
    _autoPublicSwitch.on = [sharedSettings switchAutoPublic];
}

#pragma mark - 响应通知事件

- (void)didReceiveLocalNotification:(NSNotification *)notification {
    if (!notification.userInfo || ![notification.userInfo hasKey:@"action"]) {
        return;
    }
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqualToString:kCourtesyActionLogin]) {
        [_logoutCell setHidden:NO];
    } else if ([action isEqualToString:kCourtesyActionLogout]) {
        [_logoutCell setHidden:YES];
    }
}

#pragma mark - 导航栏按钮

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

#pragma mark - 全局设置表格数据源

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kServiceSection && indexPath.row == kUserCleanCacheIndex) {
        [self.navigationController.view makeToast:[NSString stringWithFormat:@"设备可用空间：%@\n设备总空间：%@",
                                                   [FCFileManager sizeFormatted:[NSNumber numberWithLongLong:[[UIDevice currentDevice] diskSpaceFree]]],
                                                   [FCFileManager sizeFormatted:[NSNumber numberWithLongLong:[[UIDevice currentDevice] diskSpace]]]
                                                   ]
                                         duration:1.2
                                         position:CSToastPositionCenter];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case kAccountRelatedSection:
            if (indexPath.row == kAccountSettingsIndex) {
                
            } else if (indexPath.row == kDraftboxIndex) {
                
            }
            break;
        case kCustomizeSection:
            if (indexPath.row == kMessageNotificationIndex) {
                
            }
            break;
        case kServiceSection:
            if (indexPath.row == kUserFeedbackIndex) {
                [self displayComposerSheet];
            } else if (indexPath.row == kAboutCourtesyIndex) {
                
            } else if (indexPath.row == kUserAgreementIndex) {
                
            } else if (indexPath.row == kUserCleanCacheIndex) {
                [self cleanCacheClicked];
            }
            break;
        case kLogoutSection:
            if (indexPath.row == kUserLogoutIndex) {
                [self logoutClicked];
            }
            break;
        default:
            break;
    }
}

#pragma mark - 相关功能性方法

// 清理缓存
- (void)cleanCacheClicked {
    NSError *error1 = nil;
    NSError *error2 = nil;
#ifdef DEBUG
    [FCFileManager removeItemsInDirectoryAtPath:kCourtesyFontsPath error:nil];
    [FCFileManager removeItemsInDirectoryAtPath:kCourtesySavedAttachmentsPath error:nil];
#endif
    [FCFileManager removeItemsInDirectoryAtPath:kCourtesyImageCachePath error:&error1];
    [FCFileManager removeItemsInDirectoryAtPath:NSTemporaryDirectory() error:&error2];
    if (error1 || error2) {
        [self.navigationController.view makeToast:@"缓存清除失败"
                                         duration:1.2
                                         position:CSToastPositionCenter];
        return;
    }
    [self.navigationController.view makeToast:@"缓存清除成功"
                                     duration:1.2
                                     position:CSToastPositionCenter];
    [self reloadCacheSizeLabelText:YES];
}

- (void)reloadCacheSizeLabelText:(BOOL)clear {
    if (clear) {
        _cleanCacheTitleLabel.text = @"清除缓存";
        return;
    }
    float size = [[FCFileManager sizeOfDirectoryAtPath:kCourtesyImageCachePath] floatValue] + [[FCFileManager sizeOfDirectoryAtPath:NSTemporaryDirectory()] floatValue];
    if (size > 10e5) {
        _cleanCacheTitleLabel.text = [NSString stringWithFormat:@"清除缓存 %@", [FCFileManager sizeFormatted:[NSNumber numberWithFloat:size]]];
    }
}

// 发送邮件
- (void)displayComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (!picker) return;
    picker.mailComposeDelegate = self;
    [picker setSubject:@"关于「礼记」我有些话想说……"];
    NSArray *toRecipients = [NSArray arrayWithObject:SERVICE_EMAIL];
    [picker setToRecipients:toRecipients];
    [self presentViewController:picker animated:YES completion:nil];
}

// 退出登录
- (void)logoutClicked {
    [sharedSettings setHasLogin:NO];
    [self.navigationController.view makeToast:@"退出登录成功"
                                     duration:1.2
                                     position:CSToastPositionCenter];
}

#pragma mark - 开关设置项

- (IBAction)switchTriggered:(id)sender {
    if (sender == _autoPublicSwitch) {
        [sharedSettings setSwitchAutoPublic:_autoPublicSwitch.on];
    }
}

#pragma mark - 邮件代理

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - JVFloatingDrawerCenterViewController

- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide {
    if (drawerSide == JVFloatingDrawerSideLeft) return YES;
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
