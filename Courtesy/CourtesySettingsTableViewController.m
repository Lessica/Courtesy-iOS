//
//  CourtesySettingsTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesySettingsTableViewController.h"
#import "AppDelegate.h"
#import "UIView+Toast.h"
#import "FileUtils.h"
#import "GlobalDefine.h"

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

@interface CourtesySettingsTableViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *autoSaveSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoPublicSwitch;
@property (weak, nonatomic) IBOutlet UILabel *cleanCacheTitleLabel;


@end

@implementation CourtesySettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _cleanCacheTitleLabel.text = [NSString stringWithFormat:@"清除缓存 (%@ )", [FileUtils formattedCacheSize]];
}

#pragma mark - 导航栏按钮

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

#pragma mark - 全局设置表格数据源

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // return 4;
    // 尚未登录
    return 3;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kServiceSection && indexPath.row == kUserCleanCacheIndex) {
        [self.navigationController.view makeToast:[NSString stringWithFormat:@"设备可用空间：%@", [FileUtils freeDiskSpace]]
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
                
            }
            break;
        default:
            break;
    }
}

#pragma mark - 相关功能性方法

// 清理缓存
- (void)cleanCacheClicked {
    if ([FileUtils cleanCache] != nil) {
        [self.navigationController.view makeToast:@"缓存清除失败"
                                         duration:1.2
                                         position:CSToastPositionCenter];
        return;
    }
    [self.navigationController.view makeToast:@"缓存清除成功"
                                     duration:1.2
                                     position:CSToastPositionCenter];
}

// 发送邮件
- (void)displayComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"关于「礼记」我有些话想说……"];
    NSArray *toRecipients = [NSArray arrayWithObject:SERVICE_EMAIL];
    [picker setToRecipients:toRecipients];
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - 开关设置项

- (IBAction)switchTriggered:(id)sender {
    if (sender == _autoSaveSwitch) {
        
    } else if (sender == _autoPublicSwitch) {
        
    }
}

#pragma mark - 邮件代理

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
