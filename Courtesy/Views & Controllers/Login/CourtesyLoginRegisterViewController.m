//
//  CourtesyLoginRegisterViewController.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyAccountModel.h"
#import "CourtesyLoginRegisterViewController.h"
#import "CourtesyLoginRegisterTextField.h"
#import "CourtesyLoginRegisterModel.h"

@interface CourtesyLoginRegisterViewController () <CourtesyLoginRegisterDelegate, CourtesyEditProfileDelegate, CourtesyUploadAvatarDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpace;
@property (weak, nonatomic) IBOutlet CourtesyLoginRegisterTextField *loginEmailTextField;
@property (weak, nonatomic) IBOutlet CourtesyLoginRegisterTextField *loginPasswordTextField;
@property (weak, nonatomic) IBOutlet CourtesyLoginRegisterTextField *registerEmailTextField;
@property (weak, nonatomic) IBOutlet CourtesyLoginRegisterTextField *registerPasswordTextField;
@property (strong, nonatomic) NSDictionary *tencentInfo;
@property (strong, nonatomic) NSString *tencentOpenId;
@property (strong, nonatomic) NSString *tencentFakeEmail;
@property (strong, nonatomic) NSURL *tencentAvatarURL;

@end

@implementation CourtesyLoginRegisterViewController

#pragma mark - 初始化样式
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLocalNotification:)
                                                 name:kCourtesyNotificationInfo object:nil];
}

- (void)didReceiveLocalNotification:(NSNotification *)notification {
    if (!notification.object || ![notification.object hasKey:@"action"]) {
        return;
    }
    NSString *action = [notification.object objectForKey:@"action"];
    if ([action isEqualToString:kTencentLoginSuccessed]) { // 腾讯互联登录成功
        // 用户 OpenId
        GlobalSettings *globalSettings = [GlobalSettings sharedInstance];
        CYLog(@"Tencent login success, openId: %@", globalSettings.tencentAuth.openId);
        NSString *uniqueStr = [[globalSettings.tencentAuth.openId substringToIndex:6] lowercaseString];
        _tencentOpenId = [@"qq" stringByAppendingString:uniqueStr];
        _tencentFakeEmail = [_tencentOpenId stringByAppendingString:@"@82flex.com"];
        // 尝试登录
        CourtesyLoginRegisterModel *loginModel = [[CourtesyLoginRegisterModel alloc] initWithAccount:_tencentFakeEmail password:_tencentOpenId delegate:self];
        loginModel.openAPI = YES;
        [loginModel sendRequestLogin];
    } else if ([action isEqualToString:kTencentGetUserInfoSucceed]) {
        [self handleTencentUserInfo:notification.object[@"response"]];
    }
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
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity:CSToastPositionCenter];
    [[[GlobalSettings sharedInstance] tencentAuth] authorize:@[
                                                               kOPEN_PERMISSION_GET_USER_INFO,
                                                               kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                                               kOPEN_PERMISSION_ADD_SHARE
                                                               ] inSafari:NO];
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
    [self.view setUserInteractionEnabled:NO];
    [self.view makeToastActivity:CSToastPositionCenter];
    CourtesyLoginRegisterModel *loginModel = [[CourtesyLoginRegisterModel alloc] initWithAccount:_loginEmailTextField.text password:_loginPasswordTextField.text delegate:self];
    [loginModel sendRequestLogin];
}

- (IBAction)registerCourtesyAccount:(id)sender {
    [self.view endEditing:YES];
    [self.view setUserInteractionEnabled:NO];
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
    if (sender.openAPI) {
        if (login) { // 腾讯互联账户登录请求
            // 尝试注册腾讯互联账户，先获取用户信息
            GlobalSettings *globalSettings = [GlobalSettings sharedInstance];
            [globalSettings.tencentAuth getUserInfo];
        } else { // 腾讯互联账户注册请求
            [self.view hideToastActivity];
            [self.view setUserInteractionEnabled:YES];
            [self.view makeToast:[message stringByAppendingString:@" (Tencent)"]
                        duration:1.2
                        position:CSToastPositionCenter];
        }
    } else {
        [self.view hideToastActivity];
        [self.view setUserInteractionEnabled:YES];
        [self.view makeToast:message
                    duration:1.2
                    position:CSToastPositionCenter];
    }
}

- (void)loginRegisterSucceed:(CourtesyLoginRegisterModel *)sender
                     isLogin:(BOOL)login {
    if (login) {
        [self.view hideToastActivity];
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
        if (sender.openAPI) {
            _tencentAvatarURL = [NSURL URLWithString:self.tencentInfo[@"figureurl_2"]];
            kProfile.nick = self.tencentInfo[@"nickname"];
            if ([self.tencentInfo[@"gender"] isEqualToString:@"男"]) {
                kProfile.gender = 0;
            } else if ([self.tencentInfo[@"gender"] isEqualToString:@"女"]) {
                kProfile.gender = 1;
            } else {
                kProfile.gender = 2;
            }
            kProfile.province = self.tencentInfo[@"province"];
            kProfile.city = self.tencentInfo[@"city"];
            kProfile.mobile = @"";
            kProfile.area = @"";
            kProfile.introduction = @"";
            kProfile.birthday = @"";
            kProfile.avatar = @"";
            [kProfile setDelegate:self]; // 设置请求代理
            [kProfile sendRequestEditProfile];
        }
        [self.view hideToastActivity];
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
    
    // 设置登录成功状态
    [kAccount setEmail:[sender email]];
//    [self notifyLoginStatus];
}

- (void)notifyLoginStatus {
    [sharedSettings setHasLogin:YES];
    // 发送全局登录成功通知
    [NSNotificationCenter sendCTAction:kActionLogin message:nil];
}

#pragma mark - 修改资料请求回调

- (void)editProfileSucceed:(CourtesyAccountProfileModel *)sender {
    UIImage *avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:_tencentAvatarURL]];
    if (avatarImage) {
        [kProfile sendRequestUploadAvatar:avatarImage];
    } else {
        CYLog(@"No tencent avatar image fetched.");
        [self notifyLoginStatus];
    }
}

- (void)editProfileFailed:(CourtesyAccountProfileModel *)sender
             errorMessage:(NSString *)message {
    CYLog(@"Tencent account info copy failed.");
    [self notifyLoginStatus];
}

#pragma mark - 上传头像请求回调

- (void)uploadAvatarSucceed:(CourtesyAccountProfileModel *)sender {
    [self notifyLoginStatus];
}

- (void)uploadAvatarFailed:(CourtesyAccountProfileModel *)sender
              errorMessage:(NSString *)message {
    CYLog(@"Tencent avatar image upload failed.");
    [self notifyLoginStatus];
}

- (void)handleTencentUserInfo:(APIResponse *)response {
    if (!response) return;
    if (URLREQUEST_SUCCEED == response.retCode
        && kOpenSDKErrorSuccess == response.detailRetCode) {
        self.tencentInfo = response.jsonResponse;
        CourtesyLoginRegisterModel *registerModel = [[CourtesyLoginRegisterModel alloc] initWithAccount:_tencentFakeEmail password:_tencentOpenId delegate:self];
        registerModel.openAPI = YES;
        [registerModel sendRequestRegister];
    } else {
        [self.view hideToastActivity];
        [self.view makeToast:response.errorMsg
                    duration:1.2
                    position:CSToastPositionCenter];
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
