//
//  CourtesyProfileIntroductionTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/26/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyProfileIntroductionTableViewController.h"

@interface CourtesyProfileIntroductionTableViewController ()

@property (weak, nonatomic) IBOutlet UITextView *introductionField;


@end

@implementation CourtesyProfileIntroductionTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _introductionField.text = kProfile.introduction;
    [self.tableView reloadData];
}

- (IBAction)saveButtonClicked:(id)sender {
    [self.view endEditing:YES];
    if (![_introductionField.text isMaxLength:(72)]) {
        [self.navigationController.view makeToast:@"座右铭至多 72 个字符"
                                         duration:kStatusBarNotificationTime
                                         position:CSToastPositionCenter
                                            style:nil];
        return;
    }
    [kProfile setIntroduction:_introductionField.text];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
