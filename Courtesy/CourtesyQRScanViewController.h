//
//  CourtesyQRScanViewController.h
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "LBXScanViewController.h"

@interface CourtesyQRScanViewController : LBXScanViewController
@property (nonatomic, assign) BOOL isQQSimulator;
@property (nonatomic, strong) UILabel *topTitle;
@property (nonatomic, strong) UIView *bottomItemsView;
@property (nonatomic, strong) UIButton *btnPhoto;
@property (nonatomic, strong) UIButton *btnFlash;

@end
