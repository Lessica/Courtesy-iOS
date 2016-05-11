//
//  CourtesyAccountSettingsTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/27/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAccountSettingsTableViewController.h"
#import "CourtesyPortraitViewController.h"
#import "CourtesyLoginRegisterViewController.h"

@interface CourtesyAccountSettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *qqSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *weiboSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *incognitoSwitch;
@property (weak, nonatomic) IBOutlet UILabel *label_1;
@property (weak, nonatomic) IBOutlet UILabel *label_2;
@property (weak, nonatomic) IBOutlet UILabel *label_3;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@end

@implementation CourtesyAccountSettingsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([sharedSettings hasLogin]) {
        _qqSwitch.enabled = YES;
        _weiboSwitch.enabled = YES;
        _weiboSwitch.on = [kAccount hasWeiboAccount];
        _qqSwitch.on = [kAccount hasTencentAccount];
        NSString *email = kAccount.email;
        NSRange atRange = [email rangeOfString:@"@"];
        if (atRange.length != 0) {
            NSString *domainName = [email substringFromIndex:atRange.location];
            if ([domainName isEqualToString:@"@82flex.com"]) {
                NSString *prefix = [email substringToIndex:2];
                if ([prefix isEqualToString:@"qq"]) {
                    _qqSwitch.enabled = NO;
                    _qqSwitch.on = YES;
                } else if ([prefix isEqualToString:@"wb"]) {
                    _weiboSwitch.enabled = NO;
                    _weiboSwitch.on = YES;
                }
            }
        }
        _incognitoSwitch.enabled = YES;
        _label_1.alpha = _label_3.alpha = 1.0;
        if (_weiboSwitch || _qqSwitch) {
            _label_3.text = @"已经激活";
        }
        _label_2.text = kProfile.nick;
        // _incognito
        [_avatarView setImageWithURL:kProfile.avatar_url_medium
                             options:YYWebImageOptionShowNetworkActivity | YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation];
    } else {
        _avatarView.image = [UIImage imageNamed:@"3-avatar"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![sharedSettings hasLogin]) {
        CourtesyLoginRegisterViewController *vc = [CourtesyLoginRegisterViewController new];
        CourtesyPortraitViewController *navc = [[CourtesyPortraitViewController alloc] initWithRootViewController:vc];
        [self presentViewController:navc animated:YES completion:nil];
        _qqSwitch.enabled = _weiboSwitch.enabled = _incognitoSwitch.enabled = NO;
        _label_1.alpha = _label_3.alpha = 0.0;
        _label_2.text = @"你尚未登录";
    }
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = _avatarView.frame.size.width / 2;
}

- (IBAction)tencentSwitchToggled:(UISwitch *)sender {
    if (sender.on)
    {
        // 1. 调起腾讯 QQ 登录接口
        // 2. 尝试使用腾讯 OpenId 登录
        // 3. 查询 OpenId 账户信息
        // 4. 若无账户，进行绑定
        // 5. 若有账户，提示绑定失败
        
    }
    else
    { // 取消绑定
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"解除绑定"
                                                        message:@"将无法分享卡片到QQ好友、QQ空间"
                                                          style:LGAlertViewStyleActionSheet
                                                   buttonTitles:@[@"解除"]
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                                  actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                      if (index == 0) {
                                                          kAccount.tencentModel = nil;
                                                          [sharedSettings reloadAccount];
                                                      }
                                                  } cancelHandler:^(LGAlertView *alertView) {
                                                      [sender setOn:YES animated:YES];
                                                  } destructiveHandler:nil];
        SetCourtesyAleryViewStyle(alertView, self.view)
        [alertView showAnimated:YES completionHandler:nil];
    }
}

- (IBAction)weiboSwitchToggled:(UISwitch *)sender {
    if (sender.on)
    {
        
    }
    else
    { // 取消绑定
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"解除绑定"
                                                            message:@"将无法分享卡片到新浪微博"
                                                              style:LGAlertViewStyleActionSheet
                                                       buttonTitles:@[@"解除"]
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                      actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                          if (index == 0) {
                                                              kAccount.weiboModel = nil;
                                                              [sharedSettings reloadAccount];
                                                          }
                                                      } cancelHandler:^(LGAlertView *alertView) {
                                                          [sender setOn:YES animated:YES];
                                                      } destructiveHandler:nil];
        SetCourtesyAleryViewStyle(alertView, self.view)
        [alertView showAnimated:YES completionHandler:nil];
    }
}

- (IBAction)incognitoSwitchToggled:(UISwitch *)sender {
    if (sender.on) {
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"开启隐身模式"
                                                            message:@"你发布的所有卡片都会显示为匿名。"
                                                              style:LGAlertViewStyleActionSheet
                                                       buttonTitles:@[@"开启"]
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                      actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                          if (index == 0) {
                                                              // 发起开启隐身模式请求
                                                          }
                                                      } cancelHandler:^(LGAlertView *alertView) {
                                                          [sender setOn:NO animated:YES];
                                                      } destructiveHandler:nil];
        SetCourtesyAleryViewStyle(alertView, self.view)
        [alertView showAnimated:YES completionHandler:nil];
    }
    else
    {
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"关闭隐身模式"
                                                            message:@"你发布的所有公开卡片将会恢复显示你的信息。"
                                                              style:LGAlertViewStyleActionSheet
                                                       buttonTitles:@[@"关闭"]
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                      actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                          if (index == 0) {
                                                              // 发起关闭隐身模式请求
                                                          }
                                                      } cancelHandler:^(LGAlertView *alertView) {
                                                          [sender setOn:YES animated:YES];
                                                      } destructiveHandler:nil];
        SetCourtesyAleryViewStyle(alertView, self.view)
        [alertView showAnimated:YES completionHandler:nil];
    }
}

@end
