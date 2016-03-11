//
//  CourtesyLoginRegisterViewController.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAccountModel.h"
#import "CourtesyLoginRegisterViewController.h"
#import "CourtesyLoginRegisterTextField.h"
#import "CourtesyLoginRegisterModel.h"

@interface CourtesyLoginRegisterViewController () <CourtesyLoginRegisterDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpace;
@property (weak, nonatomic) IBOutlet CourtesyLoginRegisterTextField *loginEmailTextField;
@property (weak, nonatomic) IBOutlet CourtesyLoginRegisterTextField *loginPasswordTextField;
@property (weak, nonatomic) IBOutlet CourtesyLoginRegisterTextField *registerEmailTextField;
@property (weak, nonatomic) IBOutlet CourtesyLoginRegisterTextField *registerPasswordTextField;

@end

@implementation CourtesyLoginRegisterViewController

#pragma mark - 初始化样式
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
    [self.view endEditing:YES];
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

- (IBAction)loginFromQQ:(id)sender {
    [self.view endEditing:YES];
    [self.view makeToast:@"暂时无法提供此服务"
                duration:1.2
                position:CSToastPositionCenter];
}

- (IBAction)loginFromWeibo:(id)sender {
    [self.view endEditing:YES];
    [self.view makeToast:@"暂时无法提供此服务"
                duration:1.2
                position:CSToastPositionCenter];
}

- (IBAction)loginFromTencent:(id)sender {
    [self.view endEditing:YES];
    [self.view makeToast:@"暂时无法提供此服务"
                duration:1.2
                position:CSToastPositionCenter];
}

- (IBAction)loginCourtesyAccount:(id)sender {
    [self.view endEditing:YES];
    [self.view makeToastActivity:CSToastPositionCenter];
    CourtesyLoginRegisterModel *loginModel = [[CourtesyLoginRegisterModel alloc] initWithAccount:_loginEmailTextField.text password:_loginPasswordTextField.text delegate:self];
    [loginModel sendRequestLogin];
}

- (IBAction)registerCourtesyAccount:(id)sender {
    [self.view endEditing:YES];
    [self.view makeToastActivity:CSToastPositionCenter];
    CourtesyLoginRegisterModel *regModel = [[CourtesyLoginRegisterModel alloc] initWithAccount:_registerEmailTextField.text password:_registerPasswordTextField.text delegate:self];
    [regModel sendRequestRegister];
}

- (IBAction)forgetPasswordClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:API_FORGET_PASSWORD]];
}

#pragma mark - CourtesyLoginRegisterDelegate 注册登录委托方法

- (void)loginRegisterFailed:(CourtesyLoginRegisterModel *)sender
               errorMessage:(NSString *)message
                    isLogin:(BOOL)login {
    [self.view hideToastActivity];
    [self.view makeToast:message
                duration:1.2
                position:CSToastPositionCenter];
}

- (void)loginRegisterSucceed:(CourtesyLoginRegisterModel *)sender
                     isLogin:(BOOL)login {
    [self.view hideToastActivity];
    if (login) {
        [self.view makeToast:@"登录成功"
                    duration:3.0
                    position:CSToastPositionCenter
                       title:nil
                       image:nil
                       style:nil
                  completion:^(BOOL didTap) {
                      [self close];
                  }];
    } else {
        [self.view makeToast:@"注册成功"
                    duration:3.0
                    position:CSToastPositionCenter
                       title:nil
                       image:nil
                       style:nil
                  completion:^(BOOL didTap) {
                      [self close];
                  }];
    }
    [self.view setUserInteractionEnabled:NO];
    // 设置登录成功状态
    [kAccount setEmail:[sender email]];
    [sharedSettings setHasLogin:YES];
    // 发送全局登录成功通知
    [NSNotificationCenter sendCTAction:kActionLogin message:nil];
}

- (void)dealloc {
    CYLog(@"");
}

@end
