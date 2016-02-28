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
    if (![_introductionField.text isMaxLength:(4096 * 8)]) {
        [self.navigationController.view makeToast:@"你居然真的往这里面粘贴了一部小说！？"
                                         duration:2.0
                                         position:CSToastPositionCenter
                                            style:nil];
        return;
    }
    [kProfile setIntroduction:_introductionField.text];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
