//
//  CourtesyProfileGenderTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/26/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyProfileGenderTableViewController.h"

@interface CourtesyProfileGenderTableViewController ()

@end

@implementation CourtesyProfileGenderTableViewController {
    NSIndexPath *lastIndexPath;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    lastIndexPath = [NSIndexPath indexPathForItem:kProfile.gender inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:lastIndexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger newRow = [indexPath row];
    NSUInteger oldRow = [lastIndexPath row];
    
    if (newRow != oldRow) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:
                                    indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:
                                    lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        lastIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)saveButtonClicked:(id)sender {
    [kProfile setGender:lastIndexPath.row];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
