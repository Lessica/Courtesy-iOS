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

// 振动系统声音
static SystemSoundID shake_sound_male_id = 0;

@interface CourtesyQRScanViewController () <LGAlertViewDelegate, CourtesyQRCodeQueryDelegate, JVFloatingDrawerCenterViewController>

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

#pragma mark - 画界面元素

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
    [btnFlash addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark - 扫描结果处理

// 处理扫描结果回调
- (void)scanResultWithArray:(NSArray <LBXScanResult*>*)array {
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

// 扫描成功
- (void)showSucceed:(NSString *)str {
    NSURL *url = [NSURL URLWithString:str];
    if (!url
       /* || ![[url host] isEqualToString:API_DOMAIN] */
        || ![[url path] isEqualToString:API_QRCODE_PATH]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"跳转提示"
                                                                message:str
                                                                  style:LGAlertViewStyleAlert
                                                           buttonTitles:@[@"前往"]
                                                      cancelButtonTitle:@"取消"
                                                 destructiveButtonTitle:nil
                                                          actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                              if (index == 0) {
                                                                  [[UIApplication sharedApplication] openURL:url];
                                                              }
                                                          }
                                                          cancelHandler:nil
                                                     destructiveHandler:nil];
            alertView.delegate = self;
            [alertView showAnimated:YES completionHandler:nil];
        } else {
            [[UIPasteboard generalPasteboard] setString:str];
            [self.navigationController.view makeToast:@"二维码数据已储存到剪贴板"
                                             duration:kStatusBarNotificationTime
                                             position:CSToastPositionCenter];
        }
        [self performSelector:@selector(restartCapture) withObject:nil afterDelay:2.0];
        return;
    }
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url
                                                resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;
    NSString *qrcode_id = [queryItems valueForQueryKey:@"id"];
    if (!qrcode_id || [qrcode_id isEmpty] || [qrcode_id length] != 32) {
        [self.navigationController.view makeToast:@"「礼记」二维码标识符不正确"
                                         duration:kStatusBarNotificationTime
                                         position:CSToastPositionCenter];
        [self performSelector:@selector(restartCapture) withObject:nil afterDelay:2.0];
        return;
    }
    [self.navigationController.view makeToastActivity:CSToastPositionCenter];
    CourtesyQRCodeModel *newQRCode = [[CourtesyQRCodeModel alloc] initWithDelegate:self
                                                                               uid:qrcode_id];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [newQRCode sendRequestQuery];
    });
}

// 扫描获取信息成功回调
- (void)queryQRCodeSucceed:(CourtesyQRCodeModel *)qrcode {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController.view hideToastActivity];
        [self.navigationController.view makeToast:@"扫描成功"
                                         duration:kStatusBarNotificationTime
                                         position:CSToastPositionCenter];
    });
    // 返回上层并通知其弹出发布界面
    if (!_delegate || ![_delegate respondsToSelector:@selector(scanWithResult:)]) {
        CYLog(@"Delegate not found!");
        return;
    }
    [_delegate scanWithResult:qrcode];
    return;
}

- (void)autobackToDrawer {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

// 扫描获取信息失败回调
- (void)queryQRCodeFailed:(CourtesyQRCodeModel *)qrcode
             errorMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController.view hideToastActivity];
        [self.navigationController.view makeToast:message
                                         duration:kStatusBarNotificationTime
                                         position:CSToastPositionCenter];
    });
    [self performSelector:@selector(restartCapture) withObject:nil afterDelay:2.0];
    return;
}

// 扫描失败
- (void)showError:(NSString *)str {
    LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"错误"
                                                        message:str
                                                          style:LGAlertViewStyleAlert
                                                   buttonTitles:nil
                                              cancelButtonTitle:@"好"
                                         destructiveButtonTitle:nil];
    [alertView showAnimated:YES completionHandler:nil];
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
- (void)openOrCloseFlash {
    [super openOrCloseFlash];
    if (self.isOpenFlash) {
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    } else {
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    }
}

// 检查权限并打开相册
- (void)openPhoto {
    if ([LBXScanWrapper isGetPhotoPermission]) {
        [self openLocalPhoto];
    } else {
        [self showError:@"请到「设置 - 隐私」中，找到应用程序「礼记」开启应用相册访问权限。"];
    }
}

#pragma mark - JVFloatingDrawerCenterViewController

- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide {
    if (drawerSide == JVFloatingDrawerSideLeft) return YES;
    return NO;
}

- (void)dealloc {
    CYLog(@"");
}

@end
