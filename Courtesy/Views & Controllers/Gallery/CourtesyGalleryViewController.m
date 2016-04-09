//
//  CourtesyGalleryViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyCardManager.h"
#import "CourtesyStarredCardView.h"
#import "CourtesyPortraitViewController.h"
#import "CourtesyLoginRegisterViewController.h"
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
    kCourtesyGalleryLinkCard = 1,
} CourtesyGalleryMainIndex;

@interface CourtesyGalleryViewController () <JVFloatingDrawerCenterViewController, PDTSimpleCalendarViewDelegate>
@property (nonatomic, assign) CourtesyStarViewControllerStatus currentStatus;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) IBOutlet MiniDateView *dateView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end

@implementation CourtesyGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.toolbar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.toolbar.barTintColor = [UIColor clearColor];
    self.navigationController.toolbar.tintColor = [UIColor whiteColor];

    self.view.backgroundColor = [UIColor blackColor];
    self.backgroundImage.image = [[UIImage imageNamed:@"street"] imageByBlurRadius:20 tintColor:[UIColor colorWithWhite:0.11 alpha:0.72] tintMode:kCGBlendModeNormal saturation:1.2 maskImage:nil];
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout =  UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    
    self.dateView.tintColor = [UIColor whiteColor];
    self.dateView.userInteractionEnabled = YES;
    [self.dateView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDateViewTapped:)]];
    
    // Debug
    self.currentStatus = kCourtesyGalleryViewControllerStatusDefault;
    if (self.currentStatus == kCourtesyGalleryViewControllerStatusDefault) {
        ZLSwipeableView *swipeableView = [[ZLSwipeableView alloc] initWithFrame:CGRectZero];
        swipeableView.numberOfActiveViews = 4;
        swipeableView.numberOfHistoryItem = 20;
        self.swipeableView = swipeableView;
        [self.view addSubview:self.swipeableView];
        // Required Data Source
        self.swipeableView.dataSource = self;
        // Optional Delegate
        self.swipeableView.delegate = self;
        self.swipeableView.allowedDirection = ZLSwipeableViewDirectionHorizontal;
        self.swipeableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.swipeableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(50, 50, 160, 50));
        }];
    }
}

- (void)viewDidLayoutSubviews {
    [self.swipeableView loadViewsIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    if (![sharedSettings hasLogin]) { // 未登录
        CourtesyLoginRegisterViewController *vc = [CourtesyLoginRegisterViewController new];
        CourtesyPortraitViewController *navc = [[CourtesyPortraitViewController alloc] initWithRootViewController:vc];
        [self presentViewController:navc animated:YES completion:nil];
        return;
    }
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
    CourtesyStarredCardView *view = [[CourtesyStarredCardView alloc] initWithFrame:swipeableView.bounds];
    view.backgroundColor = [self colorForName:@"Clouds"];

    return view;
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
//    UIView *view = [self nextViewForSwipeableView:swipeableView];
//    [self applyRandomTransform:view];
//    return view;

/*
- (void)applyRandomTransform:(UIView *)view {
    CGFloat width = self.swipeableView.bounds.size.width;
    CGFloat height = self.swipeableView.bounds.size.height;
    CGFloat distance = MAX(width, height);
    
    CGAffineTransform transform = CGAffineTransformMakeRotation([self randomRadian]);
    transform = CGAffineTransformTranslate(transform, distance, 0);
    transform = CGAffineTransformRotate(transform, [self randomRadian]);
    view.transform = transform;
}

- (CGFloat)randomRadian {
    return (random() % 360) * (M_PI / 180.0);
}
*/
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
