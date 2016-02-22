//
//  CourtesyAboutViewController.m
//  Courtesy
//
//  Created by Zheng on 2/22/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAboutViewController.h"

@interface CourtesyAboutViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation CourtesyAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailLabelClicked:)];
    tapGesture.delegate = self;
    [_detailLabel addGestureRecognizer:tapGesture];
}

- (void)detailLabelClicked:(UITapGestureRecognizer *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://82flex.com"]];
}

@end
