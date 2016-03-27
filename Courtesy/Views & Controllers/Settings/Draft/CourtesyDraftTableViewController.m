//
//  CourtesyDraftTableViewController.m
//  Courtesy
//
//  Created by Zheng on 3/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyDraftTableViewController.h"
#import "CourtesyDraftTableViewCell.h"
#import "CourtesyCardManager.h"

static NSString * const kCourtesyDraftTableViewCellReuseIdentifier = @"CourtesyDraftTableViewCellReuseIdentifier";

@interface CourtesyDraftTableViewController ()
@property (nonatomic, assign) NSInteger draftCount;
@property (nonatomic, strong) NSMutableArray <CourtesyCardModel *> *cardArray;

@end

@implementation CourtesyDraftTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadCards];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)reloadCards {
    self.cardArray = [[CourtesyCardManager sharedManager] cardDraftArray];
    self.draftCount = self.cardArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"编辑过但尚未发布的卡片将会保存在这里";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.draftCount;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 102;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CourtesyDraftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyDraftTableViewCellReuseIdentifier forIndexPath:indexPath];
        cell.card = [self.cardArray objectAtIndex:indexPath.row];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        CourtesyCardModel *card = [self.cardArray objectAtIndex:indexPath.row];
        card.is_editable = YES;
        [[CourtesyCardManager sharedManager] editCard:card withViewController:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES; // Always allow in draft box
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            // Delete Card Model
            CourtesyCardModel *card = [self.cardArray objectAtIndex:indexPath.row];
            [[CourtesyCardManager sharedManager] deleteCardInDraft:card];
            [self.cardArray removeObject:card];
            [self reloadCards];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }
    }
}

@end
