//
//  CourtesyDraftTableViewController.m
//  Courtesy
//
//  Created by Zheng on 3/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyDraftTableViewController.h"
#import "CourtesyAlbumTableViewCell.h"
#import "CourtesyCardManager.h"
#import "CourtesyCardPreviewGenerator.h"
#import "CourtesyCardPublishQueue.h"
#import "CourtesyDraftTableViewHeaderView.h"
#import "CourtesyCardListRequestModel.h"
#import <MJRefresh/MJRefresh.h>

static NSString * const kCourtesyDraftTableViewCellReuseIdentifier = @"CourtesyDraftTableViewCellReuseIdentifier";

@interface CourtesyDraftTableViewController () <UIViewControllerPreviewingDelegate, CourtesyCardListRequestDelegate>
@property (nonatomic, strong) CourtesyDraftTableViewHeaderView *headerView;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) double lastUpdated;
@property (weak, nonatomic) IBOutlet UINavigationItem *outboxTabItem;

@end

@implementation CourtesyDraftTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发件箱";
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        // 注册 3D Touch
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    self.tableView.allowsSelectionDuringEditing = NO;
    
    // 设置底部 Tabbar 边距
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    
    /* Init of header view */
    UIView *headerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 180)];
    CourtesyDraftTableViewHeaderView *headerView = [[CourtesyDraftTableViewHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 148)];
    
    /* Init of pencil edit */
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [editButton setTarget:self action:@selector(composeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [editButton setImage:[[UIImage imageNamed:@"669-pencil-edit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    headerView.editButton = editButton;
    [headerView addSubview:editButton];
    
    [headerContainerView addSubview:headerView];
    self.headerView = headerView;
    self.tableView.tableHeaderView = headerContainerView;
    
    /* Init of MJRefresh */
    MJRefreshNormalHeader *normalHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadTableView)];
    [normalHeader setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [normalHeader setTitle:@"释放更新" forState:MJRefreshStatePulling];
    [normalHeader setTitle:@"加载中……" forState:MJRefreshStateRefreshing];
    normalHeader.stateLabel.font = [UIFont systemFontOfSize:12.0];
    normalHeader.stateLabel.textColor = [UIColor lightGrayColor];
    normalHeader.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.0];
    normalHeader.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
    [normalHeader beginRefreshing];
    self.tableView.mj_header = normalHeader;
    
    // 注册接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLocalNotification:)
                                                 name:kCourtesyNotificationInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCardQueueUpdated:)
                                                 name:kCourtesyCardComposeQueueUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCardStatusUpdated:)
                                                 name:kCourtesyCardStatusUpdated object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification

- (void)didReceiveCardQueueUpdated:(NSNotification *)notification {
    CourtesyCardModel *taskCard = notification.object;
    for (CourtesyAlbumTableViewCell *cell in self.tableView.visibleCells) {
        if (cell.card == taskCard) {
            [cell notifyUpdateProgress];
        }
    }
}

- (void)didReceiveCardStatusUpdated:(NSNotification *)notification {
    CourtesyCardModel *statusCard = notification.object;
    for (CourtesyAlbumTableViewCell *cell in self.tableView.visibleCells) {
        if (cell.card == statusCard) {
            [cell notifyUpdateStatus];
        }
    }
}

- (void)didReceiveLocalNotification:(NSNotification *)notification {
    if (!notification.userInfo || ![notification.userInfo hasKey:@"action"]) {
        return;
    }
    NSString *action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqualToString:kCourtesyActionLogin]) {
        [_headerView updateAccountInfo];
    }
    else if ([action isEqualToString:kCourtesyActionProfileEdited]) {
        [_headerView updateAccountInfo];
    }
    else if ([action isEqualToString:kCourtesyActionLogout])
    {
        [[CourtesyCardManager sharedManager] clearCards];
        [self.tableView reloadData];
        [_headerView updateAccountInfo];
    }
    else if ([action isEqualToString:kCourtesyActionFetchSucceed])
    {
        [[CourtesyCardManager sharedManager] clearCards];
        [self.tableView reloadData];
        [_headerView updateAccountInfo];
    }
}

#pragma mark - 刷新列表

- (void)reloadTableView {
    if (_isRefreshing ||
        _lastUpdated + 5 > [[NSDate date] timeIntervalSince1970] ||
        ![sharedSettings hasLogin]
        )
    {
        [self.tableView.mj_header endRefreshing];
        return;
    }
    CourtesyCardListRequestModel *listRequest = [[CourtesyCardListRequestModel alloc] init];
    listRequest.delegate = self;
    listRequest.user_id = kAccount.user_id;
    listRequest.from = 0;
    listRequest.to = 100;
    listRequest.history = NO;
    _isRefreshing = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [listRequest sendAsyncListRequest];
    });
}

#pragma mark - CourtesyCardListRequestDelegate

- (void)cardListRequestSucceed:(CourtesyCardListRequestModel *)model {
    _isRefreshing = NO;
    _lastUpdated = [[NSDate date] timeIntervalSince1970];
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

- (void)cardListRequestFailed:(CourtesyCardListRequestModel *)model withError:(NSError *)error {
    dispatch_async_on_main_queue(^{
        [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"加载失败 - %@", [error localizedDescription]]
                                   dismissAfter:kStatusBarNotificationTime
                                      styleName:JDStatusBarStyleError];
    });
    _isRefreshing = NO;
    _lastUpdated = [[NSDate date] timeIntervalSince1970];
    [self.tableView.mj_header endRefreshing];
}

#pragma mark - 按钮事件

- (void)composeButtonTapped:(id)sender {
    [[CourtesyCardManager sharedManager] composeNewCardWithViewController:self];
}

#pragma mark - Card Management

- (CourtesyCardManager *)cardManager {
    return [CourtesyCardManager sharedManager];
}

- (NSMutableArray <CourtesyCardModel *> *)cardArray {
    return self.cardManager.cardDraftArray;
}

- (NSInteger)draftCount {
    NSUInteger count = self.cardArray.count;
    _headerView.cardCount = count;
    return count;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.draftCount;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 128;
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
            if (card.hasPublished) {
                if (card.is_banned == NO) {
                    __weak typeof(self) weakSelf = self;
                    UITableViewRowAction *publicAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"设为隐藏" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                        [weakSelf.cardManager publicCardInDraft:card];
                        [tableView setEditing:NO animated:YES];
                    }];
                    return @[publicAction];
                } else {
                    __weak typeof(self) weakSelf = self;
                    UITableViewRowAction *restoreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"设为公开" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                        [weakSelf.cardManager restoreCardInDraft:card];
                        [tableView setEditing:NO animated:YES];
                    }];
                    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                        [weakSelf.cardManager deleteCardInDraft:card];
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }];
                    return @[deleteAction, restoreAction];
                }
            } else {
                __weak typeof(self) weakSelf = self;
                UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                    [weakSelf.cardManager deleteCardInDraft:card];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }];
                return @[deleteAction];
            }
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CourtesyAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyDraftTableViewCellReuseIdentifier forIndexPath:indexPath];
        cell.card = [self.cardArray objectAtIndex:indexPath.row];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        CourtesyCardModel *card = [self.cardArray objectAtIndex:indexPath.row];
        CourtesyCardPublishQueue *queue = [CourtesyCardPublishQueue sharedQueue];
        if ([queue publishTaskInPublishQueueWithCard:card]) {
            return;
        }
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
        [self.cardManager exchangeCardAtIndex:sourceIndexPath.row withCardAtIndex:destinationIndexPath.row];
    }
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    if (self.tableView.isEditing) {
        return nil;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    if (!indexPath) {
        return nil;
    }
    CourtesyAlbumTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        return nil;
    }
    CourtesyCardModel *card = cell.card;
    CourtesyCardPublishQueue *queue = [CourtesyCardPublishQueue sharedQueue];
    if ([queue publishTaskInPublishQueueWithCard:card]) {
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

#pragma mark - Memory

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
