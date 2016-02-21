//
//  CourtesyLeftDrawerTableViewController.m
//  Courtesy
//
//  Created by i_82 on 2016-02-20.
//  Copyright (c) 2016 82Flex. All rights reserved.
//

#import "CourtesyLeftDrawerTableViewController.h"
#import "CourtesyLeftDrawerTableViewCell.h"
#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"

enum {
    kJVDrawerSettingsIndex    = 0,
    kJVGitHubProjectPageIndex = 1
};

static const CGFloat kJVTableViewTopInset = 80.0;
static NSString * const kJVDrawerCellReuseIdentifier = @"JVDrawerCellReuseIdentifier";

@interface CourtesyLeftDrawerTableViewController ()

@end

@implementation CourtesyLeftDrawerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(kJVTableViewTopInset, 0.0, 0.0, 0.0);
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:kJVDrawerSettingsIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CourtesyLeftDrawerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJVDrawerCellReuseIdentifier forIndexPath:indexPath];
    
    if(indexPath.row == kJVDrawerSettingsIndex) {
        cell.titleText = @"动画设置";
        cell.iconImage = [UIImage imageNamed:@"665-gear"];
        
    } else {
        cell.titleText = @"Github Page";
        cell.iconImage = [UIImage imageNamed:@"488-github"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *destinationViewController = nil;

    if(indexPath.row == kJVDrawerSettingsIndex) {
        destinationViewController = [[AppDelegate globalDelegate] drawerSettingsViewController];
    } else {
        destinationViewController = [[AppDelegate globalDelegate] githubViewController];
    }
    
    [[[AppDelegate globalDelegate] drawerViewController] setCenterViewController:destinationViewController];
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
