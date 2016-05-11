//
//  CourtesyQRScanViewController.h
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyQRCodeModel.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LBXScanView.h"
#import "LBXScanWrapper.h"

@interface CourtesyQRScanViewController : UIViewController

@property (nonatomic, assign) BOOL isQQSimulator;
@property (nonatomic, strong) UILabel *topTitle;
@property (nonatomic, strong) UIView *bottomItemsView;
@property (nonatomic, strong) UIButton *btnPhoto;
@property (nonatomic, strong) UIButton *btnFlash;

@property (nonatomic, assign) BOOL isNeedScanImage;
@property (nonatomic, strong) LBXScanWrapper *scanObj;
@property (nonatomic, strong) LBXScanView *qRScanView;
@property (nonatomic, strong) LBXScanViewStyle *style;
@property (nonatomic, strong) UIImage *scanImage;
@property (nonatomic, assign)BOOL isOpenInterestRect;
@property (nonatomic, assign) BOOL isOpenFlash;

@end
