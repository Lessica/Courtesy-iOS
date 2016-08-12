//
//  CourtesyProfileBirthdayTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/26/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyProfileBirthdayTableViewController.h"

@interface CourtesyProfileBirthdayTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthdayPicker;


@end

@implementation CourtesyProfileBirthdayTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _birthdayField.text = kProfile.birthday;
    if (![_birthdayField.text isEmpty]) {
        @try {
            [_birthdayPicker setDate:[NSDate dateWithString:_birthdayField.text format:@"yyyy-MM-dd"]];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    
    [self.tableView reloadData];
}

- (IBAction)saveButtonClicked:(id)sender {
    [self.view endEditing:YES];
    [kProfile setBirthday:_birthdayField.text];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)birthdayPicked:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    _birthdayField.text = [formatter stringFromDate:selectedDate];
}


@end
