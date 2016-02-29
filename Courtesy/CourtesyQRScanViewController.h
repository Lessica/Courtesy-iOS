//
//  CourtesyQRScanViewController.h
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "LBXScanViewController.h"
#import "CourtesyQRCodeModel.h"

@protocol CourtesyQRCodeScanDelegate <NSObject>

@optional
- (void)scanWithResult:(CourtesyQRCodeModel *)qrcode;

@end

@interface CourtesyQRScanViewController : LBXScanViewController
@property (nonatomic, assign) BOOL isQQSimulator;
@property (nonatomic, strong) UILabel *topTitle;
@property (nonatomic, strong) UIView *bottomItemsView;
@property (nonatomic, strong) UIButton *btnPhoto;
@property (nonatomic, strong) UIButton *btnFlash;
@property (nonatomic, weak) id<CourtesyQRCodeScanDelegate> delegate;

@end
