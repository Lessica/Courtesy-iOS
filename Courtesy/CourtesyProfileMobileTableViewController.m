//
//  CourtesyProfileMobileTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/26/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyProfileMobileTableViewController.h"

@interface CourtesyProfileMobileTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mobileField;

@end

@implementation CourtesyProfileMobileTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _mobileField.text = kProfile.mobile;
    [self.tableView reloadData];
}

- (IBAction)saveButtonClicked:(id)sender {
    [kProfile setMobile:_mobileField.text];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
