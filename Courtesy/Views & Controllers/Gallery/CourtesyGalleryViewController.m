//
//  CourtesyGalleryViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "Math.h"
#import "MoreInfoView.h"
#import "CourtesyCardManager.h"
#import "CourtesyPortraitViewController.h"
#import "CourtesyGalleryViewController.h"
#import "CourtesyCalendarViewController.h"
#import "MiniDateView.h"

static int viewTag = 0x11;

typedef enum : NSUInteger {
    kCourtesyGalleryViewControllerStatusDefault = 0,
    kCourtesyGalleryViewControllerStatusNotLogin = 1,
    kCourtesyGalleryViewControllerStatusNoNetwork = 2,
} CourtesyStarViewControllerStatus;

typedef enum : NSUInteger {
    kCourtesyGalleryDailyCard = 0,
    kCourtesyGalleryGroupCard = 1,
    kCourtesyGalleryLinkCard  = 2,
    kCourtesyGalleryShareCard = 3,
    kCourtesyGalleryMaxIndex  = 4
} CourtesyGalleryMainIndex;

@interface CourtesyGalleryViewController () <JVFloatingDrawerCenterViewController, PDTSimpleCalendarViewDelegate, UIScrollViewDelegate>
@property (nonatomic, assign) CourtesyStarViewControllerStatus currentStatus;
@property (nonatomic, assign) CourtesyGalleryMainIndex currentIndex;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) IBOutlet MiniDateView *dateView;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) NSArray *picturesArray;
@property (nonatomic, strong) Math *onceLinearEquation;

@end

@implementation CourtesyGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Init of navigation bar */
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.translucent = YES;
    navigationBar.backgroundColor = [UIColor clearColor];
    navigationBar.barTintColor = [UIColor clearColor];
    navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.toolbar.translucent = YES;
    self.navigationController.toolbar.barTintColor = [UIColor clearColor];
    self.navigationController.toolbar.tintColor = [UIColor clearColor];
    
    /* Init of background view */
    self.view.backgroundColor = [UIColor blackColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    
    /* Init of Linear Equation */
    MATHPoint pointA = MATHPointMake(0, -50);
    MATHPoint pointB = MATHPointMake(self.view.width, self.view.width - 50);;
    
    self.onceLinearEquation = [Math mathOnceLinearEquationWithPointA:pointA PointB:pointB];
    
    /* Init of background Image */
    self.picturesArray = @[[[UIImage imageNamed:@"street"] imageByBlurRadius:6.0
                                                                   tintColor:[UIColor colorWithWhite:0.11 alpha:0.24]
                                                                    tintMode:kCGBlendModeNormal
                                                                  saturation:1.2
                                                                   maskImage:nil],
                           [[UIImage imageNamed:@"street"] imageByBlurRadius:12.0
                                                                   tintColor:[UIColor colorWithWhite:0.11 alpha:0.36]
                                                                    tintMode:kCGBlendModeNormal
                                                                  saturation:1.2
                                                                   maskImage:nil],
                           [[UIImage imageNamed:@"street"] imageByBlurRadius:18.0
                                                                   tintColor:[UIColor colorWithWhite:0.11 alpha:0.48]
                                                                    tintMode:kCGBlendModeNormal
                                                                  saturation:1.2
                                                                   maskImage:nil],
                           [[UIImage imageNamed:@"street"] imageByBlurRadius:18.0
                                                                   tintColor:[UIColor colorWithWhite:0.11 alpha:0.64]
                                                                    tintMode:kCGBlendModeNormal
                                                                  saturation:1.2
                                                                   maskImage:nil],
                           ];
    
    /* Init of date view */
    self.dateView.tintColor = [UIColor whiteColor];
    self.dateView.userInteractionEnabled = YES;
    [self.dateView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(actionDateViewTapped:)]];
    
    /* Init of view index */
    self.currentIndex = kCourtesyGalleryDailyCard;
}


- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    /* Init of main scroll view */
    CGFloat height = self.view.bounds.size.height;
    CGFloat width  = self.view.bounds.size.width;
    
    self.mainScrollView.delegate = self;
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.backgroundColor = [UIColor blackColor];
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.bounces = NO;
    self.mainScrollView.contentSize = CGSizeMake(kCourtesyGalleryMaxIndex * width, height);
    
    // Init More Info Views.
    for (int i = 0; i < kCourtesyGalleryMaxIndex; i++) {
        MoreInfoView *show     = [[MoreInfoView alloc] initWithFrame:CGRectMake(i * width, 0, width, height)];
        show.imageView.image   = self.picturesArray[i];
        show.layer.borderWidth = 0.25f;
        show.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.25f].CGColor;
        show.tag               = viewTag + i;
        
        // Init Card Container View
        UIView *cardContainerView = [[UIView alloc] init];
        cardContainerView.layer.cornerRadius = 10.0;
        cardContainerView.layer.borderWidth = 1.0;
        cardContainerView.layer.borderColor = [UIColor colorWithWhite:0.24 alpha:0.64].CGColor;
        cardContainerView.backgroundColor = [UIColor colorWithWhite:0.11 alpha:0.64];
        [show addSubview:cardContainerView];
        [cardContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(show.mas_left).with.offset(24);
            make.right.equalTo(show.mas_right).with.offset(-24);
            make.top.equalTo(show.mas_top).with.offset(36);
            make.bottom.equalTo(show.mas_bottom).with.offset(-148);
        }];
        
//        typedef enum : NSUInteger {
//            kCourtesyGalleryDailyCard = 0,
//            kCourtesyGalleryGroupCard = 1,
//            kCourtesyGalleryLinkCard  = 2,
//            kCourtesyGalleryShareCard = 3,
//            kCourtesyGalleryMaxIndex  = 4
//        } CourtesyGalleryMainIndex;
        
        if (i == kCourtesyGalleryDailyCard)
        {
            
        }
        else if (i == kCourtesyGalleryGroupCard)
        {
            
        }
        else if (i == kCourtesyGalleryLinkCard)
        {
            
        }
        else if (i == kCourtesyGalleryShareCard)
        {
            
        }
        
        [self.mainScrollView addSubview:show];
    }
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
    [[CourtesyCardManager sharedManager] composeNewCardWithViewController:self];
}

- (IBAction)actionSearchTapped:(id)sender {
    
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat X = scrollView.contentOffset.x;
    for (int i = 0; i < kCourtesyGalleryMaxIndex; i++) {
        MoreInfoView *show = [scrollView viewWithTag:viewTag + i];
        show.imageView.x   = _onceLinearEquation.k * (X - i * self.view.width) + _onceLinearEquation.b;
    }
}

@end
