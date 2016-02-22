//
//  CourtesyQRScanViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "CourtesyQRScanViewController.h"
#import "LBXScanResult.h"
#import "LBXScanWrapper.h"
#import "Colours.h"
#import "LGAlertView.h"

static SystemSoundID shake_sound_male_id = 0;

@interface CourtesyQRScanViewController () <LGAlertViewDelegate>

@end

@implementation CourtesyQRScanViewController 

- (instancetype)init {
    if (self = [super init]) {
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
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)drawTitle {
    if (!_topTitle) {
        self.topTitle = [[UILabel alloc] init];
        _topTitle.bounds = CGRectMake(0, 0, 145, 60);
        _topTitle.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, 50);
        if ([UIScreen mainScreen].bounds.size.height <= 568) {
            _topTitle.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, 38);
            _topTitle.font = [UIFont systemFontOfSize:14];
        }
        _topTitle.textAlignment = NSTextAlignmentCenter;
        _topTitle.numberOfLines = 0;
        _topTitle.text = @"将取景框对准二维码即可自动扫描";
        _topTitle.textColor = [UIColor whiteColor];
        [self.view addSubview:_topTitle];
    }
}

- (void)drawBottomItems {
    if (_bottomItemsView) {
        return;
    }
    
    self.bottomItemsView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - 164, CGRectGetWidth(self.view.frame), 100)];
    _bottomItemsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:_bottomItemsView];
    
    CGSize size = CGSizeMake(65, 87);
    
    self.btnFlash = [[UIButton alloc] init];
    _btnFlash.bounds = CGRectMake(0, 0, size.width, size.height);
    _btnFlash.center = CGPointMake(CGRectGetWidth(_bottomItemsView.frame) / 3 * 2, CGRectGetHeight(_bottomItemsView.frame)/2);
    [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [_btnFlash addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnPhoto = [[UIButton alloc] init];
    _btnPhoto.bounds = _btnFlash.bounds;
    _btnPhoto.center = CGPointMake(CGRectGetWidth(_bottomItemsView.frame) / 3, CGRectGetHeight(_bottomItemsView.frame)/2);
    [_btnPhoto setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_photo_nor"] forState:UIControlStateNormal];
    [_btnPhoto setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_photo_down"] forState:UIControlStateHighlighted];
    [_btnPhoto addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomItemsView addSubview:_btnFlash];
    [_bottomItemsView addSubview:_btnPhoto];
}

- (void)showError:(NSString *)str {
    LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"错误"
                                                        message:str
                                                          style:LGAlertViewStyleAlert
                                                   buttonTitles:nil
                                              cancelButtonTitle:@"好"
                                         destructiveButtonTitle:nil];
    [alertView showAnimated:YES completionHandler:nil];
}

- (void)showSucceed:(NSString *)str {
    LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"提示"
                                                        message:str
                                                          style:LGAlertViewStyleAlert
                                                   buttonTitles:nil
                                              cancelButtonTitle:@"好"
                                         destructiveButtonTitle:nil];
    alertView.delegate = self;
    [alertView showAnimated:YES completionHandler:nil];
}

- (void)alertViewCancelled:(LGAlertView *)alertView {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

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

- (void)playShakeSound {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"kisssound" ofType:@"wav"];
    if (path) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
    }
    AudioServicesPlaySystemSound(shake_sound_male_id);
}

- (void)openPhoto {
    if ([LBXScanWrapper isGetPhotoPermission]) {
        [self openLocalPhoto];
    } else {
        [self showError:@"请到「设置 - 隐私」中，找到应用程序「礼记」开启应用相册访问权限。"];
    }
}

- (void)openOrCloseFlash {
    [super openOrCloseFlash];
    if (self.isOpenFlash) {
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    } else {
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_isQQSimulator) {
        [self drawBottomItems];
        [self drawTitle];
        [self.view bringSubviewToFront:_topTitle];
    } else {
        _topTitle.hidden = YES;
    }
}

@end
