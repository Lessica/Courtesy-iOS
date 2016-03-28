//
//  CourtesyMainTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyMyStarViewController.h"
#import "UIColor+FlatColors.h"
#import "CourtesyStarredCardView.h"

typedef enum : NSUInteger {
    kCourtesyStarViewControllerStatusDefault = 0,
    kCourtesyStarViewControllerStatusNotLogin = 1,
    kCourtesyStarViewControllerStatusNoNetwork = 2,
} CourtesyStarViewControllerStatus;

@interface CourtesyMyStarViewController () <JVFloatingDrawerCenterViewController>
@property (nonatomic, assign) CourtesyStarViewControllerStatus currentStatus;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic) NSUInteger colorIndex;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end

@implementation CourtesyMyStarViewController

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
    self.currentStatus = kCourtesyStarViewControllerStatusDefault;
    if (self.currentStatus == kCourtesyStarViewControllerStatusDefault) {
        self.colorIndex = 0;
        self.colors = @[
            @"Clouds",
            @"Clouds",
            @"Clouds",
            @"Clouds"
        ];

        ZLSwipeableView *swipeableView = [[ZLSwipeableView alloc] initWithFrame:CGRectZero];
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



#pragma mark - Actions

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionTrashButtonTapped:(id)sender {

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
    if (self.colorIndex >= self.colors.count) {
        self.colorIndex = 0;
    }

    CourtesyStarredCardView *view = [[CourtesyStarredCardView alloc] initWithFrame:swipeableView.bounds];
    view.backgroundColor = [self colorForName:self.colors[self.colorIndex]];
    self.colorIndex++;

    return view;
}

- (UIColor *)colorForName:(NSString *)name {
    NSString *sanitizedName = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *selectorString = [NSString stringWithFormat:@"flat%@Color", sanitizedName];
    Class colorClass = [UIColor class];
    return [colorClass performSelector:NSSelectorFromString(selectorString)];
}

#pragma mark - JVFloatingDrawerCenterViewController

- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide {
    if (drawerSide == JVFloatingDrawerSideLeft) return YES;
    return NO;
}

@end
