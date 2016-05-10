//
//
//  
//
//  Created by lbxia on 15/10/21.
//  Copyright © 2015年 lbxia. All rights reserved.
//

#import "LBXScanViewController.h"

@interface LBXScanViewController ()
@end

@implementation LBXScanViewController

- (void)drawScanView {
    if (!_qRScanView) {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);
        self.qRScanView = [[LBXScanView alloc] initWithFrame:rect style:_style];
        [self.view addSubview:_qRScanView];
    }
    [_qRScanView startDeviceReadyingWithText:@"相机启动中"];
}

- (void)stopCapture {
    [_scanObj stopScan];
}

- (void)removeCapture {
    [_scanObj removeNativeScan];
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
        [_scanObj setNeedCaptureImage:_isNeedScanImage];
    }
    [_scanObj startScan];
    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_scanObj stopScan];
    [_qRScanView stopScanAnimation];
}

#pragma mark -实现类继承该方法，作出对应处理

- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array {
    
}

- (void)openOrCloseFlash {
    [_scanObj openOrCloseFlash];
    
    self.isOpenFlash =!self.isOpenFlash;
    
}

#pragma mark --打开相册并识别图片

- (void)openLocalPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

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

- (void)showError:(NSString*)str {
    
}

@end
