//
//  CourtesyLongImageTableViewController.m
//  Courtesy
//
//  Created by Zheng on 5/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyLongImageTableViewController.h"
#import "CourtesyLongImageTableViewCell.h"

static NSString * const kCourtesyLongImageTableViewCellReuseIdentifier = @"CourtesyLongImageTableViewCellReuseIdentifier";

@interface CourtesyLongImageTableViewController ()
@property (nonatomic, strong) NSArray<NSString *> *previewNames;
@property (nonatomic, strong) NSArray<UIImage *> *previewImages;

@end

@implementation CourtesyLongImageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _previewNames = @[
                      @"锤子便签风格",
                      // More Long Image Names
                      
                      ];
    _previewImages = @[
                       [UIImage imageNamed:@"default-preview"],
                       // More Long Image
                       ];
    
    self.title = @"长图";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 设置
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _previewImages.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < _previewNames.count) {
        return [_previewNames objectAtIndex:section];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < _previewImages.count) {
        CourtesyLongImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyLongImageTableViewCellReuseIdentifier forIndexPath:indexPath];
        [cell setPreviewImage:[_previewImages objectAtIndex:indexPath.section]];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < _previewImages.count) {
        UIImage *previewImage = [_previewImages objectAtIndex:indexPath.section];
        CGFloat height = previewImage.size.height;
        return height + 16;
    }
    return 0;
}

@end
