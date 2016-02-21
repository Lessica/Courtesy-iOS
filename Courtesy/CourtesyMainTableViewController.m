//
//  CourtesyMainTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyMainTableViewController.h"
#import "AppDelegate.h"

@interface CourtesyMainTableViewController ()

@end

@implementation CourtesyMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionScanQRCode:(id)sender {
    [[AppDelegate globalDelegate] toggleScanView:self animated:YES];
}

@end
