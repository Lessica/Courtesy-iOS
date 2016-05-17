//
//  CourtesyGalleryViewController.m
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "Math.h"
#import "UMSocial.h"
#import "AppDelegate.h"
#import "AppStorage.h"
#import "MoreInfoView.h"
#import "MiniDateView.h"
#import "FCFileManager.h"
#import "NSDate+Compare.h"
#import "CourtesyCardManager.h"
#import "JTSImageViewController.h"
#import "CourtesyGalleryDailyCardView.h"
#import "CourtesyGalleryLinkCardView.h"
#import "CourtesyGalleryDailyRequestModel.h"
#import "CourtesyPortraitViewController.h"
#import "CourtesyGalleryViewController.h"
#import "CourtesyCalendarViewController.h"
#import "CourtesyGalleryLinkWebViewController.h"

#define kCourtesyCardPreviewCachePrefix @"kCourtesyCardPreviewCachePrefix-%@-%@"

static int viewTag = 0x11;

typedef enum : NSUInteger {
    kCourtesyGalleryViewControllerStatusNone      = 0,
    kCourtesyGalleryViewControllerStatusPending   = 1,
    kCourtesyGalleryViewControllerStatusDefault   = 2,
    kCourtesyGalleryViewControllerStatusNoNetwork = 3,
} CourtesyStarViewControllerStatus;

typedef enum : NSUInteger {
    kCourtesyGalleryDailyCard = 0,
//    kCourtesyGalleryGroupCard = 1,
    kCourtesyGalleryLinkCard  = 1,
    kCourtesyGalleryMaxIndex  = 2
} CourtesyGalleryMainIndex;

@interface CourtesyGalleryViewController ()
<
JVFloatingDrawerCenterViewController,
PDTSimpleCalendarViewDelegate,
UIScrollViewDelegate,
CourtesyGalleryDailyRequestDelegate,
JTSImageViewControllerInteractionsDelegate,
JTSImageViewControllerDismissalDelegate,
UMSocialUIDelegate
>

@property (nonatomic, assign) CourtesyStarViewControllerStatus currentStatus;
@property (nonatomic, assign) CourtesyGalleryMainIndex currentIndex;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) IBOutlet MiniDateView *dateView;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) NSArray *picturesArray;
@property (nonatomic, strong) Math *onceLinearEquation;
@property (nonatomic, strong) CourtesyGalleryDailyCardView *dailyCardView;
@property (nonatomic, strong) CourtesyGalleryLinkCardView *linkCardView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation CourtesyGalleryViewController

- (CGFloat)getTopMargin {
    // 状态栏(statusbar)
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    
    // 导航栏（navigationbar）
    CGRect rectNav = self.navigationController.navigationBar.frame;
    
    return rectStatus.size.height + rectNav.size.height;
}

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
    self.picturesArray =
  @[
    [[UIImage imageNamed:@"street"] imageByBlurRadius:6.0
                                            tintColor:[UIColor colorWithWhite:0.11 alpha:0.24]
                                             tintMode:kCGBlendModeNormal
                                           saturation:1.2
                                            maskImage:nil],
    [[UIImage imageNamed:@"street"] imageByBlurRadius:12.0
                                            tintColor:[UIColor colorWithWhite:0.11 alpha:0.36]
                                             tintMode:kCGBlendModeNormal
                                           saturation:1.2
                                            maskImage:nil],
//    [[UIImage imageNamed:@"street"] imageByBlurRadius:18.0
//                                            tintColor:[UIColor colorWithWhite:0.11 alpha:0.48]
//                                             tintMode:kCGBlendModeNormal
//                                           saturation:1.2
//                                            maskImage:nil],
    ];
    
    /* Init of date view */
    self.dateView.tintColor = [UIColor whiteColor];
    self.dateView.userInteractionEnabled = YES;
    [self.dateView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(actionDateViewTapped:)]];
    
    /* Init of view index */
    self.currentIndex = kCourtesyGalleryDailyCard;
    
    /* Init of main scroll view */
    CGFloat height = self.view.bounds.size.height - [self getTopMargin];
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
        UIView *cardContainerView = [[UIView alloc] initWithFrame:CGRectMake(24, 24, width - 48, height - 184)];
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
        
        if (i == kCourtesyGalleryDailyCard)
        {
            CourtesyGalleryDailyCardView *dailyCardView = [[CourtesyGalleryDailyCardView alloc] initWithFrame:cardContainerView.bounds];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dailyCardPreview:)];
            dailyCardView.userInteractionEnabled = YES;
            [dailyCardView addGestureRecognizer:tapGesture];
            [cardContainerView addSubview:dailyCardView];
            self.dailyCardView = dailyCardView;
        }
//        else if (i == kCourtesyGalleryGroupCard)
//        {
//            
//        }
        else if (i == kCourtesyGalleryLinkCard)
        {
            CourtesyGalleryLinkCardView *linkCardView = [[CourtesyGalleryLinkCardView alloc] initWithFrame:cardContainerView.bounds];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkCardPreview:)];
            linkCardView.userInteractionEnabled = YES;
            [linkCardView addGestureRecognizer:tapGesture];
            [cardContainerView addSubview:linkCardView];
            self.linkCardView = linkCardView;
        }
        
        [self.mainScrollView addSubview:show];
    }
    _pageControl.numberOfPages = kCourtesyGalleryMaxIndex;
    _pageControl.currentPage = 0;
    [_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}


- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    // 发起加载请求
    if (self.currentStatus == kCourtesyGalleryViewControllerStatusNone) {
        self.currentStatus = kCourtesyGalleryViewControllerStatusPending;
        CourtesyGalleryDailyRequestModel *dailyRequest = [[CourtesyGalleryDailyRequestModel alloc] initWithDelegate:self];
        dailyRequest.s_date = [self.dateFormatter stringFromDate:self.selectedDate];
        [self.navigationController.view makeToastActivity:CSToastPositionCenter];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [dailyRequest sendRequest];
        });
    }
}

#pragma mark - CourtesyGalleryDailyRequestDelegate

- (void)galleryDailyRequestSucceed:(CourtesyGalleryDailyRequestModel *)sender {
    dispatch_async_on_main_queue(^{
        self.currentStatus = kCourtesyGalleryViewControllerStatusDefault;
        [self.navigationController.view hideToastActivity];
    });
    NSArray <CourtesyGalleryDailyCardModel *> *cardArray = sender.cards;
    [self setCardsWithErrorMessage:nil];
    for (CourtesyGalleryDailyCardModel *card in cardArray) {
//        if ([card.type isEqualToString:@"GroupCard"])
//        {
//            
//        }
//        else
        if ([card.type isEqualToString:@"LinkCard"])
        {
            if (self.linkCardView) {
                [self.linkCardView setDailyCard:card];
            }
        }
        else if ([card.type isEqualToString:@"DailyCard"])
        {
            if (self.dailyCardView)
            {
                [self.dailyCardView setTargetDate:self.selectedDate];
                [self.dailyCardView setDailyCard:card];
            }
        }
    }
}

- (void)galleryDailyRequestFailed:(CourtesyGalleryDailyRequestModel *)sender
                        withError:(NSError *)error {
    dispatch_async_on_main_queue(^{
        self.currentStatus = kCourtesyGalleryViewControllerStatusNone;
        [self.navigationController.view hideToastActivity];
    });
    [self setCardsWithErrorMessage:[error localizedDescription]];
}

- (void)setCardsWithErrorMessage:(NSString *)msg {
    if (self.dailyCardView)
    {
        [self.dailyCardView setTargetDate:self.selectedDate];
        [self.dailyCardView setDailyCard:nil];
        [self.dailyCardView setErrorMessage:msg];
    }
    if (self.linkCardView) {
        [self.linkCardView setDailyCard:nil];
        [self.linkCardView setErrorMessage:msg];
    }
}

#pragma mark - Getter / Setter

- (NSDate *)selectedDate {
    if (!_selectedDate) {
        _selectedDate = [NSDate date];
    }
    return _selectedDate;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat: @"yyyy-MM-dd"];
    }
    return _dateFormatter;
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

- (IBAction)actionShareTapped:(id)sender {
    NSString *shareContent = nil;
    UIImage *shareImage = nil;
    NSString *shareUrl = nil;
    if (_currentIndex == kCourtesyGalleryDailyCard) {
        shareContent = [self dailyCardPreviewContent];
        shareImage = [self dailyCardPreviewImage];
        shareUrl = nil;
    }
    else if (_currentIndex == kCourtesyGalleryLinkCard) {
        shareContent = [self linkCardPreviewContent];
        shareImage = [self linkCardPreviewImage];
        shareUrl = [self linkCardPreviewUrl];
    }
    if (shareContent != nil) {
        UmengSetShareType(shareUrl)
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:UMENG_APP_KEY
                                          shareText:[NSString stringWithFormat:WEIBO_DAILY_SHARE_CONTENT, shareContent]
                                         shareImage:shareImage
                                    shareToSnsNames:UMENG_SHARE_PLATFORMS
                                           delegate:self];
    }
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
    if (![self.selectedDate isTheSameDayWith:date]) {
        self.currentStatus = kCourtesyGalleryViewControllerStatusNone;
        self.selectedDate = date;
        self.dateView.date = date;
        [self.dateView setNeedsDisplay];
    }
    [controller close:self];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat X = scrollView.contentOffset.x;
    for (int i = 0; i < kCourtesyGalleryMaxIndex; i++) {
        MoreInfoView *show = [scrollView viewWithTag:viewTag + i];
        show.imageView.x   = _onceLinearEquation.k * (X - i * self.view.width) + _onceLinearEquation.b;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger index = (NSUInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width);
    _currentIndex = index;
    [_pageControl setCurrentPage:index];
}

- (void)pageControlValueChanged:(UIPageControl *)sender {
    NSUInteger index = sender.currentPage;
    _currentIndex = index;
    CGSize viewSize = _mainScrollView.frame.size;
    CGRect rect = CGRectMake(index * viewSize.width, 0, viewSize.width, viewSize.height);
    [_mainScrollView scrollRectToVisible:rect animated:YES];
}

#pragma mark - Link Card Preview

- (NSString *)linkCardPreviewContent {
    return [self.linkCardView.dailyCard.string stringByAppendingString:self.linkCardView.dailyCard.url];
}

- (NSString *)linkCardPreviewUrl {
    return self.linkCardView.dailyCard.url;
}

- (UIImage *)linkCardPreviewImage {
    return self.linkCardView.middleImageView.image;
}

#pragma mark - Daily Card Preview

- (NSString *)dailyCardPreviewContent {
    return self.dailyCardView.dailyCard.string;
}

- (UIImage *)dailyCardPreviewImage {
    if (self.dailyCardView.rightImageView.image == nil) {
        return nil;
    }
    UIImage *previewImage = nil;
    NSString *preview_cache_key = [NSString stringWithFormat:kCourtesyCardPreviewCachePrefix, @"DailyCard", self.dailyCardView.dailyCard.date];
    NSData *data = [[AppStorage sharedInstance] objectForKey:preview_cache_key];
    if (!data) {
        CGSize cardSize = self.dailyCardView.bounds.size;
        UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"daily-theme"]];
        UIGraphicsBeginImageContextWithOptions(cardSize, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, CGRectMake(0, 0, cardSize.width, cardSize.height));
        [self.dailyCardView.layer renderInContext:context];
        previewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[AppStorage sharedInstance] setObject:[previewImage imageDataRepresentation] forKey:preview_cache_key];
    } else {
        previewImage = [[UIImage alloc] initWithData:data];
    }
    return previewImage;
}

- (void)dailyCardPreview:(id)sender {
    if (self.dailyCardView.dailyCard == nil) {
        [self reloadData];
        return;
    }
    
    UIImage *previewImage = [self dailyCardPreviewImage];
    
    if (previewImage) {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.image = previewImage;
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                           mode:JTSImageViewControllerMode_Image
                                                                                backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
        imageViewer.interactionsDelegate = self;
        [imageViewer showFromViewController:self
                                 transition:JTSImageViewControllerTransition_FromOffscreen];
    }
}

- (void)linkCardPreview:(id)sender {
    if (self.linkCardView.dailyCard == nil) {
        [self reloadData];
        return;
    }
    CourtesyGalleryLinkWebViewController *linkWebViewController = [CourtesyGalleryLinkWebViewController new];
    linkWebViewController.cardUrl = self.linkCardView.dailyCard.url;
    [self.navigationController pushViewController:linkWebViewController animated:YES];
}

#pragma mark - JTSImageViewControllerInteractionsDelegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer
                         atRect:(CGRect)rect {
    [imageViewer.view makeToastActivity:CSToastPositionCenter];
    [[PHPhotoLibrary sharedPhotoLibrary] saveImage:imageViewer.image
                                           toAlbum:@"礼记"
                                        completion:^(BOOL success) {
                                            if (success) {
                                                dispatch_async_on_main_queue(^{
                                                    [imageViewer.view hideToastActivity];
                                                    [imageViewer.view makeToast:@"卡片已保存到「礼记」相簿"
                                                                       duration:kStatusBarNotificationTime
                                                                       position:CSToastPositionCenter];
                                                });
                                            }
                                        } failure:^(NSError * _Nullable error) {
                                            dispatch_async_on_main_queue(^{
                                                [imageViewer.view hideToastActivity];
                                                [imageViewer.view makeToast:[NSString stringWithFormat:@"卡片保存失败 - %@", [error localizedDescription]]
                                                                   duration:kStatusBarNotificationTime
                                                                   position:CSToastPositionCenter];
                                            });
                                        }];
}

#pragma mark - JTSImageViewControllerDismissalDelegate

- (void)imageViewerDidDismiss:(JTSImageViewController *)imageViewer {
    
}

@end
