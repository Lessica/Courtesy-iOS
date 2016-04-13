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
#import "CourtesyCardPreviewGenerator.h"
#import "CourtesyCardPublishQueue.h"

static NSString * const kCourtesyDraftTableViewCellReuseIdentifier = @"CourtesyDraftTableViewCellReuseIdentifier";

@interface CourtesyDraftTableViewController () <UIViewControllerPreviewingDelegate>

@end

@implementation CourtesyDraftTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        // 注册 3D Touch
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CourtesyCardManager *)cardManager {
    return [CourtesyCardManager sharedManager];
}

- (NSMutableArray <CourtesyCardModel *> *)cardArray {
    return self.cardManager.cardDraftArray;
}

- (NSInteger)draftCount {
    return self.cardArray.count;
}

#pragma mark - Table view data source

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

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        __block CourtesyCardModel *card = [self.cardArray objectAtIndex:indexPath.row];
        __block CourtesyCardPublishQueue *queue = [CourtesyCardPublishQueue sharedQueue];
        if ([queue publishTaskInPublishQueueWithCard:card]) {
            UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消上传" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
                [queue removeCardPublishTask:card];
                [tableView setEditing:NO animated:YES];
            }];
            editAction.backgroundColor = [UIColor lightGrayColor];
            return @[editAction];
        } else {
            __weak typeof(self) weakSelf = self;
            UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                [weakSelf.cardManager deleteCardInDraft:card];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            return @[deleteAction];
        }
    }
    return nil;
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
        [self.cardManager editCard:card withViewController:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES; // Always allow in draft box
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES; // Always allow in draft box
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == destinationIndexPath.section && sourceIndexPath.section == 0) {
        // [self.cardArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        [self.cardManager exchangeCardAtIndex:sourceIndexPath.row withCardAtIndex:destinationIndexPath.row];
    }
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    if (!indexPath) {
        return nil;
    }
    CourtesyDraftTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        return nil;
    }
    cell.card.is_editable = YES;
    UIViewController *previewViewController = [self.cardManager prepareCard:cell.card withViewController:self];
    previewViewController.preferredContentSize = CGSizeMake(0.0, 0.0);
    previewingContext.sourceRect = cell.frame;
    return previewViewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController *)viewControllerToCommit {
    [self.cardManager commitCardComposeViewController:viewControllerToCommit withViewController:self];
}

@end
