//
//  CourtesyProfileNickTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/26/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyProfileNickTableViewController.h"

@interface CourtesyProfileNickTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nickField;


@end

@implementation CourtesyProfileNickTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _nickField.text = kProfile.nick;
    [self.tableView reloadData];
}

- (IBAction)saveButtonClicked:(id)sender {
    [kProfile setNick:_nickField.text];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
