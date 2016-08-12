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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _nickField.text = kProfile.nick;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_nickField becomeFirstResponder];
}

- (IBAction)saveButtonClicked:(id)sender {
    [self.view endEditing:YES];
    if (![_nickField.text isMinLength:2 andMaxLength:21]) {
        [self.navigationController.view makeToast:@"昵称至少 2 个字符，至多 21 个字符"
                                         duration:kStatusBarNotificationTime
                                         position:CSToastPositionCenter
                                            style:nil];
        return;
    }
    [kProfile setNick:_nickField.text];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
