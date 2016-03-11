//
//  CourtesyCardComposeViewController.m
//  Courtesy
//
//  Created by Zheng on 3/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <objc/message.h>
#import "CourtesyAudioFrameView.h"
#import "CourtesyImageFrameView.h"
#import "CourtesyVideoFrameView.h"
#import "CourtesyTextBindingParser.h"
#import "CourtesyCardComposeViewController.h"
#import "CourtesyJotViewController.h"
#import "QBImagePickerController.h"
#import "WechatShortVideoController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PECropViewController.h"
#import "AudioNoteRecorderViewController.h"
#import "JTSImageViewController.h"
#import "CourtesyCardPreviewGenerator.h"

#define kComposeDefaultFontSize 16.0
#define kComposeDefaultLineSpacing 8.0
#define kComposeLineHeight 28.0
#define kComposeTopInsect 24.0
#define kComposeBottomInsect 24.0
#define kComposeLeftInsect 24.0
#define kComposeRightInsect 24.0
#define kComposeTopBarInsectPortrait 64.0
#define kComposeTopBarInsectLandscape 48.0

@interface CourtesyCardComposeViewController () <YYTextViewDelegate, YYTextKeyboardObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CourtesyImageFrameDelegate, WechatShortVideoDelegate, MPMediaPickerControllerDelegate, CourtesyAudioFrameDelegate, AudioNoteRecorderDelegate, JotViewControllerDelegate, JTSImageViewControllerInteractionsDelegate, CourtesyCardPreviewGeneratorDelegate>
@property (nonatomic, assign) YYTextView *textView;
@property (nonatomic, strong) UIView *fakeBar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *circleCloseBtn;
@property (nonatomic, strong) UIButton *circleApproveBtn;
@property (nonatomic, strong) UIImageView *circleSaveBtn;
@property (nonatomic, strong) UIImageView *circleBackBtn;
@property (nonatomic, strong) CourtesyJotViewController *jotViewController;
@property (nonatomic, strong) UIView *jotView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDictionary *originalAttributes;
@property (nonatomic, strong) UIFont *originalFont;

@end

@implementation CourtesyCardComposeViewController

- (instancetype)init {
    if (self = [super init]) {
        self.fd_interactivePopDisabled = YES; // 禁用全屏手势
        tryValue(self.maxAudioNum, [NSNumber numberWithInteger:1]);
        tryValue(self.maxVideoNum, [NSNumber numberWithInteger:1]);
        tryValue(self.maxImageNum, [NSNumber numberWithInteger:20]);
        tryValue(self.maxContentLength, [NSNumber numberWithInteger:2048]);
        // Debug
        self.newcard = YES;
        self.editable = YES;
        self.title = @"新卡片";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Init of main view */
    self.view.backgroundColor = tryValue(self.mainViewColor, [UIColor colorWithPatternImage:tryValue(self.mainViewBackgroundImage, [UIImage imageNamed:@"texture"])]);
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    //self.modalPresentationCapturesStatusBarAppearance = NO;
    self.edgesForExtendedLayout =  UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    
    /* Init of Navigation Bar Items (if there is a navigation bar actually) */ // 这部分没有什么用
    UIBarButtonItem *item = [UIBarButtonItem new];
    item.image = [UIImage imageNamed:@"30-send"];
    item.target = self;
    item.action = @selector(doneComposeView:);
    self.navigationItem.rightBarButtonItem = item;
    
    /* Init of toolbar container view */
    UIScrollView *toolbarContainerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    toolbarContainerView.scrollEnabled = YES;
    toolbarContainerView.alwaysBounceHorizontal = YES;
    toolbarContainerView.showsHorizontalScrollIndicator = NO;
    toolbarContainerView.showsVerticalScrollIndicator = NO;
    toolbarContainerView.backgroundColor = tryValue(self.toolbarColor, [UIColor whiteColor]);;
    
    /* Init of toolbar */
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width * 2, 40)]; // 根据按钮数量调整，暂时定为两倍
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.barTintColor = tryValue(self.toolbarBarTintColor, [UIColor whiteColor]);
    toolbar.backgroundColor = [UIColor clearColor]; // 工具栏颜色在 toolbarContainerView 中定义
    
    /* Elements of tool bar items */ // 定义按钮元素及其样式
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *myToolBarItems = [NSMutableArray array];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"45-voice"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewAudioMenu:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"36-frame"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewImageMenu:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"31-camera"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewVideoMenu:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"37-url"] style:UIBarButtonItemStylePlain target:self action:@selector(addUrl:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"50-freehand"] style:UIBarButtonItemStylePlain target:self action:@selector(openFreehand:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"51-font"] style:UIBarButtonItemStylePlain target:self action:@selector(setFont:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"33-bold"] style:UIBarButtonItemStylePlain target:self action:@selector(setRangeBold:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"32-italic"] style:UIBarButtonItemStylePlain target:self action:@selector(setRangeItalic:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"46-align-left"] style:UIBarButtonItemStylePlain target:self action:@selector(setAlignLeft:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"48-align-center"] style:UIBarButtonItemStylePlain target:self action:@selector(setAlignCenter:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"47-align-right"] style:UIBarButtonItemStylePlain target:self action:@selector(setAlignRight:)]];
    [toolbar setTintColor:tryValue(self.toolbarTintColor, [UIColor grayColor])];
    [toolbar setItems:myToolBarItems animated:YES];
    
    /* Initial text */
    NSMutableAttributedString *text = tryValue(self.cardContent, [[NSMutableAttributedString alloc] initWithString:@"说点什么吧……"]);
    text.font = [UIFont systemFontOfSize:[tryValue(self.cardFontSize, [NSNumber numberWithFloat:kComposeDefaultFontSize]) floatValue]];
    text.color = tryValue(self.cardTextColor, [UIColor darkGrayColor]);
    text.lineSpacing = [tryValue(self.cardLineSpacing, [NSNumber numberWithFloat:kComposeDefaultLineSpacing]) floatValue];
    text.lineBreakMode = NSLineBreakByWordWrapping;
    self.originalFont = tryValue(self.cardFont, text.font);
    self.originalAttributes = tryValue(self.cardContentAttributes, text.attributes);
    
    /* Init of text view */
    YYTextView *textView = [YYTextView new];
    textView.delegate = self;
    textView.typingAttributes = tryValue(self.cardContentAttributes, self.originalAttributes);
    textView.backgroundColor = tryValue(self.cardBackgroundColor, [UIColor clearColor]);
    textView.alwaysBounceVertical = YES;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Set initial text */
    textView.attributedText = text;
    
    /* Margin */
    textView.minContentSize = CGSizeMake(0, self.view.frame.size.height);
    textView.textContainerInset = UIEdgeInsetsMake(kComposeTopInsect, kComposeLeftInsect, kComposeBottomInsect, kComposeRightInsect);
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        textView.contentInset = UIEdgeInsetsMake(kComposeTopBarInsectLandscape, 0, 0, 0);
    } else {
        textView.contentInset = UIEdgeInsetsMake(kComposeTopBarInsectPortrait, 0, 0, 0);
    }
    textView.scrollIndicatorInsets = textView.contentInset;
    textView.selectedRange = NSMakeRange(text.length, 0);
    
    /* Auto correction */
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    /* Paste */
    textView.allowsPasteImage = NO; // 不允许粘贴图片
    textView.allowsPasteAttributedString = NO; // 不允许粘贴富文本
    
    /* Undo */
    textView.allowsUndoAndRedo = YES;
    textView.maximumUndoLevel = 10;
    
    /* Line height fixed */
    YYTextLinePositionSimpleModifier *mod = [YYTextLinePositionSimpleModifier new];
    mod.fixedLineHeight = [tryValue(self.cardLineHeight, [NSNumber numberWithFloat:kComposeLineHeight]) floatValue];
    textView.linePositionModifier = mod;
    
    /* Toolbar */
    [toolbarContainerView setContentSize:toolbar.frame.size];
    [toolbarContainerView addSubview:toolbar];
    textView.inputAccessoryView = self.editable ? toolbarContainerView : nil;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    /* Place holder */
    textView.placeholderText = tryValue(self.placeholderText, @"说点什么吧……");
    textView.placeholderTextColor = tryValue(self.placeholderColor, [UIColor lightGrayColor]);
    
    /* Indicator (Tint Color) */
    textView.tintColor = tryValue(self.indicatorColor, [UIColor darkGrayColor]);
    
    /* Edit ability */
    textView.editable = self.editable;
    
    /* Layout of Text View */
    self.textView = textView;
    [self.view addSubview:textView];
    [textView scrollsToTop];
    
    /* Position & Size */
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:textView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTopMargin
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:textView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottomMargin
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:textView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:textView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    
    /* Init of Jot Scroll View */
    UIView *jotView = [[UIView alloc] initWithFrame:self.textView.frame];
    jotView.backgroundColor = [UIColor clearColor];
    jotView.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Layout of Jot Scroll View */
    self.jotView = jotView;
    [self.view insertSubview:jotView belowSubview:textView];
    
    /* Position & Size */
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:jotView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTopMargin
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:jotView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottomMargin
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:jotView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:jotView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    
    /* Init of Jot View */
    CourtesyJotViewController *jotViewController = [CourtesyJotViewController new];
    jotViewController.delegate = self;
    [self addChildViewController:jotViewController];
    jotViewController.view.frame = jotView.frame;
    [jotView addSubview:jotViewController.view];
    [jotViewController didMoveToParentViewController:self];
    self.jotViewController = jotViewController;
    
    /* Init of Fake Status Bar */
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    UIView *fakeBar = [[UIView alloc] initWithFrame:frame];
    fakeBar.alpha = [tryValue(self.standardAlpha, [NSNumber numberWithFloat:0.618]) floatValue];
    fakeBar.backgroundColor = tryValue(self.statusBarColor, [UIColor blackColor]);
    fakeBar.hidden = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    
    /* Tap Gesture of Fake Status Bar */
    UITapGestureRecognizer *tapFakeBar = [[UITapGestureRecognizer alloc] initWithTarget:textView action:@selector(scrollToTop)];
    tapFakeBar.numberOfTouchesRequired = 1;
    tapFakeBar.numberOfTapsRequired = 1;
    [fakeBar addGestureRecognizer:tapFakeBar];
    [fakeBar setUserInteractionEnabled:YES];
    
    /* Layouts of Fake Status Bar */
    self.fakeBar = fakeBar;
    [self.view addSubview:fakeBar];
    [self.view bringSubviewToFront:fakeBar];
    
    /* Init of close circle button */
    UIButton *circleCloseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    circleCloseBtn.backgroundColor = tryValue(self.buttonBackgroundColor, [UIColor blackColor]);
    circleCloseBtn.tintColor = tryValue(self.buttonTintColor, [UIColor whiteColor]);
    circleCloseBtn.alpha = [tryValue(self.standardAlpha, [NSNumber numberWithFloat:0.618]) floatValue] - 0.2;
    [circleCloseBtn setImage:[[UIImage imageNamed:@"101-back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [circleCloseBtn setImage:[[UIImage imageNamed:@"39-close-circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    circleCloseBtn.selected = NO;
    circleCloseBtn.layer.masksToBounds = YES;
    circleCloseBtn.layer.cornerRadius = circleCloseBtn.frame.size.height / 2;
    circleCloseBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Tap gesture of close button */
    [circleCloseBtn addTarget:self action:@selector(closeComposeView:) forControlEvents:UIControlEventTouchUpInside];
    
    /* Enable interaction for close button */
    [circleCloseBtn setUserInteractionEnabled:YES];
    
    /* Auto layouts of close button */
    self.circleCloseBtn = circleCloseBtn;
    [self.view addSubview:circleCloseBtn];
    [self.view bringSubviewToFront:circleCloseBtn];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleCloseBtn
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleCloseBtn
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleCloseBtn
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:fakeBar
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleCloseBtn
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeadingMargin
                                                         multiplier:1
                                                           constant:0]];
    
    /* Init of approve circle button */
    UIButton *circleApproveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    circleApproveBtn.backgroundColor = tryValue(self.buttonBackgroundColor, [UIColor blackColor]);
    circleApproveBtn.tintColor = tryValue(self.buttonTintColor, [UIColor whiteColor]);
    circleApproveBtn.alpha = [tryValue(self.standardAlpha, [NSNumber numberWithFloat:0.618]) floatValue] - 0.2;
    [circleApproveBtn setImage:[[UIImage imageNamed:@"40-approve-circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [circleApproveBtn setImage:[[UIImage imageNamed:@"102-paper-plane"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    circleApproveBtn.selected = NO;
    circleApproveBtn.layer.masksToBounds = YES;
    circleApproveBtn.layer.cornerRadius = circleApproveBtn.frame.size.height / 2;
    circleApproveBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Tap gesture of approve button */
    [circleApproveBtn addTarget:self action:@selector(doneComposeView:) forControlEvents:UIControlEventTouchUpInside];
    
    /* Enable interaction for approve button */
    [circleApproveBtn setUserInteractionEnabled:YES];
    
    /* Auto layouts of approve button */
    self.circleApproveBtn = circleApproveBtn;
    [self.view addSubview:circleApproveBtn];
    [self.view bringSubviewToFront:circleApproveBtn];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleApproveBtn
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleApproveBtn
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleApproveBtn
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:fakeBar
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleApproveBtn
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailingMargin
                                                         multiplier:1
                                                           constant:0]];
    
    /* Init of approve back button */
    UIImageView *circleBackBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    circleBackBtn.backgroundColor = tryValue(self.buttonBackgroundColor, [UIColor blackColor]);
    circleBackBtn.tintColor = tryValue(self.buttonTintColor, [UIColor whiteColor]);
    circleBackBtn.alpha = [tryValue(self.standardAlpha, [NSNumber numberWithFloat:0.618]) floatValue] - 0.2;
    circleBackBtn.image = [[UIImage imageNamed:@"56-back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    circleBackBtn.layer.masksToBounds = YES;
    circleBackBtn.layer.cornerRadius = circleBackBtn.frame.size.height / 2;
    circleBackBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Back button is not visible */
    circleBackBtn.alpha = 0.0;
    circleBackBtn.hidden = YES;
    
    /* Tap gesture of back button */
    UITapGestureRecognizer *tapBackBtn = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(closeFreehand:)];
    tapBackBtn.numberOfTouchesRequired = 1;
    tapBackBtn.numberOfTapsRequired = 1;
    [circleBackBtn addGestureRecognizer:tapBackBtn];
    
    /* Enable interaction for approve button */
    [circleBackBtn setUserInteractionEnabled:YES];
    
    /* Auto layouts of approve button */
    self.circleBackBtn = circleBackBtn;
    [self.view addSubview:circleBackBtn];
    [self.view bringSubviewToFront:circleBackBtn];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBackBtn
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBackBtn
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBackBtn
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottomMargin
                                                         multiplier:1
                                                           constant:-20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBackBtn
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeadingMargin
                                                         multiplier:1
                                                           constant:0]];
    
    /* Init of save button */
    UIImageView *circleSaveBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    circleSaveBtn.backgroundColor = tryValue(self.buttonBackgroundColor, [UIColor blackColor]);
    circleSaveBtn.tintColor = tryValue(self.buttonTintColor, [UIColor whiteColor]);
    circleSaveBtn.alpha = [tryValue(self.standardAlpha, [NSNumber numberWithFloat:0.618]) floatValue] - 0.2;
    circleSaveBtn.image = [[UIImage imageNamed:@"103-down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    circleSaveBtn.layer.masksToBounds = YES;
    circleSaveBtn.layer.cornerRadius = circleSaveBtn.frame.size.height / 2;
    circleSaveBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Save button is not visible */
    circleSaveBtn.alpha = 0.0;
    circleSaveBtn.hidden = YES;
    
    /* Tap gesture of back button */
    UITapGestureRecognizer *tapSaveBtn = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(savePreview:)];
    tapSaveBtn.numberOfTouchesRequired = 1;
    tapSaveBtn.numberOfTapsRequired = 1;
    [circleSaveBtn addGestureRecognizer:tapSaveBtn];
    
    /* Enable interaction for approve button */
    [circleSaveBtn setUserInteractionEnabled:YES];
    
    /* Auto layouts of approve button */
    self.circleSaveBtn = circleSaveBtn;
    [self.view addSubview:circleSaveBtn];
    [self.view bringSubviewToFront:circleSaveBtn];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleSaveBtn
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleSaveBtn
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleSaveBtn
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottomMargin
                                                         multiplier:1
                                                           constant:-20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleSaveBtn
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailingMargin
                                                         multiplier:1
                                                           constant:0]];
    
    /* Init of Title Label */
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 24)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = tryValue(self.dateLabelTextColor, [UIColor darkGrayColor]);
    titleLabel.font = [UIFont systemFontOfSize:[tryValue(self.cardTitleFontSize, [NSNumber numberWithFloat:12.0]) floatValue]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Init of Current Date */
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:tryValue(self.cardCreateTimeFormat, @"yyyy年M月d日 EEEE ah:mm")];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    titleLabel.text = [dateFormatter stringFromDate:tryValue(self.cardModifyTime, tryValue(self.cardCreateTime, [NSDate date]))];
    
    /* Auto layouts of Title Label */
    self.dateFormatter = dateFormatter;
    self.titleLabel = titleLabel;
    [textView addSubview:titleLabel];
    [textView bringSubviewToFront:titleLabel];
    [textView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:240]];
    [textView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:24]];
    [textView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:textView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [textView addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:textView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [textView becomeFirstResponder];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textView addObserver:self forKeyPath:@"typingAttributes" options:NSKeyValueObservingOptionNew context:nil];
    [[YYTextKeyboardManager defaultManager] addObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textView removeObserver:self forKeyPath:@"typingAttributes"];
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

#pragma mark - Text Attributes Holder

// 监听输入属性的改变，禁止继承前文属性 (Fuck)
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"typingAttributes"]) {
        self.textView.typingAttributes = self.originalAttributes;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    CYLog(@"");
}

#pragma mark - Rotate

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        __weak typeof(self) weakSelf = self;
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            weakSelf.fakeBar.hidden = NO;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.fakeBar.top = 0;
            strongSelf.textView.contentInset = UIEdgeInsetsMake(kComposeTopBarInsectPortrait, 0, 0, 0);
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            weakSelf.fakeBar.hidden = YES;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.fakeBar.top = - self.fakeBar.height;
            strongSelf.textView.contentInset = UIEdgeInsetsMake(kComposeTopBarInsectLandscape, 0, 0, 0);
        }];
    }
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Selection Menu (TODO)

- (BOOL)canBecomeFirstResponder {
    return self.editable;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    /* Selection menu */
    if (action == @selector(cut:)
        || action == @selector(copy:)
        || action == @selector(paste:)
        || action == @selector(select:)
        || action == @selector(selectAll:)) {
        return [super canPerformAction:action withSender:sender];
    }
    return NO;
}

#pragma mark - Floating Actions & Navigation Bar Items

- (void)closeComposeView:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        self.circleApproveBtn.selected = NO;
        self.editable = YES;
        if (!self.textView.isFirstResponder) {
            [self.textView becomeFirstResponder];
        }
        self.textView.selectedRange = NSMakeRange(self.textView.text.length, 0);
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.circleSaveBtn.alpha = 0.0;
        } completion:^(BOOL finished) {
            weakSelf.circleSaveBtn.hidden = YES;
        }];
        [self.view makeToast:@"退出预览模式"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
    } else {
        if (self.textView.isFirstResponder) {
            [self.textView resignFirstResponder];
        }
        [self dismissViewControllerAnimated:YES completion:^() {
            [self.view removeAllSubviews];
        }];
    }
}

- (void)doneComposeView:(UIButton *)sender {
    if (sender.selected) {
        
    } else {
        sender.selected = YES;
        self.circleCloseBtn.selected = YES;
        if (self.textView.text.length >= [self.maxContentLength integerValue]) {
            [self.view makeToast:@"卡片内容太多了喔"
                        duration:kStatusBarNotificationTime
                        position:CSToastPositionCenter];
            return;
        }
        if (self.textView.isFirstResponder) {
            [self.textView resignFirstResponder];
        }
        self.editable = NO;
        self.circleSaveBtn.hidden = NO;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5 animations:^{
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.circleSaveBtn.alpha = [tryValue(strongSelf.standardAlpha, [NSNumber numberWithFloat:0.618]) floatValue] - 0.2;
        } completion:nil];
        [self.view makeToast:@"发布前预览"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
    }
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    self.textView.editable = editable;
    [self lockAttachments:!editable];
}

- (void)savePreview:(id)sender {
    CGSize imageSize = CGSizeMake(self.textView.containerView.frame.size.width, self.textView.containerView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0); // Retina Support
    CALayer *originalLayer = self.textView.containerView.layer;
    originalLayer.backgroundColor = [UIColor clearColor].CGColor;
    [originalLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *originalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CourtesyCardPreviewGenerator *generator = [CourtesyCardPreviewGenerator new];
    generator.delegate = self;
    generator.contentImage = originalImage;
    [self.view makeToastActivity:CSToastPositionCenter];
    [generator generate];
}

- (void)generatorDidFinishWorking:(CourtesyCardPreviewGenerator *)generator result:(UIImage *)result {
    UIImageWriteToSavedPhotosAlbum(result, self, @selector(preview:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)preview:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self.view hideToastActivity];
    if (error) {
        [self.view makeToast:@"预览图保存失败"
                           duration:kStatusBarNotificationTime
                           position:CSToastPositionCenter];
    } else {
        [self.view makeToast:@"预览图已保存到相册"
                           duration:kStatusBarNotificationTime
                           position:CSToastPositionCenter];
    }
}

#pragma mark - Toolbar Actions

- (void)setRangeBold:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    NSRange range = self.textView.selectedRange;
    if (range.length <= 0) {
        [self.view makeToast:@"请选择需要设置粗体的文字"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[self.textView attributedText]];
    NSAttributedString *sub = [string attributedSubstringFromRange:range];
    UIFont *font = [sub font];
    if (![font isBold]) {
        [string setFont:[font fontWithBold] range:range];
    } else {
        [string setFont:[font fontWithNormal] range:range];
    }
    [self.textView setAttributedText:string];
    [self.textView setSelectedRange:range];
    [self.textView scrollRangeToVisible:range];
}

- (void)setRangeItalic:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    NSRange range = self.textView.selectedRange;
    if (range.length <= 0) {
        [self.view makeToast:@"请选择需要设置斜体的文字"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[self.textView attributedText]];
    NSAttributedString *sub = [string attributedSubstringFromRange:range];
    UIFont *font = [sub font];
    if (![font isItalic]) {
        [string setFont:[font fontWithItalic] range:range];
    } else {
        [string setFont:[font fontWithNormal] range:range];
    }
    [self.textView setAttributedText:string];
    [self.textView setSelectedRange:range];
    [self.textView scrollRangeToVisible:range];
}

- (void)addUrl:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    NSRange range = self.textView.selectedRange;
    if (range.length <= 0) {
        [self.view makeToast:@"请选择需要设置为链接的文字"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[self.textView attributedText]];
    [[CourtesyTextBindingParser sharedInstance] parseText:string selectedRange:&range];
    [self.textView setAttributedText:string];
    [self.textView setSelectedRange:range];
    [self.textView scrollRangeToVisible:range];
}

- (void)addNewImageMenu:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if ([self countOfImageFrame] >= [self.maxImageNum integerValue]) {
        [self.view makeToast:@"图片数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    __weak typeof(self) weakSelf = self;
    LGAlertView *alert = [[LGAlertView alloc] initWithTitle:@"插入图像"
                                                    message:@"请选择一种方式"
                                                      style:LGAlertViewStyleActionSheet
                                               buttonTitles:@[@"相机", @"从相册选取"]
                                          cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:nil
                                              actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                  __strong typeof(self) strongSelf = weakSelf;
                                                                if (index == 0) {
                                                                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                    picker.delegate = strongSelf;
                                                                    picker.allowsEditing = NO;
                                                                    [strongSelf presentViewController:picker animated:YES completion:nil];
                                                                } else {
                                                                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                    picker.delegate = strongSelf;
                                                                    picker.allowsEditing = NO;
                                                                    [strongSelf presentViewController:picker animated:YES completion:nil];
                                                                }
                                                            }
                                              cancelHandler:^(LGAlertView *alertView) {
                                                  __strong typeof(self) strongSelf = weakSelf;
                                                                if (!strongSelf.textView.isFirstResponder) {
                                                                    [strongSelf.textView becomeFirstResponder];
                                                                }
                                                            } destructiveHandler:nil];
    [alert showAnimated:YES completionHandler:nil];
}

- (void)addNewAudioMenu:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if ([self countOfAudioFrame] >= [self.maxAudioNum integerValue]) {
        [self.view makeToast:@"音频数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    __weak typeof(self) weakSelf = self;
    LGAlertView *alert = [[LGAlertView alloc] initWithTitle:@"插入音频"
                                                    message:@"请选择一种方式"
                                                      style:LGAlertViewStyleActionSheet
                                               buttonTitles:@[@"录音", @"从音乐库选取"]
                                          cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:nil
                                              actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                  __strong typeof(self) strongSelf = weakSelf;
                                                  if (index == 0) {
                                                      AudioNoteRecorderViewController *vc = [[AudioNoteRecorderViewController alloc] initWithMasterViewController:strongSelf];
                                                      vc.delegate = strongSelf;
                                                      [strongSelf presentViewController:vc animated:NO completion:nil];
                                                  } else {
                                                      MPMediaPickerController * mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
                                                      mediaPicker.delegate = strongSelf;
                                                      mediaPicker.allowsPickingMultipleItems = NO;
                                                      [strongSelf presentViewController:mediaPicker animated:YES completion:nil];
                                                  }
                                              } cancelHandler:^(LGAlertView *alertView) {
                                                  __strong typeof(self) strongSelf = weakSelf;
                                                  if (!strongSelf.textView.isFirstResponder) {
                                                      [strongSelf.textView becomeFirstResponder];
                                                  }
                                              } destructiveHandler:nil];
    [alert showAnimated:YES completionHandler:nil];
}

- (void)addNewVideoMenu:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if ([self countOfVideoFrame] >= [self.maxVideoNum integerValue]) {
        [self.view makeToast:@"视频数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    __weak typeof(self) weakSelf = self;
    LGAlertView *alert = [[LGAlertView alloc] initWithTitle:@"插入视频"
                                                    message:@"请选择一种方式"
                                                      style:LGAlertViewStyleActionSheet
                                               buttonTitles:@[@"随手录", @"相机", @"从相册选取"]
                                          cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:nil
                                              actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                  __strong typeof(self) strongSelf = weakSelf;
                                                  if (index == 0) {
                                                      WechatShortVideoController *shortVideoController = [WechatShortVideoController new];
                                                      shortVideoController.delegate = strongSelf;
                                                      [strongSelf presentViewController:shortVideoController animated:YES completion:nil];
                                                  } else if (index == 1) {
                                                      UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                      picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo];
                                                      picker.videoMaximumDuration = 30.0;
                                                      picker.delegate = strongSelf;
                                                      picker.allowsEditing = YES;
                                                      [strongSelf presentViewController:picker animated:YES completion:nil];
                                                  } else if (index == 2) {
                                                      UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                      picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo];
                                                      picker.videoMaximumDuration = 30.0;
                                                      picker.videoQuality = [sharedSettings preferredVideoQuality];
                                                      picker.delegate = strongSelf;
                                                      picker.allowsEditing = YES;
                                                      [strongSelf presentViewController:picker animated:YES completion:nil];
                                                  }
                                              }
                                              cancelHandler:^(LGAlertView *alertView) {
                                                  __strong typeof(self) strongSelf = weakSelf;
                                                  if (!strongSelf.textView.isFirstResponder) {
                                                      [strongSelf.textView becomeFirstResponder];
                                                  }
                                              } destructiveHandler:nil];
    [alert showAnimated:YES completionHandler:nil];
}

- (void)setAlignLeft:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    [self setTextViewAlignment:NSTextAlignmentLeft];
}

- (void)setAlignCenter:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    [self setTextViewAlignment:NSTextAlignmentCenter];
}

- (void)setAlignRight:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    [self setTextViewAlignment:NSTextAlignmentRight];
}

- (void)closeFreehand:(UIGestureRecognizer *)sender {
    [self.jotViewController setState:JotViewStateDefault];
    [self.jotViewController setControlEnabled:NO];
    [self.view sendSubviewToBack:self.jotView];
    self.circleApproveBtn.hidden = NO;
    self.circleCloseBtn.hidden = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5
                     animations:^{
                         __strong typeof(self) strongSelf = weakSelf;
                         strongSelf.circleBackBtn.alpha = 0.0;
                         strongSelf.circleApproveBtn.alpha = [tryValue(strongSelf.standardAlpha, [NSNumber numberWithFloat:0.618]) floatValue] - 0.2;
                         strongSelf.circleCloseBtn.alpha = [tryValue(strongSelf.standardAlpha, [NSNumber numberWithFloat:0.618]) floatValue] - 0.2;
                     } completion:^(BOOL finished) {
                         __strong typeof(self) strongSelf = weakSelf;
                         if (finished) {
                             strongSelf.circleBackBtn.hidden = YES;
                             strongSelf.circleApproveBtn.userInteractionEnabled = YES;
                             strongSelf.circleCloseBtn.userInteractionEnabled = YES;
                             if (!strongSelf.textView.isFirstResponder) {
                                 [strongSelf.textView becomeFirstResponder];
                             }
                         }
                     }];
}

- (void)openFreehand:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    [self.jotViewController setState:JotViewStateDrawing];
    [self.jotViewController setControlEnabled:YES];
    [self.view sendSubviewToBack:self.textView];
    self.circleBackBtn.hidden = NO;
    self.circleApproveBtn.userInteractionEnabled = NO;
    self.circleCloseBtn.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5
                     animations:^{
                         __strong typeof(self) strongSelf = weakSelf;
                         strongSelf.circleBackBtn.alpha = [tryValue(strongSelf.standardAlpha, [NSNumber numberWithFloat:0.618]) floatValue] - 0.2;
                         strongSelf.circleApproveBtn.alpha = 0;
                         strongSelf.circleCloseBtn.alpha = 0;
                     } completion:^(BOOL finished) {
                         __strong typeof(self) strongSelf = weakSelf;
                         if (finished) {
                             strongSelf.circleApproveBtn.hidden = YES;
                             strongSelf.circleCloseBtn.hidden = YES;
                         }
                     }];
}

- (void)setFont:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    // TODO: 更改字体
    [self.view makeToast:@"Demo 版本中无法切换字体"
                duration:kStatusBarNotificationTime
                position:CSToastPositionCenter];
}

- (void)setTextViewAlignment:(NSTextAlignment)alignment {
    if (!self.editable) return;
    NSRange range = self.textView.selectedRange;
    if (range.length <= 0 && [self.textView.typingAttributes hasKey:NSParagraphStyleAttributeName]) {
        NSParagraphStyle *paragraphStyle = [self.textView.typingAttributes objectForKey:NSParagraphStyleAttributeName];
        NSMutableParagraphStyle *newParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [newParagraphStyle setParagraphStyle:paragraphStyle];
        newParagraphStyle.alignment = alignment;
        NSMutableDictionary *newTypingAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.textView.typingAttributes];
        [newTypingAttributes setObject:newParagraphStyle forKey:NSParagraphStyleAttributeName];
        [self.textView setTypingAttributes:newTypingAttributes];
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[self.textView attributedText]];
    [string setAlignment:alignment];
    [self.textView setAttributedText:string];
    [self.textView setSelectedRange:range];
    [self.textView scrollRangeToVisible:range];
}

#pragma mark - AudioNoteRecorderDelegate

- (void)audioNoteRecorderDidCancel:(AudioNoteRecorderViewController *)audioNoteRecorder {
    __weak typeof(self) weakSelf = self;
    [audioNoteRecorder dismissViewControllerAnimated:NO completion:^() {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf.textView.isFirstResponder) {
            [strongSelf.textView becomeFirstResponder];
        }
    }];
}

- (void)audioNoteRecorderDidTapDone:(AudioNoteRecorderViewController *)audioNoteRecorder
                    withRecordedURL:(NSURL *)recordedURL {
    if (!self.editable) return;
    __weak typeof(self) weakSelf = self;
    __block NSURL *newURL = recordedURL;
    [audioNoteRecorder dismissViewControllerAnimated:NO completion:^() {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf addNewAudioFrame:newURL
                                  at:strongSelf.textView.selectedRange
                            animated:YES
                            userinfo:@{
                                       @"title": @"Untitled", // TODO: 修改录音描述
                                       @"type": @(CourtesyAttachmentAudio),
                                       @"url": newURL
                                       }];
    }];
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    __weak typeof(self) weakSelf = self;
    [mediaPicker dismissViewControllerAnimated:YES completion:^() {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf.textView.isFirstResponder) {
            [strongSelf.textView becomeFirstResponder];
        }
    }];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
 didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    if (!self.editable) return;
    if (!mediaItemCollection) return;
    if (mediaItemCollection.count == 1) {
        if (mediaItemCollection.mediaTypes <= MPMediaTypeAnyAudio) {
            for (MPMediaItem *item in [mediaItemCollection items]) {
                if ([item hasProtectedAsset] == NO && [item isCloudItem] == NO) {
                    CYLog(@"%@", [item title]);
                    CYLog(@"%@", [item assetURL]);
                    [self addNewAudioFrame:[item assetURL]
                                        at:self.textView.selectedRange
                                  animated:YES
                                  userinfo:@{
                                             @"title": [item title],
                                             @"type": @(CourtesyAttachmentAudio),
                                             @"url": [item assetURL]
                                             }];
                } else {
                    [self.view makeToast:@"请勿选择有版权保护的音乐"
                                duration:kStatusBarNotificationTime
                                position:CSToastPositionCenter];
                }
            }
        } else {
            
        }
    }
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^() {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf.textView.isFirstResponder) [strongSelf.textView becomeFirstResponder];
    }];
}

- (void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (!self.editable) return;
    if ([info hasKey:UIImagePickerControllerEditedImage] || [info hasKey:UIImagePickerControllerOriginalImage]) {
        __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        __block NSDictionary *newInfo = info;
        __weak typeof(self) weakSelf = self;
        [picker dismissViewControllerAnimated:YES completion:^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf addNewImageFrame:image
                                at:strongSelf.textView.selectedRange
                          animated:YES
                          userinfo:@{
                                     @"title": @"Untitled",
                                     @"type": @(CourtesyAttachmentImage),
                                     @"data": [newInfo hasKey:UIImagePickerControllerOriginalImage] ? [newInfo objectForKey:UIImagePickerControllerOriginalImage] : nil,
                                     @"url": [newInfo hasKey:UIImagePickerControllerReferenceURL] ? [newInfo objectForKey:UIImagePickerControllerReferenceURL] : nil
                                     }];
        }];
    } else if ([info hasKey:UIImagePickerControllerMediaType] && [info hasKey:UIImagePickerControllerMediaURL]
               && (
                   [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie] ||
                   [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeVideo]
                  )) {
                   __block NSURL *mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
                   __block NSDictionary *newInfo = info;
                   __strong typeof(self) weakSelf = self;
                   [picker dismissViewControllerAnimated:YES completion:^{
                       __strong typeof(self) strongSelf = weakSelf;
                       [strongSelf addNewVideoFrame:mediaURL
                                                 at:self.textView.selectedRange
                                           animated:YES
                                           userinfo:@{
                                                      @"title": @"Untitled",
                                                      @"type": @(CourtesyAttachmentVideo),
                                                      @"trim": [newInfo hasKey:UIImagePickerControllerMediaURL] ? [newInfo objectForKey:UIImagePickerControllerMediaURL] : nil,
                                                      @"url": [newInfo hasKey:UIImagePickerControllerReferenceURL] ? [newInfo objectForKey:UIImagePickerControllerReferenceURL] : nil
                                                      }];
                   }];
   } else {
       [picker dismissViewControllerAnimated:YES completion:nil];
   }
}

#pragma mark - WeChatShortVideoDelegate

- (void)finishWechatShortVideoCapture:(WechatShortVideoController *)controller
                                 path:(NSURL *)filePath {
    if (!self.editable) return;
    __block NSURL *newPath = filePath;
    __weak typeof(self) weakSelf = self;
    [controller dismissViewControllerAnimated:YES
                                   completion:^{
                                       __strong typeof(self) strongSelf = weakSelf;
                                       [strongSelf addNewVideoFrame:newPath
                                                                 at:strongSelf.textView.selectedRange
                                                           animated:YES
                                                           userinfo:@{
                                                                      @"title": @"Untitled",
                                                                      @"type": @(CourtesyAttachmentVideo),
                                                                      @"url": newPath
                                                                      }];
                                   }];
}

#pragma mark - Audio Frame Builder

- (CourtesyAudioFrameView *)addNewAudioFrame:(NSURL *)url
                                          at:(NSRange)range
                                    animated:(BOOL)animated
                                    userinfo:(NSDictionary *)info {
    if (!self.editable) return nil;
    CourtesyAudioFrameView *frameView = [[CourtesyAudioFrameView alloc] initWithFrame:CGRectMake(0, 0, self.textView.frame.size.width - kComposeLeftInsect - kComposeRightInsect, kComposeLineHeight * 2)];
    [frameView setDelegate:self];
    [frameView setUserinfo:info];
    [frameView setCardTintColor:self.cardElementTintColor];
    [frameView setCardTintFocusColor:self.cardElementTintFocusColor];
    [frameView setCardTextColor:self.cardElementTextColor];
    [frameView setCardShadowColor:self.cardElementShadowColor];
    [frameView setCardBackgroundColor:self.cardElementBackgroundColor];
    [frameView setAutoPlay:self.shouldAutoPlayAudio];
    [frameView setAudioURL:url];
    return [self insertFrameToTextView:frameView
                                    at:range
                              animated:animated];
}

#pragma mark - Image Frame Builder

- (CourtesyImageFrameView *)addNewImageFrame:(UIImage *)image
                                          at:(NSRange)range
                                    animated:(BOOL)animated
                                    userinfo:(NSDictionary *)info {
    if (!self.editable) return nil;
    CourtesyImageFrameView *frameView = [[CourtesyImageFrameView alloc] initWithFrame:CGRectMake(0, 0, self.textView.frame.size.width - kComposeLeftInsect - kComposeRightInsect, 0)];
    [frameView setDelegate:self];
    [frameView setUserinfo:info];
    [frameView setCardTintColor:self.cardElementTintColor];
    [frameView setCardTextColor:self.cardElementTextColor];
    [frameView setCardShadowColor:self.cardElementShadowColor];
    [frameView setCardBackgroundColor:self.cardElementBackgroundColor];
    [frameView setStandardLineHeight:kComposeLineHeight];
    [frameView setEditable:self.editable];
    [frameView setCenterImage:image];
    if (frameView.frame.size.height < kComposeLineHeight) { // 添加失败
        return nil;
    }
    return [self insertFrameToTextView:frameView
                                    at:range
                              animated:animated];
}

#pragma mark - Video Frame Builder

- (CourtesyVideoFrameView *)addNewVideoFrame:(NSURL *)url
                                          at:(NSRange)range
                                    animated:(BOOL)animated
                                    userinfo:(NSDictionary *)info {
    if (!self.editable) return nil;
    CourtesyVideoFrameView *frameView = [[CourtesyVideoFrameView alloc] initWithFrame:CGRectMake(0, 0, self.textView.frame.size.width - 48, 0)];
    [frameView setDelegate:self];
    [frameView setUserinfo:info];
    [frameView setCardTintColor:self.cardElementTintColor];
    [frameView setCardTextColor:self.cardElementTextColor];
    [frameView setCardShadowColor:self.cardElementShadowColor];
    [frameView setCardBackgroundColor:self.cardElementBackgroundColor];
    [frameView setStandardLineHeight:kComposeLineHeight];
    [frameView setEditable:self.editable];
    [frameView setVideoURL:url];
    return [self insertFrameToTextView:frameView
                                    at:range
                              animated:animated];
}

#pragma mark - Insert Frame Helper

- (id)insertFrameToTextView:(UIView *)frameView
                           at:(NSRange)range
                     animated:(BOOL)animated {
    if (!self.editable) return nil;
    if (animated) [frameView setAlpha:0.0];
    // Add Frame View to Text View (Method 1)
    NSMutableString *insertHelper = [[NSMutableString alloc] initWithString:@"\n"];
    int t = floor(frameView.height / kComposeLineHeight);
    for (int i = 0; i < t; i++) [insertHelper appendString:@"\n"];
    NSMutableAttributedString *attachText = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:insertHelper attributes:self.originalAttributes]];
    [attachText appendAttributedString:[NSMutableAttributedString attachmentStringWithContent:frameView
                                                                                  contentMode:UIViewContentModeCenter
                                                                               attachmentSize:frameView.size
                                                                                  alignToFont:self.originalFont
                                                                                    alignment:YYTextVerticalAlignmentBottom]];
    [attachText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:self.originalAttributes]];
    YYTextBinding *binding = [YYTextBinding bindingWithDeleteConfirm:YES];
    [attachText setTextBinding:binding range:NSMakeRange(0, attachText.length)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [text insertAttributedString:attachText atIndex:range.location];
    if ([frameView isKindOfClass:[CourtesyImageFrameView class]]) {
        [(CourtesyImageFrameView *)frameView setSelfRange:NSMakeRange(range.location, attachText.length)];
    } else if ([frameView isKindOfClass:[CourtesyAudioFrameView class]]) {
        [(CourtesyAudioFrameView *)frameView setSelfRange:NSMakeRange(range.location, attachText.length)];
    }
    [self.textView setAttributedText:text];
    [self.textView scrollRangeToVisible:range];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [frameView setAlpha:1.0];
        } completion:nil];
    }
    return frameView;
}

#pragma mark - CourtesyAudioFrameDelegate

- (void)audioFrameTapped:(CourtesyAudioFrameView *)audioFrame {
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
}

#pragma mark - JTSImageViewControllerInteractionsDelegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer
                         atRect:(CGRect)rect {
    UIImageWriteToSavedPhotosAlbum(imageViewer.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)(imageViewer));
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (contextInfo) {
        JTSImageViewController *imageViewer = (__bridge JTSImageViewController *)contextInfo;
        if (error) {
            [imageViewer.view makeToast:@"图片保存失败"
                               duration:kStatusBarNotificationTime
                               position:CSToastPositionCenter];
        } else {
            [imageViewer.view makeToast:@"图片已保存到相册"
                               duration:kStatusBarNotificationTime
                               position:CSToastPositionCenter];
        }
    }
}

#pragma mark - CourtesyImageFrameDelegate

- (void)imageFrameTapped:(CourtesyImageFrameView *)imageFrame {
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
    if (!imageFrame.editable) {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.title = imageFrame.labelText;
        if (imageFrame.originalImageURL) {
            imageInfo.placeholderImage = imageFrame.centerImage;
            imageInfo.imageURL = imageFrame.originalImageURL;
        } else {
            imageInfo.image = imageFrame.centerImage;
        }
        imageInfo.referenceRect = imageFrame.centerImageView.frame;
        imageInfo.referenceView = imageFrame;
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                           mode:JTSImageViewControllerMode_Image
                                                                                backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        imageViewer.interactionsDelegate = self;
        [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
}

- (void)imageFrameShouldReplaced:(CourtesyImageFrameView *)imageFrame
                              by:(UIImage *)image
                        userinfo:(NSDictionary *)userinfo {
    if (!self.editable) return;
    [self imageFrameShouldDeleted:imageFrame
                         animated:NO];
    [self addNewImageFrame:image
                        at:imageFrame.selfRange
                  animated:NO
                  userinfo:userinfo];
}

- (void)imageFrameShouldDeleted:(CourtesyImageFrameView *)imageFrame
                       animated:(BOOL)animated {
    if (!self.editable) return;
    if (!animated) {
        [self removeImageFrameFromTextView:imageFrame];
    } else {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            imageFrame.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [weakSelf removeImageFrameFromTextView:imageFrame];
            }
        }];
    }
}

- (void)removeImageFrameFromTextView:(CourtesyImageFrameView *)imageFrame {
    if (!self.editable) return;
    CYLog(@"%@", self.textView.textLayout.attachments);
    [imageFrame removeFromSuperview];
    NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:[self.textView attributedText]];
    NSRange allRange = [mStr rangeOfAll];
    if (imageFrame.selfRange.location >= allRange.location &&
        imageFrame.selfRange.location + imageFrame.selfRange.length <= allRange.location + allRange.length) {
        [mStr deleteCharactersInRange:imageFrame.selfRange];
        [self.textView setAttributedText:mStr];
    }
}

- (void)imageFrameShouldCropped:(CourtesyImageFrameView *)imageFrame {
    if (!self.editable) return;
    PECropViewController *cropViewController = [[PECropViewController alloc] init];
    cropViewController.delegate = imageFrame;
    cropViewController.image = imageFrame.centerImage;
    
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:cropViewController];
    [self presentViewController:navc animated:YES completion:nil];
}

#pragma mark - Elements Control

#ifdef DEBUG
- (void)listAttachments {
    for (id object in self.textView.textLayout.attachments) {
        if (![object isKindOfClass:[YYTextAttachment class]]) {
            continue;
        }
        YYTextAttachment *attachment = (YYTextAttachment *)object;
        if (attachment.content) {
            if ([attachment.content respondsToSelector:@selector(userinfo)]) {
                CYLog(@"%@\n%@", [attachment.content description], objc_msgSend(attachment.content, @selector(userinfo)));
            }
        }
    }
}
#endif

- (void)lockAttachments:(BOOL)locked {
    for (id object in self.textView.textLayout.attachments) {
        if (![object isKindOfClass:[YYTextAttachment class]]) {
            continue;
        }
        YYTextAttachment *attachment = (YYTextAttachment *)object;
        if (attachment.content) {
            if ([attachment.content respondsToSelector:@selector(setEditable:)]) {
                if ([attachment.content isMemberOfClass:[CourtesyImageFrameView class]]) {
                    CourtesyImageFrameView *obj = (CourtesyImageFrameView *)attachment.content;
                    [obj setEditable:!locked];
                } else if ([attachment.content isMemberOfClass:[CourtesyVideoFrameView class]]) {
                    CourtesyVideoFrameView *obj = (CourtesyVideoFrameView *)attachment.content;
                    [obj setEditable:!locked];
                }
            }
        }
    }
}

- (NSUInteger)countOfAudioFrame {
    return [self countOfClass:[CourtesyAudioFrameView class]];
}

- (NSUInteger)countOfImageFrame {
    return [self countOfClass:[CourtesyImageFrameView class]];
}

- (NSUInteger)countOfVideoFrame {
    return [self countOfClass:[CourtesyVideoFrameView class]];
}

- (NSUInteger)countOfClass:(Class)class {
#ifdef DEBUG
    [self listAttachments];
#endif
    NSUInteger num = 0;
    for (id object in self.textView.textLayout.attachments) {
        if (![object isKindOfClass:[YYTextAttachment class]]) {
            continue;
        }
        YYTextAttachment *attachment = (YYTextAttachment *)object;
        if (attachment.content && [attachment.content isKindOfClass:class]) {
            num++;
        } else {
            CYLog(@"%@", [attachment.content description]);
        }
    }
    return num;
}

#pragma mark - YYTextKeyboardObserver

- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition {
    
}

#pragma mark - Memory Leaks

- (void)didReceiveMemoryWarning {
    CYLog(@"Memory warning!");
}

@end
