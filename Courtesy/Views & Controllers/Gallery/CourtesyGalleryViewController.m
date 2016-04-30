//
//  CourtesyGalleryViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyCardManager.h"
#import "CourtesyCommonCardView.h"
#import "CourtesyDefaultCoverView.h"
#import "CourtesyPortraitViewController.h"
#import "CourtesyGalleryViewController.h"
#import "CourtesyCalendarViewController.h"
#import "UIColor+FlatColors.h"
#import "MiniDateView.h"

typedef enum : NSUInteger {
    kCourtesyGalleryViewControllerStatusDefault = 0,
    kCourtesyGalleryViewControllerStatusNotLogin = 1,
    kCourtesyGalleryViewControllerStatusNoNetwork = 2,
} CourtesyStarViewControllerStatus;

typedef enum : NSUInteger {
    kCourtesyGalleryDailyCard = 0,
    kCourtesyGalleryGroupCard = 1,
    kCourtesyGalleryLinkCard  = 2,
    kCourtesyGalleryShareCard = 3
} CourtesyGalleryMainIndex;

@interface CourtesyGalleryViewController () <JVFloatingDrawerCenterViewController, PDTSimpleCalendarViewDelegate>
@property (nonatomic, assign) CourtesyStarViewControllerStatus currentStatus;
@property (nonatomic, assign) CourtesyGalleryMainIndex currentIndex;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) IBOutlet MiniDateView *dateView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end

@implementation CourtesyGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Init of navigation bar */
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.translucent = YES;
    navigationBar.barTintColor = [UIColor clearColor];
    navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.toolbar.translucent = YES;
    self.navigationController.toolbar.barTintColor = [UIColor clearColor];
    self.navigationController.toolbar.tintColor = [UIColor whiteColor];

    /* Init of background view */
    self.view.backgroundColor = [UIColor blackColor];
    self.backgroundImage.image = [[UIImage imageNamed:@"street"] imageByBlurRadius:20
                                                                         tintColor:[UIColor colorWithWhite:0.11 alpha:0.72]
                                                                          tintMode:kCGBlendModeNormal
                                                                        saturation:1.2
                                                                         maskImage:nil];
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    
    /* Init of date view */
    self.dateView.tintColor = [UIColor whiteColor];
    self.dateView.userInteractionEnabled = YES;
    [self.dateView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(actionDateViewTapped:)]];
    
    /* Init of swipeable view */
    ZLSwipeableView *swipeableView = [[ZLSwipeableView alloc] initWithFrame:CGRectZero];
    swipeableView.numberOfActiveViews = 4;
    swipeableView.numberOfHistoryItem = 20;
    // Required Data Source
    swipeableView.dataSource = self;
    // Optional Delegate
    swipeableView.delegate = self;
    swipeableView.allowedDirection = ZLSwipeableViewDirectionHorizontal;
    swipeableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:swipeableView];
    self.swipeableView = swipeableView;
    
    /* Init of view index */
    self.currentIndex = kCourtesyGalleryDailyCard;
}

- (void)viewDidLayoutSubviews {
    [self.swipeableView loadViewsIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.swipeableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(50, 50, 160, 50));
    }];
}

#pragma mark - Getter / Setter

- (NSDate *)selectedDate {
    if (!_selectedDate) {
        _selectedDate = [NSDate date];
    }
    return _selectedDate;
}

#pragma mark - Actions

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionAddButtonTapped:(id)sender {
    [[CourtesyCardManager sharedManager] composeNewCardWithViewController:self];
}

- (IBAction)actionSearchTapped:(id)sender {
    
}

- (IBAction)actionRewindTapped:(id)sender {
    [self.swipeableView rewind];
}

- (void)actionDateViewTapped:(UITapGestureRecognizer *)sender {
    CourtesyCalendarViewController *calendarViewController = [[CourtesyCalendarViewController alloc] init];
    calendarViewController.lastDate = [NSDate date];
    calendarViewController.selectedDate = self.selectedDate;
    calendarViewController.weekdayHeaderEnabled = NO;
    [calendarViewController setDelegate:self];
    CourtesyPortraitViewController *vc = [[CourtesyPortraitViewController alloc] initWithRootViewController:calendarViewController];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - ZLSwipeableViewDelegate

- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeView:(UIView *)view
          inDirection:(ZLSwipeableViewDirection)direction {
    
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
       didCancelSwipe:(UIView *)view {

}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
  didStartSwipingView:(UIView *)view
           atLocation:(CGPoint)location {

}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
          swipingView:(UIView *)view
           atLocation:(CGPoint)location
          translation:(CGPoint)translation {

}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
    didEndSwipingView:(UIView *)view
           atLocation:(CGPoint)location {

}

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    if (_currentIndex == kCourtesyGalleryDailyCard) {
        _currentIndex++;
        CourtesyDefaultCoverView *view = [[CourtesyDefaultCoverView alloc] initWithFrame:swipeableView.bounds];
        view.backgroundColor = [self colorForName:@"Clouds"];
        return view;
    } else if (_currentIndex == kCourtesyGalleryGroupCard) {
        _currentIndex++;
        CourtesyCommonCardView *view = [[CourtesyCommonCardView alloc] initWithFrame:swipeableView.bounds];
        view.backgroundColor = [self colorForName:@"Clouds"];
        return view;
    } else if (_currentIndex == kCourtesyGalleryLinkCard) {
        _currentIndex++;
        CourtesyCommonCardView *view = [[CourtesyCommonCardView alloc] initWithFrame:swipeableView.bounds];
        view.backgroundColor = [self colorForName:@"Clouds"];
        return view;
    } else if (_currentIndex == kCourtesyGalleryShareCard) {
        _currentIndex++;
        CourtesyCommonCardView *view = [[CourtesyCommonCardView alloc] initWithFrame:swipeableView.bounds];
        view.backgroundColor = [self colorForName:@"Clouds"];
        return view;
    }
    return nil;
}

- (UIColor *)colorForName:(NSString *)name {
    return [[UIColor class] performSelector:@selector(flatCloudsColor)];
}

- (UIView *)previousViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    [self.view makeToast:@"已经是第一张卡片了"
                duration:kStatusBarNotificationTime
                position:CSToastPositionCenter];
    return nil;
}

#pragma mark - JVFloatingDrawerCenterViewController

- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide {
    if (drawerSide == JVFloatingDrawerSideLeft) return YES;
    return NO;
}

#pragma mark - PDTSimpleCalendarViewDelegate

- (void)simpleCalendarViewController:(CourtesyCalendarViewController *)controller
                       didSelectDate:(NSDate *)date {
    [controller close:self];
    self.selectedDate = date;
    self.dateView.date = date;
    [self.dateView setNeedsDisplay];
}

@end
