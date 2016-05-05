//
//  CourtesyLongImageTableViewController.m
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyLongImageTableViewController.h"
#import "CourtesyLongImageTableViewCell.h"
#import "CourtesyCardPreviewStyleManager.h"

static NSString * const kCourtesyLongImageTableViewCellReuseIdentifier = @"CourtesyLongImageTableViewCellReuseIdentifier";

@interface CourtesyLongImageTableViewController ()

@end

@implementation CourtesyLongImageTableViewController

- (NSArray <NSString *> *)previewNames {
    return [[CourtesyCardPreviewStyleManager sharedManager] previewNames];
}

- (NSArray<UIImage *> *)previewImages {
    return [[CourtesyCardPreviewStyleManager sharedManager] previewImages];
}

- (NSArray<UIImage *> *)previewCheckmarks {
    return [[CourtesyCardPreviewStyleManager sharedManager] previewCheckmarks];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"长图";
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    // 设置底部 Tabbar 边距
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CourtesyLongImageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[sharedSettings preferredPreviewStyleType]]];
    [cell setPreviewStyleSelected:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section < self.previewNames.count) {
        for (int index = 0; index < self.previewNames.count; index++) {
            CourtesyLongImageTableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
            [cell setPreviewStyleSelected:NO];
        }
        CourtesyLongImageTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setPreviewStyleSelected:YES];
        [sharedSettings setPreferredPreviewStyleType:indexPath.section];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.previewImages.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section < self.previewNames.count) {
//        return [self.previewNames objectAtIndex:section];
//    }
//    return nil;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.previewImages.count) {
        CourtesyLongImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyLongImageTableViewCellReuseIdentifier forIndexPath:indexPath];
        [cell setPreviewImage:[self.previewImages objectAtIndex:indexPath.section]];
        [cell setPreviewCheckmark:[self.previewCheckmarks objectAtIndex:indexPath.section]];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.previewImages.count) {
        CGSize size = self.previewImages[indexPath.section].size;
        CGFloat ratio = size.height / size.width;
        return tableView.frame.size.width * ratio;
    }
    return 0;
}

@end
