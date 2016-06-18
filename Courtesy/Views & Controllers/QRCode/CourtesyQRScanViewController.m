//
//  CourtesyQRScanViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "CourtesyQRScanViewController.h"
#import "CourtesyQRCodeModel.h"
#import "LBXScanResult.h"
#import "LBXScanWrapper.h"
#import "CourtesyCardManager.h"

// 振动系统声音
static SystemSoundID shake_sound_male_id = 0;

@interface CourtesyQRScanViewController () <LGAlertViewDelegate, CourtesyQRCodeQueryDelegate, JVFloatingDrawerCenterViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) LGAlertView *currentAlert;

@end

@implementation CourtesyQRScanViewController 

#pragma mark - 初始化扫描界面

- (instancetype)init {
    if (self = [super init]) {
        // 初始化扫描样式
        LBXScanViewStyle *style = [[LBXScanViewStyle alloc] init];
        style.centerUpOffset = 44;
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
        style.photoframeLineW = 6;
        style.photoframeAngleW = 24;
        style.photoframeAngleH = 24;
        style.colorRetangleLine = [UIColor magicColor];
        style.colorAngle = [UIColor magicColor];
        style.animationStyle = LBXScanViewAnimationStyle_LineMove;
        style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_magic_red"];
        self.isOpenInterestRect = YES;
        self.style = style;
        self.isQQSimulator = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setTintColor:[UIColor whiteColor]];
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"399-list1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(autobackToDrawer)];
    self.navigationItem.leftBarButtonItem = leftItem;
    [[[navigationBar subviews] objectAtIndex:0] setAlpha:0.6];
    [navigationBar setBarTintColor:[UIColor blackColor]];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.title = @"扫一扫";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLocalNotification:)
                                                 name:kCourtesyNotificationInfo object:nil];
}

- (void)didReceiveLocalNotification:(NSNotification *)notification {
    if (!notification.userInfo || ![notification.userInfo hasKey:@"action"]) {
        return;
    }
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqualToString:kCourtesyActionScanRestartCapture]) {
        [self performSelector:@selector(restartCapture) withObject:nil afterDelay:1.0f];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.navigationController.view makeToast:@"向右划动以返回"
                                     duration:kStatusBarNotificationTime
                                     position:CSToastPositionCenter];
}

#pragma mark - 处理界面出现、消失事件

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self drawScanView];
    [self drawBottomItems];
    [self performSelector:@selector(startScan) withObject:nil afterDelay:0.2];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.isOpenFlash = NO;
    [_scanObj stopScan];
    [_qRScanView stopScanAnimation];
}

#pragma mark - 画界面元素

- (void)drawScanView {
    if (!_qRScanView) {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);
        self.qRScanView = [[LBXScanView alloc] initWithFrame:rect style:_style];
        [self.view addSubview:_qRScanView];
    }
    [_qRScanView startDeviceReadyingWithText:@"相机启动中"];
}

- (void)drawBottomItems {
    if (_bottomItemsView) {
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
        [self.view bringSubviewToFront:_bottomItemsView];
        return;
    }
    
    // 修正横屏情况，重新计算
    NSUInteger selfHeight = 100;
    UIView *bottomItemsView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.bounds) - selfHeight, CGRectGetWidth(self.view.bounds), selfHeight)];
    bottomItemsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    _bottomItemsView = bottomItemsView;
    
    CGSize size = CGSizeMake(65, 87);
    
    UIButton *btnFlash = [[UIButton alloc] init];
    btnFlash.bounds = CGRectMake(0, 0, size.width, size.height);
    btnFlash.center = CGPointMake(CGRectGetWidth(bottomItemsView.frame) / 3 * 2, CGRectGetHeight(bottomItemsView.frame) / 2);
    [btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_down"] forState:UIControlStateSelected];
    [btnFlash addTarget:self action:@selector(openOrCloseFlash:) forControlEvents:UIControlEventTouchUpInside];
    _btnFlash = btnFlash;
    
    UIButton *btnPhoto = [[UIButton alloc] init];
    btnPhoto.bounds = btnFlash.bounds;
    btnPhoto.center = CGPointMake(CGRectGetWidth(bottomItemsView.frame) / 3, CGRectGetHeight(bottomItemsView.frame) / 2);
    [btnPhoto setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_photo_nor"] forState:UIControlStateNormal];
    [btnPhoto setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_photo_down"] forState:UIControlStateHighlighted];
    [btnPhoto addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventTouchUpInside];
    _btnPhoto = btnPhoto;
    
    [self.view addSubview:bottomItemsView];
    [bottomItemsView addSubview:btnFlash];
    [bottomItemsView addSubview:btnPhoto];
}

#pragma mark - JVFloatingDrawerCenterViewController

- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide {
    if (drawerSide == JVFloatingDrawerSideLeft) return YES;
    return NO;
}

- (void)autobackToDrawer {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

#pragma mark - 二维码扫描结果解析

// 处理扫描结果回调
- (void)scanResultWithArray:(NSArray <LBXScanResult *> *)array {
    self.isOpenFlash = NO;
    if (array.count < 1) {
        // Pop-error
        [self showError:@"二维码识别失败"];
        return;
    }
    LBXScanResult *scanResult = array[0];
    NSString *strResult = scanResult.strScanned;
    self.scanImage = scanResult.imgScanned;
    if (!strResult) {
        [self showError:@"图像中未找到有效的二维码"];
        return;
    }
    [LBXScanWrapper systemVibrate];
    [self playShakeSound];
    // Succeed
    [self showSucceed:strResult];
}

// 扫描失败
- (void)showError:(NSString *)str {
    dispatch_async_on_main_queue(^{
        __weak typeof(self) weakSelf = self;
        LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"错误"
                                                            message:str
                                                              style:LGAlertViewStyleActionSheet
                                                       buttonTitles:nil
                                                  cancelButtonTitle:@"好"
                                             destructiveButtonTitle:nil
                                                      actionHandler:nil
                                                      cancelHandler:^(LGAlertView *alertView) {
                                                          [weakSelf performSelector:@selector(restartCapture) withObject:nil afterDelay:kStatusBarNotificationTime];
                                                      }
                                                 destructiveHandler:nil];
        SetCourtesyAleryViewStyle(alertView)
    
        if (self.currentAlert && self.currentAlert.isShowing) {
            [self.currentAlert transitionToAlertView:alertView completionHandler:nil];
        } else {
            [alertView showAnimated:YES completionHandler:nil];
        }
        self.currentAlert = alertView;
    });
}

// 扫描成功的处理方式
- (void)showSucceed:(NSString *)str {
    NSURL *url = [NSURL URLWithString:str];
    if (!url
        || ![[url host] isEqualToString:API_DOMAIN] 
        || ![[url path] isEqualToString:API_QRCODE_PATH]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            dispatch_async_on_main_queue(^{
            __weak typeof(self) weakSelf = self;
                LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"跳转提示"
                                                                    message:str
                                                                      style:LGAlertViewStyleActionSheet
                                                               buttonTitles:@[@"前往"]
                                                          cancelButtonTitle:@"取消"
                                                     destructiveButtonTitle:nil
                                                              actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                                  if (index == 0) {
                                                                      [[UIApplication sharedApplication] openURL:url];
                                                                  }
                                                                  [weakSelf performSelector:@selector(restartCapture) withObject:nil afterDelay:kStatusBarNotificationTime];
                                                              }
                                                              cancelHandler:^(LGAlertView *alertView) {
                                                                  [weakSelf performSelector:@selector(restartCapture) withObject:nil afterDelay:kStatusBarNotificationTime];
                                                              }
                                                         destructiveHandler:nil];
                alertView.delegate = self;
                SetCourtesyAleryViewStyle(alertView)
                
                if (self.currentAlert && self.currentAlert.isShowing) {
                    [self.currentAlert transitionToAlertView:alertView completionHandler:nil];
                } else {
                    [alertView showAnimated:YES completionHandler:nil];
                }
                self.currentAlert = alertView;
            });
        } else {
            [[UIPasteboard generalPasteboard] setString:str];
            [self showError:@"二维码数据已储存到剪贴板"];
        }
        return;
    }
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url
                                                resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;
    NSString *qrcode_id = [queryItems valueForQueryKey:@"id"];
    if (!qrcode_id || [qrcode_id isEmpty] || [qrcode_id length] != 32) {
        [self showError:@"「礼记」二维码标识符不正确"];
        return;
    }
    
    // 扫描成功，进行查询
    dispatch_async_on_main_queue(^{
        LGAlertView *scanActivityAlert = [[LGAlertView alloc] initWithActivityIndicatorAndTitle:@"读取中"
                                                                                        message:@"正在请求二维码信息"
                                                                                          style:LGAlertViewStyleActionSheet
                                                                                   buttonTitles:nil
                                                                              cancelButtonTitle:nil
                                                                         destructiveButtonTitle:nil
                                                                                  actionHandler:nil
                                                                                  cancelHandler:nil
                                                                             destructiveHandler:nil];
        SetCourtesyAleryViewStyle(scanActivityAlert)
    
        if (self.currentAlert && self.currentAlert.isShowing) {
            [self.currentAlert transitionToAlertView:scanActivityAlert completionHandler:nil];
        } else {
            [scanActivityAlert showAnimated:YES completionHandler:nil];
        }
        self.currentAlert = scanActivityAlert;
    });
    
    CourtesyQRCodeModel *newQRCode = [[CourtesyQRCodeModel alloc] initWithDelegate:self
                                                                               uid:qrcode_id];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [newQRCode sendRequestQuery];
    });
}

#pragma mark - CourtesyQRCodeQueryDelegate

// 扫描获取信息成功回调
- (void)queryQRCodeSucceed:(CourtesyQRCodeModel *)qrcode {
    [self scanWithResult:qrcode];
}

// 扫描获取信息失败回调
- (void)queryQRCodeFailed:(CourtesyQRCodeModel *)qrcode
             errorMessage:(NSString *)message {
    [self showError:message];
}

#pragma mark - CourtesyQRCodeScanDelegate

- (void)scanWithResult:(CourtesyQRCodeModel *)qrcode {
    if (!qrcode) {
        return;
    }
    // 发布、修改或查看
    if (qrcode.is_recorded == NO) {
        if (![sharedSettings hasLogin]) { // 未登录
            [self showError:@"登录后才能发布新卡片"];
            return;
        }
        dispatch_async_on_main_queue(^{
            if (self.currentAlert && self.currentAlert.isShowing) {
                [self.currentAlert dismissAnimated:YES completionHandler:nil];
            }
            // 发布新卡片界面并设置二维码数据
            CourtesyCardModel *newCard = [[CourtesyCardManager sharedManager] composeNewCardWithViewController:self];
            newCard.qr_id = qrcode.unique_id;
        });
    } else {
        if (!qrcode.card_token) {
            [self showError:@"卡片信息获取失败"];
            return;
        }
        if (self.currentAlert && self.currentAlert.isShowing) {
            dispatch_async_on_main_queue(^{
                [self.currentAlert dismissAnimated:YES completionHandler:nil];
            });
        }
        [[CourtesyCardManager sharedManager] handleRemoteCardToken:qrcode.card_token withController:self];
    }
}

#pragma mark - 扫描相关功能性方法

// 播放振动
- (void)playShakeSound {
    if (shake_sound_male_id != 0) {
        AudioServicesPlaySystemSound(shake_sound_male_id);
        return;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"kisssound" ofType:@"wav"];
    if (path) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
    }
}

// 打开或关闭闪光灯
- (void)openOrCloseFlash:(UIButton *)sender {
    if (sender.selected) {
        [_scanObj openFlash:NO];
        sender.selected = NO;
    } else {
        [_scanObj openFlash:YES];
        sender.selected = YES;
    }
}

- (void)setIsOpenFlash:(BOOL)isOpenFlash {
    _isOpenFlash = isOpenFlash;
    _btnFlash.selected = isOpenFlash;
}

// 检查权限并打开相册
- (void)openPhoto {
    if ([LBXScanWrapper isGetPhotoPermission]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self showError:@"请到「设置 - 隐私」中，找到应用程序「礼记」开启应用相册访问权限。"];
    }
}

#pragma mark - Memory

- (void)dealloc {
    CYLog(@"");
}

- (void)stopCapture {
    [_scanObj stopScan];
}

- (void)restartCapture {
    [_scanObj startScan];
}

- (void)startScan {
    if ( ![LBXScanWrapper isGetCameraPermission] ) {
        [_qRScanView stopDeviceReadying];
        [self showError:@"请到「设置 - 隐私」中开启本程序相机权限"];
        return;
    }
    if (!_scanObj) {
        __weak __typeof(self) weakSelf = self;
        CGRect cropRect = CGRectZero;
        if (_isOpenInterestRect) {
            cropRect = [LBXScanView getScanRectWithPreView:self.view style:_style];
        }
        self.scanObj = [[LBXScanWrapper alloc] initZXingWithPreView:self.view
                                                            success:^(NSArray<LBXScanResult *> *array) {
                                                                [weakSelf scanResultWithArray:array];
                                                            }];
    }
    [_scanObj startScan];
    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];
    self.view.backgroundColor = [UIColor clearColor];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    __weak __typeof(self) weakSelf = self;
    [LBXScanWrapper recognizeImage:image success:^(NSArray<LBXScanResult *> *array) {
        [weakSelf scanResultWithArray:array];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end

