//
//  CourtesyCardComposeViewController.m
//  Courtesy
//
//  Created by Zheng on 3/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <objc/message.h>
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FYPhotoAsset.h"
#import "CourtesyAudioFrameView.h"
#import "CourtesyImageFrameView.h"
#import "CourtesyVideoFrameView.h"
#import "CourtesyCardComposeViewController.h"
#import "CourtesyJotViewController.h"
#import "WechatShortVideoController.h"
#import "PECropViewController.h"
#import "CourtesyAudioNoteRecorderView.h"
#import "JTSImageViewController.h"
#import "JTSAnimatedGIFUtility.h"
#import "CourtesyCardPreviewGenerator.h"
#import "CourtesyTextView.h"
#import "CourtesyFontSheetView.h"
#import "CourtesyAudioSheetView.h"
#import "CourtesyImageSheetView.h"
#import "CourtesyVideoSheetView.h"
#import "CourtesyMarkdownParser.h"
#import "FCFileManager.h"

#define kComposeTopInsect 24.0
#define kComposeBottomInsect 24.0
#define kComposeLeftInsect 24.0
#define kComposeRightInsect 24.0
#define kComposeTopBarInsectPortrait 64.0
#define kComposeTopBarInsectLandscape 48.0

@interface CourtesyCardComposeViewController ()
<
    YYTextViewDelegate,
    YYTextKeyboardObserver,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    MPMediaPickerControllerDelegate,
    CourtesyAudioFrameDelegate,
    CourtesyAudioNoteRecorderDelegate,
    CourtesyImageFrameDelegate,
    WechatShortVideoDelegate,
    JotViewControllerDelegate,
    JTSImageViewControllerInteractionsDelegate,
    CourtesyCardPreviewGeneratorDelegate,
    CourtesyFontSheetViewDelegate,
    CourtesyAudioSheetViewDelegate,
    CourtesyImageSheetViewDelegate,
    CourtesyVideoSheetViewDelegate,
    LGAlertViewDelegate
>
@property (nonatomic, assign) CourtesyTextView *textView;
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
@property (nonatomic, strong) CourtesyMarkdownParser *markdownParser;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *audioButton;
@property (nonatomic, strong) UIBarButtonItem *imageButton;
@property (nonatomic, strong) UIBarButtonItem *videoButton;
@property (nonatomic, strong) UIBarButtonItem *urlButton;
@property (nonatomic, strong) UIBarButtonItem *drawButton;
@property (nonatomic, strong) UIBarButtonItem *fontButton;
@property (nonatomic, strong) UIBarButtonItem *alignmentButton;
@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, assign) CourtesyInputViewType inputViewType;

@end

@implementation CourtesyCardComposeViewController
- (instancetype)initWithCard:(nullable CourtesyCardModel *)card{
    if (self = [super init]) {
        self.fd_interactivePopDisabled = YES; // 禁用全屏手势
        if (!card) {
            card = [CourtesyCardManager newCard]; // 这里只能渲染初始卡片模型
        }
        _card = card;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Init of main view */
    self.view.backgroundColor = self.style.cardBackgroundColor;
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
    toolbarContainerView.backgroundColor = self.style.toolbarColor;
    
    /* Init of toolbar */
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width , 40)]; // 根据按钮数量调整，暂时定为两倍
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.barTintColor = self.style.toolbarBarTintColor;
    toolbar.backgroundColor = [UIColor clearColor]; // 工具栏颜色在 toolbarContainerView 中定义
    
    /* Elements of tool bar items */ // 定义按钮元素及其样式
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *myToolBarItems = [NSMutableArray array];
    self.audioButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"45-voice"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewAudioButtonTapped:)];
    [myToolBarItems addObject:self.audioButton];
    [myToolBarItems addObject:flexibleSpace];
    self.imageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"36-frame"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewImageButtonTapped:)];
    [myToolBarItems addObject:self.imageButton];
    [myToolBarItems addObject:flexibleSpace];
    self.videoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"31-camera"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewVideoButtonTapped:)];
    [myToolBarItems addObject:self.videoButton];
    [myToolBarItems addObject:flexibleSpace];
    self.urlButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"37-url"] style:UIBarButtonItemStylePlain target:self action:@selector(addUrlButtonTapped:)];
    [myToolBarItems addObject:self.urlButton];
    [myToolBarItems addObject:flexibleSpace];
    self.drawButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"50-freehand"] style:UIBarButtonItemStylePlain target:self action:@selector(openFreehandButtonTapped:)];
    [myToolBarItems addObject:self.drawButton];
    [myToolBarItems addObject:flexibleSpace];
    self.fontButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"51-font"] style:UIBarButtonItemStylePlain target:self action:@selector(fontButtonTapped:)];
    [myToolBarItems addObject:self.fontButton];
    [myToolBarItems addObject:flexibleSpace];
    NSString *alignmentImageName = nil;
    if (self.card.card_data.alignmentType == NSTextAlignmentLeft) {
        alignmentImageName = @"46-align-left";
    } else if (self.card.card_data.alignmentType == NSTextAlignmentCenter) {
        alignmentImageName = @"48-align-center";
    } else {
        alignmentImageName = @"47-align-right";
    }
    self.alignmentButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:alignmentImageName] style:UIBarButtonItemStylePlain target:self action:@selector(alignButtonTapped:)];
    [myToolBarItems addObject:self.alignmentButton];
    [toolbar setTintColor:self.style.toolbarTintColor];
    [toolbar setItems:myToolBarItems animated:YES];
    self.toolbar = toolbar;
    
    /* Initial text */
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.card.card_data.content];
    text.font = [[CourtesyFontManager sharedManager] fontWithID:self.card.card_data.fontType];
    if (!text.font) {
        text.font = [UIFont systemFontOfSize:self.card.card_data.fontSize];
    } else {
        text.font = [text.font fontWithSize:self.card.card_data.fontSize];
    }
    text.color = self.style.cardTextColor;
    text.lineSpacing = self.style.cardLineSpacing;
    text.paragraphSpacing = self.style.paragraphSpacing;
    text.lineBreakMode = NSLineBreakByWordWrapping;
    text.alignment = self.card.card_data.alignmentType;
    self.originalFont = text.font;
    self.originalAttributes = text.attributes;
    
    /* Init of text view */
    CourtesyTextView *textView = [CourtesyTextView new];
    textView.delegate = self;
    textView.typingAttributes = self.originalAttributes;
    textView.backgroundColor = [UIColor clearColor];
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
    textView.maximumUndoLevel = 20;
    
    /* Line height fixed */
    YYTextLinePositionSimpleModifier *mod = [YYTextLinePositionSimpleModifier new];
    mod.fixedLineHeight = self.style.cardLineHeight;
    textView.linePositionModifier = mod;
    
    /* Toolbar */
    [toolbarContainerView setContentSize:toolbar.frame.size];
    [toolbarContainerView addSubview:toolbar];
    textView.inputAccessoryView = self.editable ? toolbarContainerView : nil;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    /* Place holder */
    textView.placeholderText = self.style.placeholderText;
    textView.placeholderTextColor = self.style.placeholderColor;
    textView.placeholderFont = text.font;
    
    /* Indicator (Tint Color) */
    textView.tintColor = self.style.indicatorColor;
    
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
    
    if ([sharedSettings switchMarkdown]) {
        /* Markdown Support */
        CourtesyMarkdownParser *parser = [CourtesyMarkdownParser new];
        parser.currentFont = text.font;
        parser.fontSize = self.card.card_data.fontSize;
        parser.headerFontSize = [self.style.headerFontSize floatValue];
        parser.textColor = self.style.cardTextColor;
        parser.controlTextColor = self.style.controlTextColor;
        parser.headerTextColor = self.style.headerTextColor;
        parser.inlineTextColor = self.style.inlineTextColor;
        parser.codeTextColor = self.style.codeTextColor;
        parser.linkTextColor = self.style.linkTextColor;
        textView.textParser = parser;
        self.markdownParser = parser;
    }
    
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
    fakeBar.alpha = self.style.standardAlpha;
    fakeBar.backgroundColor = self.style.statusBarColor;
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
    circleCloseBtn.backgroundColor = self.style.buttonBackgroundColor;
    circleCloseBtn.tintColor = self.style.buttonTintColor;
    circleCloseBtn.alpha = self.style.standardAlpha - 0.2;
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
    circleApproveBtn.backgroundColor = self.style.buttonBackgroundColor;
    circleApproveBtn.tintColor = self.style.buttonTintColor;
    circleApproveBtn.alpha = self.style.standardAlpha - 0.2;
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
    circleBackBtn.backgroundColor = self.style.buttonBackgroundColor;
    circleBackBtn.tintColor = self.style.buttonTintColor;
    circleBackBtn.alpha = self.style.standardAlpha - 0.2;
    circleBackBtn.image = [[UIImage imageNamed:@"56-back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    circleBackBtn.layer.masksToBounds = YES;
    circleBackBtn.layer.cornerRadius = circleBackBtn.frame.size.height / 2;
    circleBackBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Back button is not visible */
    circleBackBtn.alpha = 0.0;
    circleBackBtn.hidden = YES;
    
    /* Tap gesture of back button */
    UITapGestureRecognizer *tapBackBtn = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(closeFreehandButtonTapped:)];
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
    circleSaveBtn.backgroundColor = self.style.buttonBackgroundColor;
    circleSaveBtn.tintColor = self.style.buttonTintColor;
    circleSaveBtn.alpha = self.style.standardAlpha - 0.2;
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
    titleLabel.textColor = self.style.dateLabelTextColor;
    titleLabel.font = [text.font fontWithSize:self.style.cardTitleFontSize];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Init of Current Date */
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:self.style.cardCreateTimeFormat];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    titleLabel.text = [dateFormatter stringFromDate:self.card.created_at_object];
    
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
        if (self.card.newcard) [textView selectAll:nil];
    });
    
    // 为什么要在这里滚动到最顶部一次其实我也不是很清楚
    [textView scrollToTop];
    
    // 设置输入区域属性
    self.inputViewType = kCourtesyInputViewDefault;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.textView addObserver:self forKeyPath:@"typingAttributes" options:NSKeyValueObservingOptionNew context:nil];
    [[YYTextKeyboardManager defaultManager] addObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.textView removeObserver:self forKeyPath:@"typingAttributes"];
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

#pragma mark - Text Attributes Holder

//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary<NSString *,id> *)change
//                       context:(void *)context
//{
//    if ([keyPath isEqualToString:@"typingAttributes"]) {
//        self.textView.typingAttributes = self.originalAttributes;
//    } else {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}

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

#pragma mark - Floating Actions & Navigation Bar Items

- (void)closeComposeView:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO;
        self.circleApproveBtn.selected = NO;
        self.editable = YES;
        if (!self.textView.isFirstResponder) [self.textView becomeFirstResponder];
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
        if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:^() { [self.view removeAllSubviews]; }];
    }
}

- (void)doneComposeView:(UIButton *)sender {
    if (sender.selected) {
        [self serialize];
    } else {
        if (self.textView.text.length >= self.style.maxContentLength) {
            [self.view makeToast:@"卡片内容太多了喔"
                        duration:kStatusBarNotificationTime
                        position:CSToastPositionCenter];
            return;
        } else if (self.textView.text.length <= 0) {
            [self.view makeToast:@"再说点儿什么吧"
                        duration:kStatusBarNotificationTime
                        position:CSToastPositionCenter];
            return;
        }
        if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
        sender.selected = YES;
        self.circleCloseBtn.selected = YES;
        self.editable = NO;
        self.circleSaveBtn.hidden = NO;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.5 animations:^{
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.circleSaveBtn.alpha = strongSelf.style.standardAlpha - 0.2;
        } completion:nil];
        [self.view makeToast:@"发布前预览"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
    }
}

- (void)savePreview:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    [self performSelectorInBackground:@selector(generateTextViewLayer) withObject:nil];
}

- (void)generateTextViewLayer {
    CGSize imageSize = CGSizeMake(self.textView.yyContainerView.frame.size.width, self.textView.yyContainerView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0); // Retina Support
    CALayer *originalLayer = self.textView.yyContainerView.layer;
    originalLayer.backgroundColor = [UIColor clearColor].CGColor;
    [originalLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *originalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CourtesyCardPreviewGenerator *generator = [CourtesyCardPreviewGenerator new];
    generator.delegate = self;
    generator.previewStyle = self.style.previewStyle;
    generator.contentImage = originalImage;
    [generator generate];
}

#pragma mark - Media Elements

- (void)addNewImageButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if (self.inputViewType != kCourtesyInputViewImageSheet) {
        self.inputViewType = kCourtesyInputViewImageSheet;
        sender.tintColor = self.style.toolbarHighlightColor;
        self.fontButton.tintColor =
        self.audioButton.tintColor =
        self.videoButton.tintColor =
        self.urlButton.tintColor =
        self.drawButton.tintColor =
        self.alignmentButton.tintColor = self.style.toolbarTintColor;
        CourtesyImageSheetView *imageView = [[CourtesyImageSheetView alloc] initWithFrame:CGRectMake(self.keyboardFrame.origin.x, self.keyboardFrame.origin.y + self.toolbar.frame.size.height, self.keyboardFrame.size.width, self.keyboardFrame.size.height - self.toolbar.size.height) andDelegate:self];
        self.textView.inputView = imageView;
    } else {
        self.inputViewType = kCourtesyInputViewDefault;
        sender.tintColor = self.style.toolbarTintColor;
        self.textView.inputView = nil;
    }
    [self.textView reloadInputViews];
    if (![self.textView isFirstResponder]) [self.textView becomeFirstResponder];
}

- (void)addNewAudioButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if (self.inputViewType != kCourtesyInputViewAudioSheet && self.inputViewType != kCourtesyInputViewAudioNote) {
        self.inputViewType = kCourtesyInputViewAudioSheet;
        sender.tintColor = self.style.toolbarHighlightColor;
        self.fontButton.tintColor =
        self.imageButton.tintColor =
        self.videoButton.tintColor =
        self.urlButton.tintColor =
        self.drawButton.tintColor =
        self.alignmentButton.tintColor = self.style.toolbarTintColor;
        CourtesyAudioSheetView *audioView = [[CourtesyAudioSheetView alloc] initWithFrame:CGRectMake(self.keyboardFrame.origin.x, self.keyboardFrame.origin.y + self.toolbar.frame.size.height, self.keyboardFrame.size.width, self.keyboardFrame.size.height - self.toolbar.size.height) andDelegate:self];
        self.textView.inputView = audioView;
    } else {
        self.inputViewType = kCourtesyInputViewDefault;
        sender.tintColor = self.style.toolbarTintColor;
        self.textView.inputView = nil;
    }
    [self.textView reloadInputViews];
    if (![self.textView isFirstResponder]) [self.textView becomeFirstResponder];
}

- (void)addNewVideoButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if (self.inputViewType != kCourtesyInputViewVideoSheet) {
        self.inputViewType = kCourtesyInputViewVideoSheet;
        sender.tintColor = self.style.toolbarHighlightColor;
        self.fontButton.tintColor =
        self.imageButton.tintColor =
        self.audioButton.tintColor =
        self.urlButton.tintColor =
        self.drawButton.tintColor =
        self.alignmentButton.tintColor = self.style.toolbarTintColor;
        CourtesyVideoSheetView *videoView = [[CourtesyVideoSheetView alloc] initWithFrame:CGRectMake(self.keyboardFrame.origin.x, self.keyboardFrame.origin.y + self.toolbar.frame.size.height, self.keyboardFrame.size.width, self.keyboardFrame.size.height - self.toolbar.size.height) andDelegate:self];
        self.textView.inputView = videoView;
    } else {
        self.inputViewType = kCourtesyInputViewDefault;
        sender.tintColor = self.style.toolbarTintColor;
        self.textView.inputView = nil;
    }
    [self.textView reloadInputViews];
    if (![self.textView isFirstResponder]) [self.textView becomeFirstResponder];
}

#pragma mark - Freehand

- (void)closeFreehandButtonTapped:(UIGestureRecognizer *)sender {
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
                         strongSelf.circleApproveBtn.alpha = strongSelf.style.standardAlpha - 0.2;
                         strongSelf.circleCloseBtn.alpha = strongSelf.style.standardAlpha - 0.2;
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

- (void)openFreehandButtonTapped:(UIBarButtonItem *)sender {
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
                         strongSelf.circleBackBtn.alpha = strongSelf.style.standardAlpha - 0.2;
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

#pragma mark - Font & Alignment

- (void)fontButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if (self.inputViewType != kCourtesyInputViewFontSheet) {
        self.inputViewType = kCourtesyInputViewFontSheet;
        sender.tintColor = self.style.toolbarHighlightColor;
        self.audioButton.tintColor =
        self.imageButton.tintColor =
        self.videoButton.tintColor =
        self.urlButton.tintColor =
        self.drawButton.tintColor =
        self.alignmentButton.tintColor = self.style.toolbarTintColor;
        CourtesyFontSheetView *fontView = [[CourtesyFontSheetView alloc] initWithFrame:CGRectMake(self.keyboardFrame.origin.x, self.keyboardFrame.origin.y + self.toolbar.frame.size.height, self.keyboardFrame.size.width, self.keyboardFrame.size.height - self.toolbar.size.height) andDelegate:self];
        self.textView.inputView = fontView;
    } else {
        self.inputViewType = kCourtesyInputViewDefault;
        sender.tintColor = self.style.toolbarTintColor;
        self.textView.inputView = nil;
    }
    [self.textView reloadInputViews];
    if (![self.textView isFirstResponder]) [self.textView becomeFirstResponder];
}

- (void)addUrlButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if (!self.markdownParser) {
        [self.view makeToast:@"未启用 Markdown 支持"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if ([self.textView isFirstResponder]) [self.textView resignFirstResponder];
    NSRange range = self.textView.selectedRange;
    __block NSString *selectedText = nil;
    if (range.length > 0) {
        selectedText = [self.textView textInRange:[YYTextRange rangeWithRange:range]];
    }
    LGAlertView *urlAlert = [[LGAlertView alloc] initWithTextFieldsAndTitle:@"添加链接或引用源"
                                                                    message:nil
                                                         numberOfTextFields:2
                                                     textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
                                                         if (index == 0) {
                                                             textField.placeholder = @"标题";
                                                             if (selectedText && ![selectedText isUrl] && ![selectedText isEmail]) {
                                                                 textField.text = selectedText;
                                                             }
                                                         } else if (index == 1) {
                                                             textField.placeholder = @"网址、邮箱地址或引用源";
                                                             if (selectedText && ([selectedText isUrl] || [selectedText isEmail])) {
                                                                 textField.text = selectedText;
                                                             }
                                                         }
                                                     } buttonTitles:@[@"确认"]
                                                          cancelButtonTitle:@"取消"
                                                     destructiveButtonTitle:nil
                                                                   delegate:self];
    [urlAlert showAnimated:YES completionHandler:nil];
}

- (void)alignButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if (self.card.card_data.alignmentType == NSTextAlignmentLeft) {
        self.card.card_data.alignmentType = NSTextAlignmentCenter;
    } else if (self.card.card_data.alignmentType == NSTextAlignmentCenter) {
        self.card.card_data.alignmentType = NSTextAlignmentRight;
    } else {
        self.card.card_data.alignmentType = NSTextAlignmentLeft;
    }
    NSString *alignmentImageName = nil;
    if (self.card.card_data.alignmentType == NSTextAlignmentLeft) {
        alignmentImageName = @"46-align-left";
    } else if (self.card.card_data.alignmentType == NSTextAlignmentCenter) {
        alignmentImageName = @"48-align-center";
    } else {
        alignmentImageName = @"47-align-right";
    }
    [sender setImage:[UIImage imageNamed:alignmentImageName]];
    [self setTextViewAlignment:self.card.card_data.alignmentType];
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
    [self.textView setTextAlignment:alignment];
}

#pragma mark - LGAlertViewDelegate

- (void)alertViewCancelled:(LGAlertView *)alertView {
    if (![self.textView isFirstResponder]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.textView becomeFirstResponder];
        });
    }
}

- (void)alertView:(LGAlertView *)alertView buttonPressedWithTitle:(NSString *)title index:(NSUInteger)index {
    if (index == 0) {
        if (
            [alertView.textFieldsArray objectAtIndex:0]
            && [[alertView.textFieldsArray objectAtIndex:0] isKindOfClass:[UITextField class]]
            && [alertView.textFieldsArray objectAtIndex:1]
            && [[alertView.textFieldsArray objectAtIndex:1] isKindOfClass:[UITextField class]]
            ) {
            NSRange range = self.textView.selectedRange;
            NSString *title = [(UITextField *)[alertView.textFieldsArray objectAtIndex:0] text];
            NSString *url = [(UITextField *)[alertView.textFieldsArray objectAtIndex:1] text];
            NSString *insert_str = nil;
            if ([url isUrl] || [url isEmail]) {
                insert_str = [NSString stringWithFormat:@"[%@] (%@)", title, url];
            } else {
                insert_str = [NSString stringWithFormat:@"[%@]: %@", title, url];
            }
            [self.textView replaceRange:[YYTextRange rangeWithRange:range] withText:insert_str];
        }
    }
}

#pragma mark - AudioNoteRecorderDelegate

- (void)audioNoteRecorderDidCancel:(CourtesyAudioNoteRecorderView *)audioNoteRecorder {
    self.inputViewType = kCourtesyInputViewAudioSheet;
    self.audioButton.tintColor = self.style.toolbarHighlightColor;
    self.fontButton.tintColor =
    self.imageButton.tintColor =
    self.videoButton.tintColor =
    self.urlButton.tintColor =
    self.drawButton.tintColor =
    self.alignmentButton.tintColor = self.style.toolbarTintColor;
    CourtesyAudioSheetView *audioView = [[CourtesyAudioSheetView alloc] initWithFrame:CGRectMake(self.keyboardFrame.origin.x, self.keyboardFrame.origin.y + self.toolbar.frame.size.height, self.keyboardFrame.size.width, self.keyboardFrame.size.height - self.toolbar.size.height) andDelegate:self];
    self.textView.inputView = audioView;
    [self.textView reloadInputViews];
    if (![self.textView isFirstResponder]) [self.textView becomeFirstResponder];
}

- (void)audioNoteRecorderDidTapDone:(CourtesyAudioNoteRecorderView *)audioNoteRecorder
                    withRecordedURL:(NSURL *)recordedURL {
    if (!self.editable) return;
    self.fontButton.tintColor =
    self.imageButton.tintColor =
    self.videoButton.tintColor =
    self.urlButton.tintColor =
    self.drawButton.tintColor =
    self.alignmentButton.tintColor =
    self.audioButton.tintColor = self.style.toolbarTintColor;
    self.textView.inputView = nil;
    [self.textView reloadInputViews];
    NSURL *newURL = recordedURL;
    [self addNewAudioFrame:newURL at:self.textView.selectedRange animated:YES
                  userinfo:@{@"title": @"Record",
                             @"type": @(CourtesyAttachmentAudio),
                             @"url": newURL }];
}

#pragma mark - CourtesyFontSheetViewDelegate

- (void)fontSheetViewDidCancel:(CourtesyFontSheetView *)fontView {
    if (!self.textView.isFirstResponder) [self.textView becomeFirstResponder];
}

- (void)fontSheetViewDidTapDone:(CourtesyFontSheetView *)fontView withFont:(UIFont *)font {
    [self setNewCardFont:font];
}

- (void)fontSheetView:(CourtesyFontSheetView *)fontView changeFontSize:(CGFloat)size {
    CYLog(@"%.1f", size);
    self.card.card_data.fontSize = size;
    [self setNewCardFont:[_originalFont fontWithSize:size]];
}

#pragma mark - CourtesyAudioSheetViewDelegate

- (void)audioSheetViewRecordButtonTapped:(CourtesyAudioSheetView *)audioSheetView {
    if (!self.editable) return;
    if ([self countOfAudioFrame] >= self.style.maxAudioNum) {
        [self.view makeToast:@"音频数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    self.inputViewType = kCourtesyInputViewAudioNote;
    self.audioButton.tintColor =
    self.imageButton.tintColor =
    self.videoButton.tintColor =
    self.urlButton.tintColor =
    self.drawButton.tintColor =
    self.alignmentButton.tintColor = self.style.toolbarTintColor;
    self.audioButton.tintColor = self.style.toolbarHighlightColor;
    CourtesyAudioNoteRecorderView *audioNoteView = [[CourtesyAudioNoteRecorderView alloc] initWithFrame:CGRectMake(self.keyboardFrame.origin.x, self.keyboardFrame.origin.y + self.toolbar.frame.size.height, self.keyboardFrame.size.width, self.keyboardFrame.size.height - self.toolbar.size.height) andDelegate:self];
    self.textView.inputView = audioNoteView;
    [self.textView reloadInputViews];
    [self.textView becomeFirstResponder];
}

- (void)audioSheetViewMusicButtonTapped:(CourtesyAudioSheetView *)audioSheetView {
    if ([self countOfAudioFrame] >= self.style.maxAudioNum) {
        [self.view makeToast:@"音频数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
    MPMediaPickerController * mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = NO;
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

#pragma mark - CourtesyImageSheetViewDelegate

- (void)imageSheetViewCameraButtonTapped:(CourtesyImageSheetView *)imageSheetView {
    if ([self countOfImageFrame] >= self.style.maxImageNum) {
        [self.view makeToast:@"图片数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imageSheetViewAlbumButtonTapped:(CourtesyImageSheetView *)imageSheetView {
    if ([self countOfImageFrame] >= self.style.maxImageNum) {
        [self.view makeToast:@"图片数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - CourtesyVideoSheetViewDelegate

- (void)videoSheetViewCameraButtonTapped:(CourtesyVideoSheetView *)videoSheetView {
    if ([self countOfVideoFrame] >= self.style.maxVideoNum) {
        [self.view makeToast:@"视频数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo];
    picker.videoMaximumDuration = 30.0;
    picker.videoQuality = [sharedSettings preferredVideoQuality];
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)videoSheetViewShortCameraButtonTapped:(CourtesyVideoSheetView *)videoSheetView {
    if ([self countOfVideoFrame] >= self.style.maxVideoNum) {
        [self.view makeToast:@"视频数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
    WechatShortVideoController *shortVideoController = [WechatShortVideoController new];
    shortVideoController.delegate = self;
    [self presentViewController:shortVideoController animated:YES completion:nil];
}

- (void)videoSheetViewAlbumButtonTapped:(CourtesyVideoSheetView *)videoSheetView {
    if ([self countOfVideoFrame] >= self.style.maxVideoNum) {
        [self.view makeToast:@"视频数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo];
    picker.videoMaximumDuration = 30.0;
    picker.videoQuality = [sharedSettings preferredVideoQuality];
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
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
                if ([item hasProtectedAsset] == NO && [item isCloudItem] == NO)
                { // Common Music
                    __weak typeof(self) weakSelf = self;
                    NSString *tempPath = NSTemporaryDirectory();
                    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
                    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset presetName: AVAssetExportPresetPassthrough];
                    exporter.outputFileType = @"com.apple.coreaudio-format";
                    NSString *fname = [[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]] stringByAppendingString:@".caf"];
                    NSString *exportFile = [tempPath stringByAppendingPathComponent:fname];
                    exporter.outputURL = [NSURL fileURLWithPath:exportFile];
                    [exporter exportAsynchronouslyWithCompletionHandler:^{
                        dispatch_async_on_main_queue(^{
                            __strong typeof(self) strongSelf = weakSelf;
                            [strongSelf addNewAudioFrame:[item assetURL] at:strongSelf.textView.selectedRange animated:YES
                                                userinfo:@{@"title": [item title], // Music
                                                           @"type": @(CourtesyAttachmentAudio),
                                                           @"url": [NSURL fileURLWithPath:exportFile] }];
                        });
                    }];
                }
                else
                { // Apple Music
                    [self.view makeToast:@"请勿选择有版权保护的音乐"
                                duration:kStatusBarNotificationTime
                                position:CSToastPositionCenter];
                }
            }
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
    if ([info hasKey:UIImagePickerControllerMediaType]
        && [info hasKey:UIImagePickerControllerMediaURL]
        && (
            [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie] ||
            [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeVideo]
            ))
    { // 视频或电影
        if (
            [[info objectForKey:UIImagePickerControllerMediaURL] isKindOfClass:[NSURL class]]
            ) {
            __block NSURL *mediaURL = (NSURL *)[info objectForKey:UIImagePickerControllerMediaURL];
            __strong typeof(self) weakSelf = self;
            [picker dismissViewControllerAnimated:YES completion:^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf addNewVideoFrame:mediaURL at:self.textView.selectedRange animated:YES
                                    userinfo:@{@"title": @"Video",
                                               @"type": @(CourtesyAttachmentVideo),
                                               @"url": mediaURL }];
            }];
        }
   } else if ([info hasKey:UIImagePickerControllerMediaType]
              && (
                  [info hasKey:UIImagePickerControllerOriginalImage] ||
                  [info hasKey:UIImagePickerControllerReferenceURL]
                  )
              && (
                  [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]
                  ))
   { // 静态图片、动态图片
       if (
           [info hasKey:UIImagePickerControllerReferenceURL]
           && (
               [[info objectForKey:UIImagePickerControllerReferenceURL] isKindOfClass:[NSURL class]]
           )) { // 从别的什么地方保存的或者相册里的
               __weak typeof(self) weakSelf = self;
               __block NSURL *assetURL = (NSURL *)[info objectForKey:UIImagePickerControllerReferenceURL];
               NSUInteger imageType = CourtesyAttachmentImage; // 静态图
               if ([[[assetURL pathExtension] uppercaseString] isEqualToString:@"GIF"])
               { // 动态图
                   imageType = CourtesyAttachmentAnimatedImage;
               }
               PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[assetURL]
                                                             options:nil] lastObject];
               FYPhotoAsset *fy = [[FYPhotoAsset alloc] initWithPHAsset:asset];
               [fy getOriginalImageData:^(NSData *imageData) {
                   if (imageType == CourtesyAttachmentImage) {
                       float quality = [sharedSettings preferredImageQuality];
                       if (quality != kCourtesyQualityBest) {
                           imageData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], quality);
                       }
                   } // 压缩图片
                   __block YYImage *image = [YYImage imageWithData:imageData];
                   [picker dismissViewControllerAnimated:YES completion:^{
                       __strong typeof(self) strongSelf = weakSelf;
                       [strongSelf addNewImageFrame:image at:strongSelf.textView.selectedRange animated:YES
                                           userinfo:@{@"title": @"Photo",
                                                      @"type": @(imageType),
                                                      @"data": imageData }];
                   }];
               }];
       }
       else if (
                [info hasKey:UIImagePickerControllerOriginalImage]
                && [[info objectForKey:UIImagePickerControllerOriginalImage] isKindOfClass:[UIImage class]]
                ) { // 直接拍摄的，或者是相册里的原画
           NSData *imageData = nil;
           float quality = [sharedSettings preferredImageQuality];
           if (quality != kCourtesyQualityBest) {
               imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], quality);
           } else {
               imageData = [[info objectForKey:UIImagePickerControllerOriginalImage] imageDataRepresentation];
           }
           __block YYImage *image = [YYImage imageWithData:imageData];
           __weak typeof(self) weakSelf = self;
           [picker dismissViewControllerAnimated:YES completion:^{
               __strong typeof(self) strongSelf = weakSelf;
               [strongSelf addNewImageFrame:image at:strongSelf.textView.selectedRange animated:YES
                                   userinfo:@{@"title": @"Camera",
                                              @"type": @(CourtesyAttachmentImage),
                                              @"data": imageData }];
           }];
       }
   }
   else
   { // 不支持的类型
       [picker dismissViewControllerAnimated:YES completion:nil];
   }
}

#pragma mark - WeChatShortVideoDelegate

- (void)cancelWechatShortVideoCapture:(WechatShortVideoController *)controller {
    __weak typeof(self) weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^() {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf.textView.isFirstResponder) [strongSelf.textView becomeFirstResponder];
    }];
}

- (void)finishWechatShortVideoCapture:(WechatShortVideoController *)controller
                                 path:(NSURL *)filePath {
    if (!self.editable) return;
    __block NSURL *newPath = filePath;
    __weak typeof(self) weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
                                       __strong typeof(self) strongSelf = weakSelf;
                                       [strongSelf addNewVideoFrame:newPath at:strongSelf.textView.selectedRange animated:YES
                                                           userinfo:@{@"title": @"Untitled",
                                                                      @"type": @(CourtesyAttachmentVideo),
                                                                      @"url": newPath }];
                                   }];
}

#pragma mark - Audio Frame Builder

- (CourtesyAudioFrameView *)addNewAudioFrame:(NSURL *)url
                                          at:(NSRange)range
                                    animated:(BOOL)animated
                                    userinfo:(NSDictionary *)info {
    if (!self.editable) return nil;
    CourtesyAudioFrameView *frameView = [[CourtesyAudioFrameView alloc] initWithFrame:CGRectMake(0, 0, self.textView.frame.size.width - kComposeLeftInsect - kComposeRightInsect, self.style.cardLineHeight * 2)];
    [frameView setDelegate:self];
    [frameView setUserinfo:info];
    [frameView setCardTintColor:self.style.cardElementTintColor];
    [frameView setCardTintFocusColor:self.style.cardElementTintFocusColor];
    [frameView setCardTextColor:self.style.cardElementTextColor];
    [frameView setCardShadowColor:self.style.cardElementShadowColor];
    [frameView setCardBackgroundColor:self.style.cardElementBackgroundColor];
    [frameView setAutoPlay:self.card.card_data.shouldAutoPlayAudio];
    [frameView setAudioURL:url];
    return [self insertFrameToTextView:frameView at:range animated:animated];
}

#pragma mark - Image Frame Builder

- (CourtesyImageFrameView *)addNewImageFrame:(YYImage *)image
                                          at:(NSRange)range
                                    animated:(BOOL)animated
                                    userinfo:(NSDictionary *)info {
    if (!self.editable) return nil;
    CourtesyImageFrameView *frameView = [[CourtesyImageFrameView alloc] initWithFrame:CGRectMake(0, 0, self.textView.frame.size.width - kComposeLeftInsect - kComposeRightInsect, 0)];
    [frameView setDelegate:self];
    [frameView setUserinfo:info];
    [frameView setCardTintColor:self.style.cardElementTintColor];
    [frameView setCardTextColor:self.style.cardElementTextColor];
    [frameView setCardShadowColor:self.style.cardElementShadowColor];
    [frameView setCardBackgroundColor:self.style.cardElementBackgroundColor];
    [frameView setStandardLineHeight:self.style.cardLineHeight];
    [frameView setEditable:self.editable];
    [frameView setCenterImage:image];
    if (frameView.frame.size.height < self.style.cardLineHeight) return nil;
    return [self insertFrameToTextView:frameView at:range animated:animated];
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
    [frameView setCardTintColor:self.style.cardElementTintColor];
    [frameView setCardTextColor:self.style.cardElementTextColor];
    [frameView setCardShadowColor:self.style.cardElementShadowColor];
    [frameView setCardBackgroundColor:self.style.cardElementBackgroundColor];
    [frameView setStandardLineHeight:self.style.cardLineHeight];
    [frameView setEditable:self.editable];
    [frameView setVideoURL:url];
    return [self insertFrameToTextView:frameView at:range animated:animated];
}

#pragma mark - Insert Frame Helper

- (id)insertFrameToTextView:(UIView *)frameView
                           at:(NSRange)range
                     animated:(BOOL)animated {
    if (!self.editable) return nil;
    if (animated) [frameView setAlpha:0.0];
    // Add Frame View to Text View (Method 1)
    NSMutableString *insertHelper = [[NSMutableString alloc] initWithString:@"\n"];
    int t = floor(frameView.height / self.style.cardLineHeight);
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
    if ([frameView isKindOfClass:[CourtesyImageFrameView class]]) {
        [(CourtesyImageFrameView *)frameView setSelfRange:NSMakeRange(range.location, attachText.length)];
    } else if ([frameView isKindOfClass:[CourtesyAudioFrameView class]]) {
        [(CourtesyAudioFrameView *)frameView setSelfRange:NSMakeRange(range.location, attachText.length)];
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [text insertAttributedString:attachText atIndex:range.location];
    [self.textView setAttributedText:text];
    [self.textView scrollRangeToVisible:range];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{ [frameView setAlpha:1.0]; } completion:nil];
    }
    return frameView;
}

#pragma mark - CourtesyAudioFrameDelegate

- (void)audioFrameTapped:(CourtesyAudioFrameView *)audioFrame { if (self.textView.isFirstResponder) [self.textView resignFirstResponder]; }

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
                                                    [imageViewer.view makeToast:@"图片已保存到「礼记」相簿"
                                                                       duration:kStatusBarNotificationTime
                                                                       position:CSToastPositionCenter];
                                                });
                                            }
                                        } failure:^(NSError * _Nullable error) {
                                            dispatch_async_on_main_queue(^{
                                                [imageViewer.view hideToastActivity];
                                                [imageViewer.view makeToast:[NSString stringWithFormat:@"图片保存失败 - %@", [error localizedDescription]]
                                                                   duration:kStatusBarNotificationTime
                                                                   position:CSToastPositionCenter];
                                            });
                                        }];
}

#pragma mark - CourtesyImageFrameDelegate

- (void)imageFrameTapped:(CourtesyImageFrameView *)imageFrame {
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
    if (!imageFrame.editable) {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.title = imageFrame.labelText;
        if (imageFrame.originalImageURL)
        { // 需要加载远程大图
            imageInfo.placeholderImage = imageFrame.centerImage;
            imageInfo.imageURL = imageFrame.originalImageURL;
        }
        else
        { // 本地图片，判断是否为动态图
            if (
                [imageFrame.userinfo hasKey:@"type"]
                && [[imageFrame.userinfo objectForKey:@"type"] isKindOfClass:[NSNumber class]]
                ) {
                NSUInteger type = [(NSNumber *)[imageFrame.userinfo objectForKey:@"type"] unsignedIntegerValue];
                if (
                    type == CourtesyAttachmentImage
                    || type == CourtesyAttachmentVideo
                    ) { // 如果是静态图或者是视频缩略图
                    imageInfo.image = imageFrame.centerImage;
                }
                else if (type == CourtesyAttachmentAnimatedImage)
                { // 如果是动态图
                    imageInfo.image = [JTSAnimatedGIFUtility animatedImageWithAnimatedGIFData:[imageFrame.userinfo objectForKey:@"data"]];
                }
            }
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
                              by:(YYImage *)image
                        userinfo:(NSDictionary *)userinfo {
    if (!self.editable) return;
    [self imageFrameShouldDeleted:imageFrame animated:NO];
    [self addNewImageFrame:image at:imageFrame.selfRange animated:NO userinfo:userinfo];
}

- (void)imageFrameShouldDeleted:(CourtesyImageFrameView *)imageFrame
                       animated:(BOOL)animated {
    if (!self.editable) return;
    if (!animated) [self removeImageFrameFromTextView:imageFrame];
    else {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{ imageFrame.alpha = 0.0; } completion:^(BOOL finished) {
            if (finished) [weakSelf removeImageFrameFromTextView:imageFrame];
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
        //[mStr deleteCharactersInRange:imageFrame.selfRange];
        [self.textView replaceRange:[YYTextRange rangeWithRange:imageFrame.selfRange] withText:@""];
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

#pragma mark - CourtesyCardPreviewGeneratorDelegate

- (void)generatorDidFinishWorking:(CourtesyCardPreviewGenerator *)generator result:(UIImage *)result {
    [[PHPhotoLibrary sharedPhotoLibrary] saveImage:result
                                           toAlbum:@"礼记"
                                        completion:^(BOOL success) {
                                            if (success) {
                                                dispatch_async_on_main_queue(^{
                                                    [self.view hideToastActivity];
                                                    [self.view makeToast:@"预览图已保存到「礼记」相簿"
                                                                duration:kStatusBarNotificationTime
                                                                position:CSToastPositionCenter];
                                                });
                                            }
                                        } failure:^(NSError * _Nullable error) {
                                            dispatch_async_on_main_queue(^{
                                                [self.view hideToastActivity];
                                                [self.view makeToast:[NSString stringWithFormat:@"预览图保存失败 - %@", [error localizedDescription]]
                                                            duration:kStatusBarNotificationTime
                                                            position:CSToastPositionCenter];
                                            });
                                        }];
}

#pragma mark - Elements Control

#ifdef DEBUG
- (void)listAttachments {
    for (id object in self.textView.textLayout.attachments) {
        if (![object isKindOfClass:[YYTextAttachment class]]) continue;
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
        if (![object isKindOfClass:[YYTextAttachment class]]) continue;
        YYTextAttachment *attachment = (YYTextAttachment *)object;
        if (attachment.content) {
            if ([attachment.content respondsToSelector:@selector(setEditable:)]) {
                if ([attachment.content isMemberOfClass:[CourtesyImageFrameView class]]) {
                    [(CourtesyImageFrameView *)attachment.content setEditable:!locked];
                } else if ([attachment.content isMemberOfClass:[CourtesyVideoFrameView class]]) {
                    [(CourtesyVideoFrameView *)attachment.content setEditable:!locked];
                } else if ([attachment.content isMemberOfClass:[CourtesyAudioFrameView class]]) {
                    [(CourtesyAudioFrameView *)attachment.content pausePlaying];
                }
            }
        }
    }
}

- (NSUInteger)countOfAudioFrame { return [self countOfClass:[CourtesyAudioFrameView class]]; }

- (NSUInteger)countOfImageFrame { return [self countOfClass:[CourtesyImageFrameView class]]; }

- (NSUInteger)countOfVideoFrame { return [self countOfClass:[CourtesyVideoFrameView class]]; }

- (NSUInteger)countOfClass:(Class)class {
#ifdef DEBUG
    [self listAttachments];
#endif
    NSUInteger num = 0;
    for (id object in self.textView.textLayout.attachments) {
        if (![object isKindOfClass:[YYTextAttachment class]]) continue;
        YYTextAttachment *attachment = (YYTextAttachment *)object;
        if (attachment.content && [attachment.content isKindOfClass:class]) num++;
    }
    return num;
}

#pragma mark - Style Modifier

- (BOOL)editable {
    return _card.is_editable;
}

- (CourtesyCardStyleModel *)style {
    return _card.card_data.style;
}

- (void)setNewCardFont:(UIFont *)cardFont {
    if (!cardFont) return;
    CGFloat fontSize = self.card.card_data.fontSize;
    cardFont = [cardFont fontWithSize:fontSize];
    if (self.markdownParser) {
        self.markdownParser.currentFont = cardFont;
        self.markdownParser.fontSize = fontSize;
        self.markdownParser.headerFontSize = fontSize + 8.0;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:self.originalAttributes];
    [dict setObject:cardFont forKey:NSFontAttributeName];
    self.originalAttributes = dict;
    self.originalFont = cardFont;
    self.textView.font = cardFont;
    self.textView.placeholderFont = cardFont;
    self.textView.typingAttributes = self.originalAttributes;
    self.titleLabel.font = [cardFont fontWithSize:12];
}

- (void)setEditable:(BOOL)editable {
    _card.is_editable = editable;
    self.textView.editable = editable;
    [self lockAttachments:!editable];
}

#pragma mark - YYTextViewDelegate

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ((textView.text.length + text.length - range.length) > self.style.maxContentLength) {
        [self.view makeToast:[NSString stringWithFormat:@"超出最大长度限制 (%lu)", self.style.maxContentLength]
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return NO;
    } else if ([text containsString:@"\n"]) {
        self.textView.typingAttributes = self.originalAttributes;
    }
    return YES;
}

#pragma mark - YYTextKeyboardObserver

- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition {
    self.keyboardFrame = transition.toFrame;
}

#pragma mark - Memory Leaks

- (void)dealloc {
    CYLog(@"");
}

- (void)didReceiveMemoryWarning {
    CYLog(@"Memory warning!");
}

#pragma mark - Serialize

- (void)serialize {
    @try {
        [self lockAttachments:YES];
        [self.view setUserInteractionEnabled:NO];
        [self.view makeToastActivity:CSToastPositionCenter];
        NSError *error = nil;
        NSString *targetPath = [[NSURL fileURLWithPath:[[[UIApplication sharedApplication] documentsPath] stringByAppendingPathComponent:@"SavedAttachments"]] path];
        if (![FCFileManager isDirectoryItemAtPath:targetPath])
            [FCFileManager createDirectoriesForPath:targetPath error:&error];
        if (error) {
            @throw NSException(kCourtesyUnexceptedStatus, [error localizedDescription]);
            return;
        }
        CourtesyCardModel *card = self.card;
        card.is_editable = YES;
        card.is_public = [sharedSettings switchAutoPublic];
        card.modified_at_object = [NSDate date];
        if (card.newcard) {
            card.edited_count = 0;
            card.newcard = NO;
        } else {
            card.edited_count++;
        }
        card.card_data.content = self.textView.text;
        NSMutableArray *attachments_arr = [NSMutableArray new];
        for (id object in self.textView.textLayout.attachments) {
            if (![object isKindOfClass:[YYTextAttachment class]]) continue;
            YYTextAttachment *attachment = (YYTextAttachment *)object;
            if (attachment.content) {
                if ([attachment.content isMemberOfClass:[CourtesyImageFrameView class]]) {
                    CourtesyImageFrameView *imageFrameView = (CourtesyImageFrameView *)attachment.content;
                    CourtesyAttachmentType file_type = [[imageFrameView.userinfo objectForKey:@"type"] unsignedIntegerValue];
                    NSData *binary = nil;
                    NSString *ext = nil;
                    if (file_type == CourtesyAttachmentImage) {
                        binary = [imageFrameView.centerImage imageDataRepresentation];
                        ext = @"png";
                    } else if (file_type == CourtesyAttachmentAnimatedImage) {
                        binary = [imageFrameView.userinfo objectForKey:@"data"];
                        ext = @"gif";
                    } else {
                        return;
                    }
                    if (!binary) {
                        @throw NSException(kCourtesyUnexceptedStatus, @"图片解析失败");
                        return;
                    }
                    NSString *salt_hash = [binary sha256String];
                    NSString *file_path = [[targetPath stringByAppendingPathComponent:salt_hash] stringByAppendingPathExtension:ext];
                    [binary writeToFile:file_path options:NSDataWritingAtomic error:&error];
                    if (error) {
                        @throw NSException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                        return;
                    }
                    CourtesyCardAttachmentModel *a = [CourtesyCardAttachmentModel new];
                    a.type = file_type;
                    a.title = [imageFrameView.userinfo objectForKey:@"title"];
                    a.remote_url = nil;
                    a.local_url = [NSURL fileURLWithPath:file_path];
                    a.attachment_id = nil;
                    a.length = imageFrameView.selfRange.length;
                    a.location = imageFrameView.selfRange.location;
                    a.created_at_object = card.modified_at_object;
                    a.salt_hash = salt_hash;
                    [attachments_arr addObject:[a toDictionary]];
                } else if ([attachment.content isMemberOfClass:[CourtesyVideoFrameView class]]) {
                    CourtesyVideoFrameView *videoFrameView = (CourtesyVideoFrameView *)attachment.content;
                    CourtesyAttachmentType file_type = [[videoFrameView.userinfo objectForKey:@"type"] unsignedIntegerValue];
                    NSData *binary = nil;
                    NSURL *originalURL = [videoFrameView.userinfo objectForKey:@"url"];
                    if (!originalURL) {
                        @throw NSException(kCourtesyUnexceptedStatus, @"找不到视频地址");
                        return;
                    }
                    if (file_type == CourtesyAttachmentVideo) {
                        binary = [NSData dataWithContentsOfURL:originalURL
                                                       options:NSDataReadingUncached
                                                         error:&error];
                    } else {
                        return;
                    }
                    if (error || !binary) {
                        @throw NSException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                        return;
                    }
                    NSString *salt_hash = [binary sha256String];
                    NSString *file_path = [[targetPath stringByAppendingPathComponent:salt_hash] stringByAppendingPathExtension:[originalURL pathExtension]];
                    [binary writeToFile:file_path options:NSDataWritingAtomic error:&error];
                    if (error) {
                        @throw NSException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                        return;
                    }
                    CourtesyCardAttachmentModel *a = [CourtesyCardAttachmentModel new];
                    a.type = file_type;
                    a.title = [videoFrameView.userinfo objectForKey:@"title"];
                    a.remote_url = nil;
                    a.local_url = [NSURL fileURLWithPath:file_path];
                    a.attachment_id = nil;
                    a.length = videoFrameView.selfRange.length;
                    a.location = videoFrameView.selfRange.location;
                    a.created_at_object = card.modified_at_object;
                    a.salt_hash = salt_hash;
                    [attachments_arr addObject:[a toDictionary]];
                } else if ([attachment.content isMemberOfClass:[CourtesyAudioFrameView class]]) {
                    CourtesyAudioFrameView *audioFrameView = (CourtesyAudioFrameView *)attachment.content;
                    CourtesyAttachmentType file_type = [[audioFrameView.userinfo objectForKey:@"type"] unsignedIntegerValue];
                    NSData *binary = nil;
                    NSURL *originalURL = [audioFrameView.userinfo objectForKey:@"url"];
                    if (!originalURL) {
                        @throw NSException(kCourtesyUnexceptedStatus, @"找不到音频地址");
                        return;
                    }
                    if (file_type == CourtesyAttachmentAudio) {
                        binary = [NSData dataWithContentsOfURL:originalURL
                                                       options:NSDataReadingUncached
                                                         error:&error];
                    } else {
                        return;
                    }
                    if (error || !binary) {
                        @throw NSException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                        return;
                    }
                    NSString *salt_hash = [binary sha256String];
                    NSString *file_path = [[targetPath stringByAppendingPathComponent:salt_hash] stringByAppendingPathExtension:[originalURL pathExtension]];
                    [binary writeToFile:file_path options:NSDataWritingAtomic error:&error];
                    if (error) {
                        @throw NSException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                        return;
                    }
                    CourtesyCardAttachmentModel *a = [CourtesyCardAttachmentModel new];
                    a.type = file_type;
                    a.title = [audioFrameView.userinfo objectForKey:@"title"];
                    a.remote_url = nil;
                    a.local_url = [NSURL fileURLWithPath:file_path];
                    a.attachment_id = nil;
                    a.length = audioFrameView.selfRange.length;
                    a.location = audioFrameView.selfRange.location;
                    a.created_at_object = card.modified_at_object;
                    a.salt_hash = salt_hash;
                    [attachments_arr addObject:[a toDictionary]];
                }
            }
        }
        card.card_data.attachments = attachments_arr;
        card.local_template = [card.card_data toJSONString];
        CYLog(@"%@", [card toJSONString]);
    }
    @catch (NSException *exception) {
        [self.view makeToast:exception.reason
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
    }
    @finally {
        [self.view hideToastActivity];
        [self.view setUserInteractionEnabled:YES];
    }
}

@end
