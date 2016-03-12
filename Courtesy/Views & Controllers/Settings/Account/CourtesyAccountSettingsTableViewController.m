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
@property (weak, nonatomic) IBOutlet UISwitch *tencentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *incognitoSwitch;
@property (weak, nonatomic) IBOutlet UILabel *label_1;
@property (weak, nonatomic) IBOutlet UILabel *label_2;
@property (weak, nonatomic) IBOutlet UILabel *label_3;

@end

@implementation CourtesyAccountSettingsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([sharedSettings hasLogin]) {
        _qqSwitch.enabled = _weiboSwitch.enabled = _tencentSwitch.enabled = _incognitoSwitch.enabled = YES;
        _label_1.alpha = _label_3.alpha = 1.0;
        _qqSwitch.on = [kAccount hasQQAccount];
        _weiboSwitch.on = [kAccount hasWeiboAccount];
        _tencentSwitch.on = [kAccount hasTencentAccount];
        _label_2.text = kProfile.nick;
        // _incognito
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![sharedSettings hasLogin]) {
        CourtesyLoginRegisterViewController *vc = [CourtesyLoginRegisterViewController new];
        CourtesyPortraitViewController *navc = [[CourtesyPortraitViewController alloc] initWithRootViewController:vc];
        [self presentViewController:navc animated:YES completion:nil];
        _qqSwitch.enabled = _weiboSwitch.enabled = _tencentSwitch.enabled = _incognitoSwitch.enabled = NO;
        _label_1.alpha = _label_3.alpha = 0.0;
        _label_2.text = @"你尚未登录";
    }
}

@end
