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
@property (assign, nonatomic) BOOL usingOpenApi;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    self.usingOpenApi = YES;
    [[[GlobalSettings sharedInstance] tencentAuth] authorize:@[
                                                               kOPEN_PERMISSION_GET_USER_INFO,
                                                               kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                                               kOPEN_PERMISSION_ADD_SHARE
                                                               ]];
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

#pragma mark - 第三方登录事件通知

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.usingOpenApi) {
        [self.view setUserInteractionEnabled:YES];
        [self.view hideToastActivity];
        [self.view makeToast:@"用户取消登录"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
    }
}

- (void)didReceiveLocalNotification:(NSNotification *)notification {
    if (!notification.object || ![notification.object hasKey:@"action"]) {
        return;
    }
    NSString *action = [notification.object objectForKey:@"action"];
    if
        ([action isEqualToString:kTencentLoginSuccessed])
    {
        self.usingOpenApi = NO;
        // 腾讯互联登录成功
        // 用户 OpenId
        GlobalSettings *globalSettings = [GlobalSettings sharedInstance];
        CYLog(@"Tencent login success, openId: %@", globalSettings.tencentAuth.openId);
        NSString *uniqueStr = [[globalSettings.tencentAuth.openId substringToIndex:6] lowercaseString];
        _tencentOpenId = [@"qq" stringByAppendingString:uniqueStr];
        _tencentFakeEmail = [_tencentOpenId stringByAppendingString:@"@82flex.com"];
        // 尝试登录
        CourtesyLoginRegisterModel *loginModel = [[CourtesyLoginRegisterModel alloc] initWithAccount:_tencentFakeEmail password:_tencentOpenId delegate:self];
        loginModel.openAPI = CourtesyOpenApiTypeQQ;
        [loginModel sendRequestLogin];
    }
    else if ([action isEqualToString:kTencentGetUserInfoSucceed])
    {
        // 腾讯互联用户信息获取成功
        [self handleTencentUserInfo:notification.object[@"response"]];
    }
}

#pragma mark - CourtesyLoginRegisterDelegate 注册登录委托方法

- (void)loginRegisterFailed:(CourtesyLoginRegisterModel *)sender
               errorMessage:(NSString *)message
                    isLogin:(BOOL)login {
    if (sender.openAPI == CourtesyOpenApiTypeQQ) {
        if (login) { // 腾讯互联账户登录请求
            // 尝试注册腾讯互联账户，先获取用户信息
            GlobalSettings *globalSettings = [GlobalSettings sharedInstance];
            [globalSettings.tencentAuth getUserInfo];
        } else { // 腾讯互联账户注册请求
            [self openApiFailed:message];
        }
    } else if (sender.openAPI == CourtesyOpenApiTypeNone) {
        [self openApiFailed:message];
    }
}

- (void)loginRegisterSucceed:(CourtesyLoginRegisterModel *)sender
                     isLogin:(BOOL)login {
    [kAccount setEmail:[sender email]]; // 设置账户邮箱
    if (login)
    {
        [self notifyLoginStatus]; // 通知普通登录成功
        [self.view hideToastActivity];
        [self.view makeToast:@"登录成功"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter
                       title:nil
                       image:nil
                       style:nil
                  completion:^(BOOL didTap) {
                      [self close];
                  }];
    }
    else
    {
        if
            (sender.openAPI == CourtesyOpenApiTypeNone)
        {
            [self notifyLoginStatus]; // 通知普通注册成功
            [self.view hideToastActivity];
            [self.view makeToast:@"注册成功"
                        duration:kStatusBarNotificationTime
                        position:CSToastPositionCenter
                           title:nil
                           image:nil
                           style:nil
                      completion:^(BOOL didTap) {
                          [self close];
                      }];
        }
        else if
            (sender.openAPI == CourtesyOpenApiTypeQQ)
        {
            // 来自腾讯互联的首次注册请求视为第三方登录请求
            _tencentAvatarURL = [NSURL URLWithString:self.tencentInfo[@"figureurl_2"]];
            kProfile.nick = self.tencentInfo[@"nickname"];
            if
                ([self.tencentInfo[@"gender"] isEqualToString:@"男"])
            {
                kProfile.gender = 0;
            }
            else if ([self.tencentInfo[@"gender"] isEqualToString:@"女"])
            {
                kProfile.gender = 1;
            }
            else
            {
                kProfile.gender = 2;
            }
            kProfile.province = self.tencentInfo[@"province"];
            kProfile.city = self.tencentInfo[@"city"];
            kProfile.mobile = @"13800138000";
            kProfile.area = @"";
            kProfile.introduction = @"Tell me why you did it,\nevery dream falling apart.";
            kProfile.birthday = @"1996-01-01";
            kProfile.avatar = @"";
            [kProfile setDelegate:self]; // 设置请求代理
            [kProfile sendRequestEditProfile]; // 发送修改个人资料请求
        }
    }
}

#pragma mark - 用户提示信息及系统通知

- (void)openApiSucceed
{
    [self notifyLoginStatus];
    [self.view hideToastActivity];
    [self.view makeToast:@"第三方登录成功"
                duration:kStatusBarNotificationTime
                position:CSToastPositionCenter
                   title:nil
                   image:nil
                   style:nil
              completion:^(BOOL didTap) {
                  [self close];
              }];
}

- (void)openApiFailed:(NSString *)errorMessage
{
    [self.view hideToastActivity];
    [self.view setUserInteractionEnabled:YES];
    [self.view makeToast:errorMessage
                duration:kStatusBarNotificationTime
                position:CSToastPositionCenter];
}

- (void)notifyLoginStatus
{
    [sharedSettings setHasLogin:YES];
    // 发送全局登录成功通知
    [NSNotificationCenter sendCTAction:kCourtesyActionLogin message:nil];
}

#pragma mark - 第三方修改资料请求回调

- (void)editProfileSucceed:(CourtesyAccountProfileModel *)sender
{
    UIImage *avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:_tencentAvatarURL]];
    if (avatarImage) {
        [kProfile sendRequestUploadAvatar:avatarImage];
    } else {
        CYLog(@"No tencent avatar image fetched.");
        [self openApiSucceed];
    }
}

- (void)editProfileFailed:(CourtesyAccountProfileModel *)sender
             errorMessage:(NSString *)message
{
    CYLog(@"Tencent account info copy failed.");
    [self openApiSucceed];
}

#pragma mark - 第三方上传头像请求回调

- (void)uploadAvatarSucceed:(CourtesyAccountProfileModel *)sender
{
    [self openApiSucceed];
}

- (void)uploadAvatarFailed:(CourtesyAccountProfileModel *)sender
              errorMessage:(NSString *)message
{
    CYLog(@"Tencent avatar image upload failed.");
    [self openApiSucceed];
}

#pragma mark - 处理腾讯互联用户信息

- (void)handleTencentUserInfo:(APIResponse *)response
{
    if (!response) return;
    if (URLREQUEST_SUCCEED == response.retCode
        && kOpenSDKErrorSuccess == response.detailRetCode)
    {
        self.tencentInfo = response.jsonResponse;
        CourtesyLoginRegisterModel *registerModel = [[CourtesyLoginRegisterModel alloc] initWithAccount:_tencentFakeEmail password:_tencentOpenId delegate:self];
        registerModel.openAPI = YES;
        [registerModel sendRequestRegister];
    }
    else
    {
        [self openApiFailed:response.errorMsg];
    }
}

#pragma mark - Memory Management

- (void)dealloc
{
    CYLog(@"");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
