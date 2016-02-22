//
//  CourtesyAboutViewController.m
//  Courtesy
//
//  Created by Zheng on 2/22/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAboutViewController.h"
#import "GlobalDefine.h"

@interface CourtesyAboutViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *appLabel;

@end

@implementation CourtesyAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 跳转到官方网站的手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailLabelClicked:)];
    tapGesture.delegate = self;
    [_detailLabel addGestureRecognizer:tapGesture];
    
    // 应用展示标签
    _appLabel.text = [NSString stringWithFormat:@"%@ V%@", APP_NAME_CN, VERSION_STRING];
}

- (void)detailLabelClicked:(UITapGestureRecognizer *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://82flex.com"]];
}

@end
