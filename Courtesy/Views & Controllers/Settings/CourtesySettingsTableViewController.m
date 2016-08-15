//
//  CourtesySettingsTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocial.h"
#import "FCFileManager.h"
#import <MessageUI/MessageUI.h>
#import "CourtesySettingsTableViewController.h"

#define kCourtesyImageCachePath ([[[UIApplication sharedApplication] cachesPath] stringByAppendingPathComponent:@"com.ibireme.yykit"])
#define kCourtesyFontsPath ([[[UIApplication sharedApplication] libraryPath] stringByAppendingPathComponent:@"Fonts"])
#define kCourtesySavedAttachmentsPath ([[[UIApplication sharedApplication] libraryPath] stringByAppendingPathComponent:@"SavedAttachments"])

enum {
    kCustomizeSection         = 0,
    kConfigSection            = 1,
    kServiceSection           = 2,
    kLogoutSection            = 3
};

enum {
    kMessageNotificationIndex = 0,
    kAutoPublicSwitchIndex    = 1,
    kUserCleanCacheIndex      = 2
};

enum {
    kFeedbackIndex            = 0,
    kUserAgreementIndex       = 1,
    kOpenSourceCreditIndex    = 2,
};

enum {
    kUserLogoutIndex          = 0
};

@interface CourtesySettingsTableViewController () <JVFloatingDrawerCenterViewController, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *autoPublicSwitch;
@property (weak, nonatomic) IBOutlet UILabel *cleanCacheTitleLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *appLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end

@implementation CourtesySettingsTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLocalNotification:)
                                                 name:kCourtesyNotificationInfo object:nil];
    
    // 跳转到官方网站的手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailLabelClicked:)];
    tapGesture.delegate = self;
    [_detailLabel addGestureRecognizer:tapGesture];
    
    // 应用展示标签
    _appLabel.text = [NSString stringWithFormat:@"%@\nV%@ (%@)", APP_NAME_CN, VERSION_STRING, VERSION_BUILD];
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
    if (indexPath.section == kConfigSection && indexPath.row == kUserCleanCacheIndex) {
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
        case kCustomizeSection:
            break;
        case kConfigSection:
            if (indexPath.row == kUserCleanCacheIndex) {
                [self cleanCacheClicked];
            }
            break;
        case kServiceSection:
            if (indexPath.row == kFeedbackIndex) {
                [self displayComposerSheet];
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

- (IBAction)shareButtonClicked:(id)sender {
    if (sender == _shareButton) {
        UIImage *shareImage = [UIImage imageNamed:@"courtesy-share-qrcode"];
        NSString *shareUrl = APP_DOWNLOAD_URL;
        UmengSetShareType(shareUrl, shareImage)
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:UMENG_APP_KEY
                                          shareText:[NSString stringWithFormat:WEIBO_SHARE_CONTENT, kAccount.profile.nick ? kAccount.profile.nick : @"", APP_DOWNLOAD_URL]
                                         shareImage:shareImage
                                    shareToSnsNames:UMENG_SHARE_PLATFORMS
                                           delegate:nil];
    }
}

- (void)detailLabelClicked:(UITapGestureRecognizer *)sender {
#if DEBUG
    // This could also live in a handler for a keyboard shortcut, debug menu item, etc.
    [self.navigationController.view makeToast:@"启动调试模式"
                                     duration:kStatusBarNotificationTime position:CSToastPositionCenter];
    [[FLEXManager sharedManager] showExplorer];
#else
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SERVICE_INDEX]];
#endif
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

#pragma mark - 邮件代理

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

#pragma mark - JVFloatingDrawerCenterViewController

- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide {
    if (drawerSide == JVFloatingDrawerSideLeft) return YES;
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
