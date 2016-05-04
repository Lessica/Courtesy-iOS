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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"长图";
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
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.previewImages.count) {
        return tableView.frame.size.width * 0.5625;
    }
    return 0;
}

@end
