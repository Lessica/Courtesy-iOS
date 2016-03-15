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
#import "AudioNoteRecorderViewController.h"
#import "JTSImageViewController.h"
#import "JTSAnimatedGIFUtility.h"
#import "CourtesyCardPreviewGenerator.h"
#import "CourtesyTextView.h"
#import "CourtesyFontTableViewController.h"
#import "CourtesyMarkdownParser.h"

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
    AudioNoteRecorderDelegate,
    CourtesyImageFrameDelegate,
    WechatShortVideoDelegate,
    JotViewControllerDelegate,
    JTSImageViewControllerInteractionsDelegate,
    CourtesyCardPreviewGeneratorDelegate,
    CourtesyFontViewControllerDelegate
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
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width * 1.5 , 40)]; // 根据按钮数量调整，暂时定为两倍
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.barTintColor = self.style.toolbarBarTintColor;
    toolbar.backgroundColor = [UIColor clearColor]; // 工具栏颜色在 toolbarContainerView 中定义
    
    /* Elements of tool bar items */ // 定义按钮元素及其样式
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *myToolBarItems = [NSMutableArray array];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"45-voice"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewAudioButtonTapped:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"36-frame"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewImageButtonTapped:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"31-camera"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewVideoButtonTapped:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"37-url"] style:UIBarButtonItemStylePlain target:self action:@selector(addUrlButtonTapped:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"50-freehand"] style:UIBarButtonItemStylePlain target:self action:@selector(openFreehandButtonTapped:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"51-font"] style:UIBarButtonItemStylePlain target:self action:@selector(fontButtonTapped:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"46-align-left"] style:UIBarButtonItemStylePlain target:self action:@selector(alignLeftButtonTapped:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"48-align-center"] style:UIBarButtonItemStylePlain target:self action:@selector(alignCenterButtonTapped:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"47-align-right"] style:UIBarButtonItemStylePlain target:self action:@selector(alignRightButtonTapped:)]];
    [toolbar setTintColor:tryValue(self.style.toolbarTintColor, [UIColor grayColor])];
    [toolbar setItems:myToolBarItems animated:YES];
    
    /* Initial text */
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.card.card_data.content];
    text.font = [UIFont systemFontOfSize:[self.style.cardFontSize floatValue]];
    text.color = self.style.cardTextColor;
    text.lineSpacing = [self.style.cardLineSpacing floatValue];
    text.lineBreakMode = NSLineBreakByWordWrapping;
    self.originalFont = self.style.cardFont;
    self.originalAttributes = tryValue(self.style.cardContentAttributes, text.attributes);
    
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
    mod.fixedLineHeight = [self.style.cardLineHeight floatValue];
    textView.linePositionModifier = mod;
    
    /* Toolbar */
    [toolbarContainerView setContentSize:toolbar.frame.size];
    [toolbarContainerView addSubview:toolbar];
    textView.inputAccessoryView = self.editable ? toolbarContainerView : nil;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    /* Place holder */
    textView.placeholderText = self.style.placeholderText;
    textView.placeholderTextColor = self.style.placeholderColor;
    
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
    
    /* Markdown Support */
    CourtesyMarkdownParser *parser = [CourtesyMarkdownParser new];
    parser.currentFont = self.style.cardFont;
    parser.fontSize = [self.style.cardFontSize floatValue];
    parser.headerFontSize = [self.style.headerFontSize floatValue];
    parser.textColor = self.style.cardTextColor;
    parser.controlTextColor = self.style.controlTextColor;
    parser.headerTextColor = self.style.headerTextColor;
    parser.inlineTextColor = self.style.inlineTextColor;
    parser.codeTextColor = self.style.codeTextColor;
    parser.linkTextColor = self.style.linkTextColor;
    textView.textParser = parser;
    self.markdownParser = parser;
    
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
    fakeBar.alpha = [self.style.standardAlpha floatValue];
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
    circleCloseBtn.alpha = [self.style.standardAlpha floatValue] - 0.2;
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
    circleApproveBtn.alpha = [self.style.standardAlpha floatValue] - 0.2;
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
    circleBackBtn.alpha = [self.style.standardAlpha floatValue] - 0.2;
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
    circleSaveBtn.alpha = [self.style.standardAlpha floatValue] - 0.2;
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
    titleLabel.font = [UIFont systemFontOfSize:[self.style.cardTitleFontSize floatValue]];
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
    });
    
    // 为什么要在这里滚动到最顶部一次其实我也不是很清楚
    [textView scrollToTop];
}

/*
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
*/

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
#warning "Send"
    } else {
        if (self.textView.text.length >= [self.style.maxContentLength integerValue]) {
            [self.view makeToast:@"卡片内容太多了喔"
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
            strongSelf.circleSaveBtn.alpha = [strongSelf.style.standardAlpha floatValue] - 0.2;
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
    if ([self countOfImageFrame] >= [self.style.maxImageNum integerValue]) {
        [self.view makeToast:@"图片数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
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
                                                                    picker.mediaTypes = @[(NSString *)kUTTypeImage];
                                                                    picker.delegate = strongSelf;
                                                                    picker.allowsEditing = NO;
                                                                    [strongSelf presentViewController:picker animated:YES completion:nil];
                                                                } else {
                                                                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                    picker.mediaTypes = @[(NSString *)kUTTypeImage];
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

- (void)addNewAudioButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if ([self countOfAudioFrame] >= [self.style.maxAudioNum integerValue]) {
        [self.view makeToast:@"音频数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
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
                                                      [self addChildViewController:vc];
                                                      [self.view addSubview:vc.view];
                                                      [vc didMoveToParentViewController:self];
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

- (void)addNewVideoButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    if ([self countOfVideoFrame] >= [self.style.maxVideoNum integerValue]) {
        [self.view makeToast:@"视频数量已达上限"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
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
                         strongSelf.circleApproveBtn.alpha = [strongSelf.style.standardAlpha floatValue] - 0.2;
                         strongSelf.circleCloseBtn.alpha = [strongSelf.style.standardAlpha floatValue] - 0.2;
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
                         strongSelf.circleBackBtn.alpha = [strongSelf.style.standardAlpha floatValue] - 0.2;
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
    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
    CourtesyFontTableViewController *vc = [[CourtesyFontTableViewController alloc] initWithMasterViewController:self];
    vc.delegate = self;
    vc.fitSize = [self.style.cardFontSize floatValue];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}

- (void)addUrlButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    __block NSRange range = self.textView.selectedRange;
    if ([self.textView isFirstResponder]) [self.textView resignFirstResponder];
    __weak typeof(self) weakSelf = self;
    LGAlertView *urlAlert = [[LGAlertView alloc] initWithTextFieldsAndTitle:@"添加链接"
                                                                    message:@"请键入链接标题、网址或电子邮箱地址"
                                                         numberOfTextFields:2
                                                     textFieldsSetupHandler:^(UITextField *textField, NSUInteger index) {
                                                         if (index == 0) {
                                                             textField.placeholder = @"标题";
                                                         } else if (index == 1) {
                                                             textField.placeholder = @"网址或电子邮箱地址";
                                                         }
                                                     } buttonTitles:@[@"确认"]
                                                          cancelButtonTitle:@"取消"
                                                     destructiveButtonTitle:nil
                                                              actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                                  __strong typeof(self) strongSelf = weakSelf;
                                                                  if (index == 0) {
                                                                      if (
                                                                          [alertView.textFieldsArray objectAtIndex:0]
                                                                          && [[alertView.textFieldsArray objectAtIndex:0] isKindOfClass:[UITextField class]]
                                                                          && [alertView.textFieldsArray objectAtIndex:1]
                                                                          && [[alertView.textFieldsArray objectAtIndex:1] isKindOfClass:[UITextField class]]
                                                                          ) {
                                                                          NSString *title = [(UITextField *)[alertView.textFieldsArray objectAtIndex:0] text];
                                                                          NSString *url = [(UITextField *)[alertView.textFieldsArray objectAtIndex:1] text];
                                                                          NSString *insert_str = [NSString stringWithFormat:@"[%@] (%@)", title, url];
                                                                          [strongSelf.textView replaceRange:[YYTextRange rangeWithRange:range] withText:insert_str];
                                                                      }
                                                                  }
                                                              } cancelHandler:^(LGAlertView *alertView) {
                                                                  __strong typeof(self) strongSelf = weakSelf;
                                                                  if (![strongSelf.textView isFirstResponder]) [strongSelf.textView becomeFirstResponder];
                                                              } destructiveHandler:nil];
    [urlAlert showAnimated:YES completionHandler:nil];
}

- (void)alignLeftButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    [self setTextViewAlignment:NSTextAlignmentLeft];
}

- (void)alignCenterButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    [self setTextViewAlignment:NSTextAlignmentCenter];
}

- (void)alignRightButtonTapped:(UIBarButtonItem *)sender {
    if (!self.editable) return;
    [self setTextViewAlignment:NSTextAlignmentRight];
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
//    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[self.textView attributedText]];
//    [string setAlignment:alignment];
//    [self.textView setSelectedRange:range];
//    [self.textView scrollRangeToVisible:range];
}

#pragma mark - AudioNoteRecorderDelegate

- (void)audioNoteRecorderDidCancel:(AudioNoteRecorderViewController *)audioNoteRecorder {
    [audioNoteRecorder.view removeFromSuperview];
    [audioNoteRecorder removeFromParentViewController];
    if (!self.textView.isFirstResponder) [self.textView becomeFirstResponder];
}

- (void)audioNoteRecorderDidTapDone:(AudioNoteRecorderViewController *)audioNoteRecorder
                    withRecordedURL:(NSURL *)recordedURL {
    if (!self.editable) return;
    [audioNoteRecorder.view removeFromSuperview];
    [audioNoteRecorder removeFromParentViewController];
    NSURL *newURL = recordedURL;
    [self addNewAudioFrame:newURL at:self.textView.selectedRange animated:YES
                  userinfo:@{@"title": @"Record",
                             @"type": @(CourtesyAttachmentAudio),
                             @"url": newURL }];
}

#pragma mark - CourtesyFontViewControllerDelegate

- (void)fontViewControllerDidCancel:(CourtesyFontTableViewController *)fontViewController {
    [fontViewController.view removeFromSuperview];
    [fontViewController removeFromParentViewController];
    if (!self.textView.isFirstResponder) [self.textView becomeFirstResponder];
}

- (void)fontViewControllerDidTapDone:(CourtesyFontTableViewController *)fontViewController
                            withFont:(UIFont *)font { [self setNewCardFont:font]; }

- (void)fontViewController:(CourtesyFontTableViewController *)fontViewController
            changeFontSize:(CGFloat)size {
    CYLog(@"%.1f", size);
    self.style.cardFontSize = [NSNumber numberWithFloat:size];
    [self setNewCardFont:[_originalFont fontWithSize:[self.style.cardFontSize floatValue]]];
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
                    [self addNewAudioFrame:[item assetURL] at:self.textView.selectedRange animated:YES
                                  userinfo:@{@"title": [item title], // Music
                                             @"type": @(CourtesyAttachmentAudio),
                                             @"url": [item assetURL] }];
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
           __block YYImage *image = (YYImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
           __weak typeof(self) weakSelf = self;
           [picker dismissViewControllerAnimated:YES completion:^{
               __strong typeof(self) strongSelf = weakSelf;
               [strongSelf addNewImageFrame:image at:strongSelf.textView.selectedRange animated:YES
                                   userinfo:@{@"title": @"Camera",
                                              @"type": @(CourtesyAttachmentImage),
                                              @"data": [image imageDataRepresentation] }];
           }];
       }
   }
   else
   { // 不支持的类型
       [picker dismissViewControllerAnimated:YES completion:nil];
   }
}

#pragma mark - WeChatShortVideoDelegate

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
    CourtesyAudioFrameView *frameView = [[CourtesyAudioFrameView alloc] initWithFrame:CGRectMake(0, 0, self.textView.frame.size.width - kComposeLeftInsect - kComposeRightInsect, [self.style.cardLineHeight floatValue] * 2)];
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
    [frameView setStandardLineHeight:[self.style.cardLineHeight floatValue]];
    [frameView setEditable:self.editable];
    [frameView setCenterImage:image];
    if (frameView.frame.size.height < [self.style.cardLineHeight floatValue]) return nil;
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
    [frameView setStandardLineHeight:[self.style.cardLineHeight floatValue]];
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
    int t = floor(frameView.height / [self.style.cardLineHeight floatValue]);
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
    [text replaceCharactersInRange:range withAttributedString:attachText];
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
    CGFloat fontSize = [self.style.cardFontSize floatValue];
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
    self.textView.typingAttributes = self.originalAttributes;
    self.titleLabel.font = [cardFont fontWithSize:12];
}

- (void)setEditable:(BOOL)editable {
    _card.is_editable = editable;
    self.textView.editable = editable;
    [self lockAttachments:!editable];
}
/*
#pragma mark - YYTextKeyboardObserver

- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition {
    
}
*/
#pragma mark - Memory Leaks

- (void)dealloc {
    CYLog(@"");
}

- (void)didReceiveMemoryWarning {
    CYLog(@"Memory warning!");
}

@end
