//
//  CourtesyLoginRegisterViewController.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyLoginRegisterViewController.h"
#import "UIView+Toast.h"

@interface CourtesyLoginRegisterViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpace;

@end

@implementation CourtesyLoginRegisterViewController

#pragma mark - 初始化样式
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// 关闭按钮
- (IBAction)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 失去焦点
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// 切换注册登录区域
- (IBAction)loginOrRegister:(UIButton *)button {
    if (self.leadingSpace.constant == 0) {
        self.leadingSpace.constant = -self.view.frame.size.width;
        button.selected = YES;
    } else {
        self.leadingSpace.constant = 0;
        button.selected = NO;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 按钮事件

- (IBAction)forgetButtonClicked:(id)sender {
    // 跳转到忘记密码页面
}

- (IBAction)loginFromQQ:(id)sender {
    [self.view makeToast:@"暂时无法提供此服务"
                duration:1.2
                position:CSToastPositionCenter];
}

- (IBAction)loginFromWeibo:(id)sender {
    [self.view makeToast:@"暂时无法提供此服务"
                duration:1.2
                position:CSToastPositionCenter];
}

- (IBAction)loginFromTencent:(id)sender {
    [self.view makeToast:@"暂时无法提供此服务"
                duration:1.2
                position:CSToastPositionCenter];
}

- (IBAction)loginCourtesyAccount:(id)sender {
    
}

- (IBAction)registerCourtesyAccount:(id)sender {
    
}

@end
