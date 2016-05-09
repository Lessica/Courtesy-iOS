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
//#import "CourtesyJotViewController.h"
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
#import "CourtesyCardAuthorHeader.h"
#import "UMSocial.h"

#define kComposeTopInsect 24.0
#define kComposeBottomInsect 24.0
#define kComposeLeftInsect 24.0
#define kComposeRightInsect 24.0
#define kComposeTopBarInsectPortrait 24.0
#define kComposeTopBarInsectUpdated 64.0
#define kComposeCardViewMargin 12.0
#define kComposeCardViewBorderWidth 4.0
#define kComposeCardViewShadowOpacity 0.33
#define kComposeCardViewShadowRadius 4.0
#define kComposeCardViewCornerRadius 10.0
#define kComposeCardViewEditInset UIEdgeInsetsMake(-kComposeCardViewMargin / 2, -kComposeCardViewMargin / 2, -kComposeCardViewMargin / 2, -kComposeCardViewMargin / 2)

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
//    JotViewControllerDelegate,
    JTSImageViewControllerInteractionsDelegate,
    CourtesyCardPreviewGeneratorDelegate,
    CourtesyFontSheetViewDelegate,
    CourtesyAudioSheetViewDelegate,
    CourtesyImageSheetViewDelegate,
    CourtesyVideoSheetViewDelegate,
    LGAlertViewDelegate,
    UMSocialUIDelegate,
    UIPreviewActionItem
>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *cardView;

@property (nonatomic, strong) CourtesyTextView *textView;
@property (nonatomic, strong) CourtesyMarkdownParser *markdownParser;

@property (nonatomic, strong) UIView *fakeBar;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *circleCloseBtn;
@property (nonatomic, strong) UIButton *circleApproveBtn;
@property (nonatomic, strong) UIImageView *circleSaveBtn;
//@property (nonatomic, strong) UIImageView *circleBackBtn;
@property (nonatomic, strong) UIButton *circleLocationBtn;

//@property (nonatomic, strong) UIView *jotView;
//@property (nonatomic, strong) CourtesyJotViewController *jotViewController;

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *audioButton;
@property (nonatomic, strong) UIBarButtonItem *imageButton;
@property (nonatomic, strong) UIBarButtonItem *videoButton;
@property (nonatomic, strong) UIBarButtonItem *urlButton;
//@property (nonatomic, strong) UIBarButtonItem *drawButton;
@property (nonatomic, strong) UIBarButtonItem *fontButton;
@property (nonatomic, strong) UIBarButtonItem *alignmentButton;

@property (nonatomic, strong) CourtesyCardAuthorHeader *authorHeader;
@property (nonatomic, strong) UIScrollView *toolbarContainerView;

@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, assign) CourtesyInputViewType inputViewType;

@end

@implementation CourtesyCardComposeViewController {
    BOOL firstAnimation;
    BOOL firstAppear;
    BOOL isAuthor;
}

- (instancetype)initWithCard:(nullable CourtesyCardModel *)card {
    if (self = [super init]) {
        self.fd_interactivePopDisabled = YES; // 禁用全屏手势
        _card = card;
        _previewContext = NO;
        if (card.author.user_id == kAccount.user_id) {
            isAuthor = YES;
        } else {
            isAuthor = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.delegate && [self.delegate respondsToSelector:@selector(cardComposeViewWillBeginLoading:)]) {
        [self.delegate cardComposeViewWillBeginLoading:self];
    }
    
    /* Init of main view */
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;

    /* Init of background view */
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    if (self.style.darkStyle) {
        backgroundImageView.image = [[UIImage imageNamed:@"street"] imageByBlurDark];
    } else {
        backgroundImageView.image = [[UIImage imageNamed:@"street"] imageByBlurLight];
    }
    
    backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundImageView = backgroundImageView;
    [self.view addSubview:backgroundImageView];

    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    /* Init of Fake Status Bar */
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    UIView *fakeBar = [[UIView alloc] initWithFrame:frame];
    fakeBar.alpha = 0.0;
    fakeBar.backgroundColor = self.style.statusBarColor;
    
    /* Layouts of Fake Status Bar */
    self.fakeBar = fakeBar;
    [self.view addSubview:fakeBar];
    
    /* Init of Card View */
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(kComposeCardViewMargin, (CGFloat) (fakeBar.frame.size.height + kComposeCardViewMargin), (CGFloat) (self.view.frame.size.width - kComposeCardViewMargin * 2), (CGFloat) (self.view.frame.size.height - kComposeCardViewMargin * 2))];
    cardView.backgroundColor = self.style.cardBackgroundColor;
    cardView.layer.masksToBounds = YES;
    cardView.layer.shadowOffset = CGSizeMake(0, 1.5);
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOpacity = kComposeCardViewShadowOpacity;
    cardView.layer.shadowRadius = kComposeCardViewShadowRadius;
    cardView.layer.cornerRadius = kComposeCardViewCornerRadius;
    cardView.layer.shouldRasterize = YES;
    cardView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    /* Layouts of Card View */
    self.cardView = cardView;
    [self.view insertSubview:cardView belowSubview:fakeBar];
    [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(kComposeCardViewEditInset);
    }];
    if (!_previewContext) {
        cardView.transform = CGAffineTransformMakeScale(0.75, 0.75);
    }
    
    /* Elements of tool bar items */
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *myToolBarItems = [NSMutableArray array];
    self.audioButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"45-voice"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewAudioButtonTapped:)];
    [myToolBarItems addObject:self.audioButton]; [myToolBarItems addObject:flexibleSpace];
    self.imageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"36-frame"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewImageButtonTapped:)];
    [myToolBarItems addObject:self.imageButton]; [myToolBarItems addObject:flexibleSpace];
    self.videoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"31-camera"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewVideoButtonTapped:)];
    [myToolBarItems addObject:self.videoButton]; [myToolBarItems addObject:flexibleSpace];
    self.urlButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"37-url"] style:UIBarButtonItemStylePlain target:self action:@selector(addUrlButtonTapped:)];
    [myToolBarItems addObject:self.urlButton]; [myToolBarItems addObject:flexibleSpace];
//    self.drawButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"50-freehand"] style:UIBarButtonItemStylePlain target:self action:@selector(openFreehandButtonTapped:)];
//    [myToolBarItems addObject:self.drawButton]; [myToolBarItems addObject:flexibleSpace];
    self.fontButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"51-font"] style:UIBarButtonItemStylePlain target:self action:@selector(fontButtonTapped:)];
    [myToolBarItems addObject:self.fontButton]; [myToolBarItems addObject:flexibleSpace];
    NSString *alignmentImageName = nil;
    if (self.card.local_template.alignmentType == NSTextAlignmentLeft) alignmentImageName = @"46-align-left";
    else if (self.card.local_template.alignmentType == NSTextAlignmentCenter) alignmentImageName = @"48-align-center";
    else alignmentImageName = @"47-align-right";
    self.alignmentButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:alignmentImageName] style:UIBarButtonItemStylePlain target:self action:@selector(alignButtonTapped:)];
    [myToolBarItems addObject:self.alignmentButton];
    
    /* Init of toolbar */
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width , 40)]; // 根据按钮数量调整，暂时定为两倍
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.barTintColor = self.style.toolbarBarTintColor;
    toolbar.backgroundColor = [UIColor clearColor]; // 工具栏颜色在 toolbarContainerView 中定义
    [toolbar setTintColor:self.style.toolbarTintColor];
    [toolbar setItems:myToolBarItems animated:YES];
    self.toolbar = toolbar;
    
    /* Init of toolbar container view */
    UIScrollView *toolbarContainerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    toolbarContainerView.scrollEnabled = YES;
    toolbarContainerView.alwaysBounceHorizontal = YES;
    toolbarContainerView.showsHorizontalScrollIndicator = NO;
    toolbarContainerView.showsVerticalScrollIndicator = NO;
    toolbarContainerView.backgroundColor = self.style.toolbarColor;
    [toolbarContainerView setContentSize:toolbar.frame.size];
    [toolbarContainerView addSubview:toolbar];
    self.toolbarContainerView = toolbarContainerView;
    
    /* Initial text */
    if (self.card.local_template.content.length == 0) {
        self.card.local_template.content = @"说点什么吧……";
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.card.local_template.content];
    text.font = [[CourtesyFontManager sharedManager] fontWithID:self.card.local_template.fontType];
    if (!text.font) text.font = [UIFont systemFontOfSize:self.card.local_template.fontSize];
    else text.font = [text.font fontWithSize:self.card.local_template.fontSize];
    text.color = self.style.cardTextColor;
    text.lineSpacing = self.style.cardLineSpacing;
    text.paragraphSpacing = self.style.paragraphSpacing;
    text.lineBreakMode = NSLineBreakByWordWrapping;
    text.alignment = self.card.local_template.alignmentType;
    _originalFont = text.font;
    _originalAttributes = text.attributes;
    
    /* Init of text view */
    CourtesyTextView *textView = [[CourtesyTextView alloc] initWithFrame:self.view.frame];
    textView.delegate = self;
    textView.typingAttributes = self.originalAttributes;
    textView.backgroundColor = [UIColor clearColor];
    textView.alwaysBounceVertical = YES;
    textView.showsHorizontalScrollIndicator = NO;
    textView.showsVerticalScrollIndicator = YES;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.attributedText = text;
    
    /* Margin */
    textView.minContentSize = CGSizeMake(0, self.view.frame.size.height);
    textView.textContainerInset = UIEdgeInsetsMake(kComposeTopInsect, kComposeLeftInsect, kComposeBottomInsect, kComposeRightInsect);
    textView.contentInset = UIEdgeInsetsMake(kComposeTopBarInsectPortrait, 0, 0, 0);
    textView.scrollIndicatorInsets = UIEdgeInsetsMake(textView.contentInset.top, 0, 0, kComposeCardViewBorderWidth);
    
    /* Auto correction */
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    /* Paste */
    textView.allowsPasteImage = NO; // 不允许粘贴图片
    textView.allowsPasteAttributedString = NO; // 不允许粘贴富文本
    
    /* Undo & Redo */
    textView.allowsUndoAndRedo = YES;
    textView.maximumUndoLevel = 20;
    
    /* Line height */
    YYTextLinePositionSimpleModifier *mod = [YYTextLinePositionSimpleModifier new];
    mod.fixedLineHeight = self.style.cardLineHeight;
    textView.linePositionModifier = mod;
    
    /* Toolbar */
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
    [cardView addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cardView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [textView scrollToTop];
    
    if ([sharedSettings switchMarkdown]) {
        /* Markdown Support */
        CourtesyMarkdownParser *parser = [CourtesyMarkdownParser new];
        parser.currentFont = text.font;
        parser.fontSize = self.card.local_template.fontSize;
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
    
    /* Init of header view */
    CourtesyCardAuthorHeader *authorHeader = [CourtesyCardAuthorHeader headerWithRefreshingBlock:^{}];
    authorHeader.avatarImageView.imageURL = self.card.author.profile.avatar_url_medium;
    authorHeader.nickLabelView.text = self.card.author.profile.nick;
    authorHeader.nickLabelView.font = [text.font fontWithSize:12.0];
    authorHeader.nickLabelView.textColor = self.style.dateLabelTextColor;
    textView.mj_header = authorHeader;
    self.authorHeader = authorHeader;
    
    /* Tap Gesture of Fake Status Bar */
    UITapGestureRecognizer *tapFakeBar = [[UITapGestureRecognizer alloc] initWithTarget:textView action:@selector(scrollToTop)];
    tapFakeBar.numberOfTouchesRequired = 1;
    tapFakeBar.numberOfTapsRequired = 1;
    [fakeBar addGestureRecognizer:tapFakeBar];
    [fakeBar setUserInteractionEnabled:YES];
    
    /* Init of Jot Scroll View
    UIView *jotView = [[UIView alloc] initWithFrame:self.textView.frame];
    jotView.backgroundColor = [UIColor clearColor];
    jotView.translatesAutoresizingMaskIntoConstraints = NO;
    */
    /* Layout of Jot Scroll View
    self.jotView = jotView;
    [cardView insertSubview:jotView belowSubview:textView];
    [jotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cardView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    */
    /* Init of Jot View Controller
    CourtesyJotViewController *jotViewController = [[CourtesyJotViewController alloc] initWithMasterController:self];
    [self addChildViewController:jotViewController];
    jotViewController.view.frame = jotView.frame;
    [jotView addSubview:jotViewController.view];
    [jotViewController didMoveToParentViewController:self];
    self.jotViewController = jotViewController;
    */
    /* Init of close circle button */
    UIButton *circleCloseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    circleCloseBtn.backgroundColor = self.style.buttonBackgroundColor;
    circleCloseBtn.tintColor = self.style.buttonTintColor;
    circleCloseBtn.alpha = 0.0;
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
    [circleCloseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset((CGFloat) (fakeBar.frame.size.height + kComposeCardViewMargin * 2));
        make.left.equalTo(self.view.mas_left).with.offset((CGFloat) (kComposeCardViewMargin * 2));
        make.width.equalTo(@32);
        make.height.equalTo(@32);
    }];
    
    /* Init of approve circle button */
    UIButton *circleApproveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    circleApproveBtn.backgroundColor = self.style.buttonBackgroundColor;
    circleApproveBtn.tintColor = self.style.buttonTintColor;
    circleApproveBtn.alpha = 0.0;
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
    [circleApproveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset((CGFloat) (fakeBar.frame.size.height + kComposeCardViewMargin * 2));
        make.right.equalTo(self.view.mas_right).with.offset((CGFloat) (-kComposeCardViewMargin * 2));
        make.width.equalTo(@32);
        make.height.equalTo(@32);
    }];
    
    /* Init of back button
    UIImageView *circleBackBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    circleBackBtn.backgroundColor = self.style.buttonBackgroundColor;
    circleBackBtn.tintColor = self.style.buttonTintColor;
    circleBackBtn.alpha = self.style.standardAlpha - 0.2;
    circleBackBtn.image = [[UIImage imageNamed:@"56-back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    circleBackBtn.layer.masksToBounds = YES;
    circleBackBtn.layer.cornerRadius = circleBackBtn.frame.size.height / 2;
    circleBackBtn.translatesAutoresizingMaskIntoConstraints = NO;
     */
    /* Back button is not visible
    circleBackBtn.alpha = 0.0;
    circleBackBtn.hidden = YES;
     */
    /* Tap gesture of back button
    UITapGestureRecognizer *tapBackBtn = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(closeFreehandButtonTapped:)];
    tapBackBtn.numberOfTouchesRequired = 1;
    tapBackBtn.numberOfTapsRequired = 1;
    [circleBackBtn addGestureRecognizer:tapBackBtn];
     */
    /* Enable interaction for back button
    [circleBackBtn setUserInteractionEnabled:YES];
    */
    /* Auto layouts of back button
    self.circleBackBtn = circleBackBtn;
    [self.view addSubview:circleBackBtn];
    [self.view bringSubviewToFront:circleBackBtn];
    [circleBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-kComposeCardViewMargin * 2);
        make.left.equalTo(self.view.mas_left).with.offset(kComposeCardViewMargin * 2);
        make.width.equalTo(@32);
        make.height.equalTo(@32);
    }];
    */
    /* Init of save button */
    UIImageView *circleSaveBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    circleSaveBtn.backgroundColor = self.style.buttonBackgroundColor;
    circleSaveBtn.tintColor = self.style.buttonTintColor;
    circleSaveBtn.alpha = (CGFloat) (self.style.standardAlpha - 0.2);
    circleSaveBtn.image = [[UIImage imageNamed:@"103-down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    circleSaveBtn.layer.masksToBounds = YES;
    circleSaveBtn.layer.cornerRadius = circleSaveBtn.frame.size.height / 2;
    circleSaveBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Save button is not visible */
    circleSaveBtn.alpha = 0.0;
    circleSaveBtn.hidden = YES;
    
    /* Tap gesture of save button */
    UITapGestureRecognizer *tapSaveBtn = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(actionShare:)];
    tapSaveBtn.numberOfTouchesRequired = 1;
    tapSaveBtn.numberOfTapsRequired = 1;
    [circleSaveBtn addGestureRecognizer:tapSaveBtn];
    
    /* Enable interaction for save button */
    [circleSaveBtn setUserInteractionEnabled:YES];
    
    /* Auto layouts of save button */
    self.circleSaveBtn = circleSaveBtn;
    [self.view addSubview:circleSaveBtn];
    [self.view bringSubviewToFront:circleSaveBtn];
    [circleSaveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).with.offset((CGFloat) (-kComposeCardViewMargin * 2));
        make.bottom.equalTo(self.view.mas_bottom).with.offset((CGFloat) (-kComposeCardViewMargin * 2));
        make.width.equalTo(@32);
        make.height.equalTo(@32);
    }];
    
    UIButton *circleLocationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 96, 32)];
    circleLocationBtn.backgroundColor = self.style.buttonBackgroundColor;
    circleLocationBtn.tintColor = self.style.buttonTintColor;
    circleLocationBtn.alpha = (CGFloat) (self.style.standardAlpha - 0.2);
    [circleLocationBtn setImage:[[UIImage imageNamed:@"104-location"]
            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                       forState:UIControlStateNormal];
    [circleLocationBtn setTitle:@"添加位置" forState:UIControlStateNormal];
    [circleLocationBtn setTitleColor:self.style.buttonTintColor forState:UIControlStateNormal];
    circleLocationBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    circleLocationBtn.layer.masksToBounds = YES;
    circleLocationBtn.layer.cornerRadius = circleLocationBtn.frame.size.height / 2;
    circleLocationBtn.translatesAutoresizingMaskIntoConstraints = NO;

    /* Location button is not visible */
    circleLocationBtn.alpha = 0.0;
    circleLocationBtn.hidden = YES;

    /* Touch Event of Location Button */
    [circleLocationBtn setTarget:self action:@selector(locationButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    /* Auto layouts of location button */
    self.circleLocationBtn = circleLocationBtn;
    [self.view addSubview:circleLocationBtn];
    [self.view bringSubviewToFront:circleLocationBtn];
    [circleLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset((CGFloat) (kComposeCardViewMargin * 2));
        make.bottom.equalTo(self.view.mas_bottom).with.offset((CGFloat) (-kComposeCardViewMargin * 2));
        make.width.equalTo(@96);
        make.height.equalTo(@32);
    }];

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
    titleLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.card.created_at]];
    
    /* Auto layouts of Title Label */
    self.dateFormatter = dateFormatter;
    self.titleLabel = titleLabel;
    [textView addSubview:titleLabel];
    [textView bringSubviewToFront:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textView.mas_top).with.offset(0);
        make.centerX.equalTo(textView.mas_centerX).with.offset(0);
        make.width.equalTo(@240);
        make.height.equalTo(@24);
    }];

    /* Load Card Attachments */
    for (CourtesyCardAttachmentModel *attachment in self.card.local_template.attachments) {
        if (attachment.type == CourtesyAttachmentAudio) {
            NSError *err = nil;
            NSString *localPath = [attachment attachmentPath];
            if ([FCFileManager isReadableItemAtPath:localPath]) {
                
            } else { // 下载卡片音频资源
                NSData *audioData = nil;
                audioData = [NSData dataWithContentsOfURL:[attachment remoteAttachmentURL]
                                                options:NSDataReadingMappedAlways
                                                  error:&err];
                [audioData writeToFile:localPath atomically:YES];
                NSAssert(audioData != nil && err == nil, @"Cannot load audioData!");
            }
            [self addNewAudioFrame:[attachment attachmentURL]
                                at:NSMakeRange(attachment.location, attachment.length)
                          animated:NO
                          userinfo:@{
                                     @"title": attachment.title ? attachment.title : @"",
                                     @"type": @(attachment.type),
                                     @"url": [attachment attachmentURL],
                                     }];
        } else if (attachment.type == CourtesyAttachmentImage || attachment.type == CourtesyAttachmentAnimatedImage) {
            NSError *err = nil;
            NSData *imgData = nil;
            NSString *localPath = [attachment attachmentPath];
            if ([FCFileManager isReadableItemAtPath:localPath]) {
                imgData = [NSData dataWithContentsOfFile:localPath
                                                 options:NSDataReadingMappedAlways
                                                   error:&err];
            } else { // 下载卡片图像资源
                imgData = [NSData dataWithContentsOfURL:[attachment remoteAttachmentURL]
                                                options:NSDataReadingMappedAlways
                                                  error:&err];
                [imgData writeToFile:localPath atomically:YES];
            }
            NSAssert(imgData != nil && err == nil, @"Cannot load imgData!");
            YYImage *img = [YYImage imageWithData:imgData];
            [self addNewImageFrame:img
                                at:NSMakeRange(attachment.location, attachment.length)
                          animated:NO
                          userinfo:@{
                                     @"title": attachment.title ? attachment.title : @"",
                                     @"type": @(attachment.type),
                                     @"url": [attachment attachmentURL],
                                     @"data": imgData
                                     }];
        } else if (attachment.type == CourtesyAttachmentVideo) {
            NSError *err = nil;
            NSString *localPath = [attachment attachmentPath];
            if ([FCFileManager isReadableItemAtPath:localPath]) {
                
            } else { // 下载卡片视频资源
                NSData *videoData = nil;
                videoData = [NSData dataWithContentsOfURL:[attachment remoteAttachmentURL]
                                                  options:NSDataReadingMappedAlways
                                                    error:&err];
                [videoData writeToFile:localPath atomically:YES];
                NSAssert(videoData != nil && err == nil, @"Cannot load videoData!");
            }
            [self addNewVideoFrame:[attachment attachmentURL]
                                at:NSMakeRange(attachment.location, attachment.length)
                          animated:NO
                          userinfo:@{
                                     @"title": attachment.title ? attachment.title : @"",
                                     @"type": @(attachment.type),
                                     @"url": [attachment attachmentURL],
                                     }];
        }/* else if (attachment.type == CourtesyAttachmentDraw) {

        } */else {
            continue;
        }
    }
    
    // 设置输入区域属性
    _cardEdited = NO;
    firstAnimation = YES;
    firstAppear = YES;
    [[YYTextKeyboardManager defaultManager] addObserver:self];
    self.inputViewType = kCourtesyInputViewDefault;

    if (self.delegate && [self.delegate respondsToSelector:@selector(cardComposeViewDidFinishLoading:)]) {
        [self.delegate cardComposeViewDidFinishLoading:self];
    }
}

#pragma mark - view events

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.textView addObserver:self forKeyPath:@"typingAttributes" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (firstAppear && !_previewContext) {
        [self doCardViewAnimation:YES];
        firstAppear = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [self.textView removeObserver:self forKeyPath:@"typingAttributes"];
}

#pragma mark - animation

- (void)doCardViewAnimation:(BOOL)animated {
    if (animated) {
        self.textView.minContentSize = CGSizeMake(0, self.cardView.frame.size.height);
        [UIView beginAnimations:@"startEditing" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationWillStartSelector:@selector(animationDidStart:)];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
        [UIView setAnimationDelay:0.0f];
        [UIView setAnimationDuration:0.3f];
        self.textView.showsVerticalScrollIndicator = YES;
        self.cardView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.textView.contentInset = UIEdgeInsetsMake(kComposeTopBarInsectUpdated, 0, 0, 0);
        if (firstAnimation) {
            self.fakeBar.alpha = self.style.standardAlpha;
            self.circleApproveBtn.alpha = (CGFloat) (self.style.standardAlpha - 0.2);
            self.circleCloseBtn.alpha = (CGFloat) (self.style.standardAlpha - 0.2);
            [self.textView scrollToTop];
        }
        [UIView commitAnimations];
    } else {
        self.textView.minContentSize = CGSizeMake(0, 0);
        [UIView beginAnimations:@"endEditing" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationWillStartSelector:@selector(animationDidStart:)];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
        [UIView setAnimationDelay:0.0f];
        [UIView setAnimationDuration:0.3f];
        self.textView.showsVerticalScrollIndicator = NO;
        self.cardView.transform = CGAffineTransformMakeScale(0.75, 0.75);
        self.textView.contentInset = UIEdgeInsetsMake(kComposeTopBarInsectPortrait, 0, 0, 0);
        [UIView commitAnimations];
    }
}

- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.editable) {
        if (firstAnimation) {
            firstAnimation = NO;
        }
    }
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

#pragma mark - Floating Actions & Navigation Bar Items

- (void)locationButtonTapped {
    CYLog(@"");
}

- (void)closeComposeView:(UIButton *)sender {
    if (isAuthor) {
        if (sender.selected) {
            self.circleApproveBtn.selected = NO;
            self.circleCloseBtn.selected = NO;
            self.editable = YES;
            [self doCardViewAnimation:YES];
            if (!self.textView.isFirstResponder) [self.textView becomeFirstResponder];
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.5 animations:^{
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.circleSaveBtn.alpha = 0.0;
                strongSelf.circleLocationBtn.alpha = 0.0;
            } completion:^(BOOL finished) {
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.circleSaveBtn.hidden = YES;
                strongSelf.circleLocationBtn.hidden = YES;
            }];
            [self.view makeToast:@"退出预览模式"
                        duration:kStatusBarNotificationTime
                        position:CSToastPositionCenter];
        } else {
            if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
            if (_cardEdited) {
                if (self.textView.text.length >= self.style.maxContentLength) {
                    [self.view makeToast:@"卡片内容太多了喔"
                                duration:kStatusBarNotificationTime
                                position:CSToastPositionCenter];
                    return;
                } else {
                    self.editable = NO;
                    [self serialize];
                }
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardComposeViewDidCancelEditing:shouldSaveToDraftBox:)]) {
                [self.delegate cardComposeViewDidCancelEditing:self shouldSaveToDraftBox:_cardEdited];
            }
        }
    } else {
        if (sender.selected) {
            self.circleCloseBtn.selected = NO;
            self.circleApproveBtn.hidden = NO;
            [self doCardViewAnimation:YES];
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.5 animations:^{
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.circleSaveBtn.alpha = 0.0;
                strongSelf.circleLocationBtn.alpha = 0.0;
                strongSelf.circleApproveBtn.alpha = (CGFloat) (strongSelf.style.standardAlpha - 0.2);
            } completion:^(BOOL finished) {
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.circleSaveBtn.hidden = YES;
                strongSelf.circleLocationBtn.hidden = YES;
            }];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardComposeViewDidCancelEditing:shouldSaveToDraftBox:)]) {
                [self.delegate cardComposeViewDidCancelEditing:self shouldSaveToDraftBox:_cardEdited];
            }
        }
    }
}

- (void)publishCard {
    [self serialize];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardComposeViewDidFinishEditing:)]) {
        [self.delegate cardComposeViewDidFinishEditing:self];
    }
}

- (void)doneComposeView:(UIButton *)sender {
    if (isAuthor) {
        if (sender.selected) {
            [self publishCard];
        } else {
            if (self.textView.text.length >= self.style.maxContentLength) {
                [self.view makeToast:@"卡片内容太多了喔"
                            duration:kStatusBarNotificationTime
                            position:CSToastPositionCenter];
                return;
            } else if (self.textView.text.length <= 0) {
                [self.view makeToast:@"无法发布空白卡片"
                            duration:kStatusBarNotificationTime
                            position:CSToastPositionCenter];
                return;
            }
            if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
            self.circleApproveBtn.selected = YES;
            self.circleCloseBtn.selected = YES;
            self.circleSaveBtn.hidden = NO;
            self.circleLocationBtn.hidden = NO;
            self.editable = NO;
            [self doCardViewAnimation:NO];
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.5 animations:^{
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.circleSaveBtn.alpha = (CGFloat) (strongSelf.style.standardAlpha - 0.2);
                strongSelf.circleLocationBtn.alpha = (CGFloat) (strongSelf.style.standardAlpha - 0.2);
            } completion:nil];
            NSString *type = @"发布";
            if (self.card.hasPublished) {
                type = @"修改";
            }
            [self.view makeToast:[NSString stringWithFormat:@"%@前预览", type]
                        duration:kStatusBarNotificationTime
                        position:CSToastPositionCenter];
        }
    } else {
        if (sender.selected) {
            
        } else {
            self.circleCloseBtn.selected = YES;
            self.circleSaveBtn.hidden = NO;
            self.circleLocationBtn.hidden = NO;
            [self doCardViewAnimation:NO];
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.5 animations:^{
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.circleSaveBtn.alpha = (CGFloat) (strongSelf.style.standardAlpha - 0.2);
                strongSelf.circleLocationBtn.alpha = (CGFloat) (strongSelf.style.standardAlpha - 0.2);
                strongSelf.circleApproveBtn.alpha = 0;
            } completion:^(BOOL finished) {
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.circleApproveBtn.hidden = YES;
            }];
        }
    }
}

- (void)actionShare:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    [self performSelectorInBackground:@selector(generateTextViewLayer:) withObject:self];
}

- (void)generateTextViewLayer:(id)delegate {
    CourtesyCardPreviewGenerator *generator = [CourtesyCardPreviewGenerator new];
    generator.delegate = delegate;
    generator.headerView = self.authorHeader;
    generator.contentView = self.textView.yyContainerView;
    generator.tintColor = [self.style.cardTextColor colorWithAlphaComponent:self.style.standardAlpha];
    [generator generate];
}

#pragma mark - Media Elements

- (void)addNewImageButtonTapped:(UIBarButtonItem *)sender {
    if (self.inputViewType != kCourtesyInputViewImageSheet) {
        self.inputViewType = kCourtesyInputViewImageSheet;
        sender.tintColor = self.style.toolbarHighlightColor;
        self.fontButton.tintColor =
        self.audioButton.tintColor =
        self.videoButton.tintColor =
        self.urlButton.tintColor =
//        self.drawButton.tintColor =
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
    if (self.inputViewType != kCourtesyInputViewAudioSheet && self.inputViewType != kCourtesyInputViewAudioNote) {
        self.inputViewType = kCourtesyInputViewAudioSheet;
        sender.tintColor = self.style.toolbarHighlightColor;
        self.fontButton.tintColor =
        self.imageButton.tintColor =
        self.videoButton.tintColor =
        self.urlButton.tintColor =
//        self.drawButton.tintColor =
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
    if (self.inputViewType != kCourtesyInputViewVideoSheet) {
        self.inputViewType = kCourtesyInputViewVideoSheet;
        sender.tintColor = self.style.toolbarHighlightColor;
        self.fontButton.tintColor =
        self.imageButton.tintColor =
        self.audioButton.tintColor =
        self.urlButton.tintColor =
//        self.drawButton.tintColor =
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
/*
- (void)closeFreehandButtonTapped:(UIGestureRecognizer *)sender {
    [self.jotViewController setState:JotViewStateDefault];
    [self.jotViewController setControlEnabled:NO];
    [self.cardView sendSubviewToBack:self.jotView];
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
    [self.cardView sendSubviewToBack:self.textView];
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
*/
#pragma mark - Font & Alignment

- (void)fontButtonTapped:(UIBarButtonItem *)sender {
    if (self.inputViewType != kCourtesyInputViewFontSheet) {
        self.inputViewType = kCourtesyInputViewFontSheet;
        sender.tintColor = self.style.toolbarHighlightColor;
        self.audioButton.tintColor =
        self.imageButton.tintColor =
        self.videoButton.tintColor =
        self.urlButton.tintColor =
//        self.drawButton.tintColor =
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
    LGAlertView *alertView = [[LGAlertView alloc] initWithTextFieldsAndTitle:@"添加链接或引用源"
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
    SetCourtesyAleryViewStyle(alertView, self.view)
    [alertView showAnimated:YES completionHandler:nil];
}

- (void)alignButtonTapped:(UIBarButtonItem *)sender {
    _cardEdited = YES;
    if (self.card.local_template.alignmentType == NSTextAlignmentLeft) {
        self.card.local_template.alignmentType = NSTextAlignmentCenter;
    } else if (self.card.local_template.alignmentType == NSTextAlignmentCenter) {
        self.card.local_template.alignmentType = NSTextAlignmentRight;
    } else {
        self.card.local_template.alignmentType = NSTextAlignmentLeft;
    }
    NSString *alignmentImageName = nil;
    if (self.card.local_template.alignmentType == NSTextAlignmentLeft) {
        alignmentImageName = @"46-align-left";
    } else if (self.card.local_template.alignmentType == NSTextAlignmentCenter) {
        alignmentImageName = @"48-align-center";
    } else {
        alignmentImageName = @"47-align-right";
    }
    [sender setImage:[UIImage imageNamed:alignmentImageName]];
    [self setTextViewAlignment:self.card.local_template.alignmentType];
}

- (void)setTextViewAlignment:(NSTextAlignment)alignment {
    NSRange range = self.textView.selectedRange;
    if (range.length <= 0 && [self.textView.typingAttributes hasKey:NSParagraphStyleAttributeName]) {
        NSParagraphStyle *paragraphStyle = self.textView.typingAttributes[NSParagraphStyleAttributeName];
        NSMutableParagraphStyle *newParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [newParagraphStyle setParagraphStyle:paragraphStyle];
        newParagraphStyle.alignment = alignment;
        NSMutableDictionary *newTypingAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.textView.typingAttributes];
        newTypingAttributes[NSParagraphStyleAttributeName] = newParagraphStyle;
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
            alertView.textFieldsArray[0]
            && [alertView.textFieldsArray[0] isKindOfClass:[UITextField class]]
            && alertView.textFieldsArray[1]
            && [alertView.textFieldsArray[1] isKindOfClass:[UITextField class]]
            ) {
            NSRange range = self.textView.selectedRange;
            NSString *field_title = [(UITextField *) alertView.textFieldsArray[0] text];
            NSString *url = [(UITextField *) alertView.textFieldsArray[1] text];
            NSString *insert_str = nil;
            if ([url isUrl] || [url isEmail]) {
                insert_str = [NSString stringWithFormat:@"[%@] (%@)", field_title, url];
            } else {
                insert_str = [NSString stringWithFormat:@"[%@]: %@", field_title, url];
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
//    self.drawButton.tintColor =
    self.alignmentButton.tintColor = self.style.toolbarTintColor;
    CourtesyAudioSheetView *audioView = [[CourtesyAudioSheetView alloc] initWithFrame:CGRectMake(self.keyboardFrame.origin.x, self.keyboardFrame.origin.y + self.toolbar.frame.size.height, self.keyboardFrame.size.width, self.keyboardFrame.size.height - self.toolbar.size.height) andDelegate:self];
    self.textView.inputView = audioView;
    [self.textView reloadInputViews];
    if (![self.textView isFirstResponder]) [self.textView becomeFirstResponder];
}

- (void)audioNoteRecorderDidTapDone:(CourtesyAudioNoteRecorderView *)audioNoteRecorder
                    withRecordedURL:(NSURL *)recordedURL {
    self.fontButton.tintColor =
    self.imageButton.tintColor =
    self.videoButton.tintColor =
    self.urlButton.tintColor =
//    self.drawButton.tintColor =
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
    self.card.local_template.fontSize = size;
    [self setNewCardFont:[_originalFont fontWithSize:size]];
}

#pragma mark - CourtesyAudioSheetViewDelegate

- (void)audioSheetViewRecordButtonTapped:(CourtesyAudioSheetView *)audioSheetView {
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
//    self.drawButton.tintColor =
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
//    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
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
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.view makeToast:@"当前设备不支持拍照"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
//    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
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
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self.view makeToast:@"当前设备不支持相册"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
//    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
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
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.view makeToast:@"当前设备不支持摄像"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
//    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
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
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.view makeToast:@"当前设备不支持摄像"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
//    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
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
//    if (self.textView.isFirstResponder) [self.textView resignFirstResponder];
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
    if (!mediaItemCollection) return;
    if (mediaItemCollection.count == 1) {
        if (mediaItemCollection.mediaTypes <= MPMediaTypeAnyAudio) {
            for (MPMediaItem *item in [mediaItemCollection items]) {
                if (![item isCloudItem])
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
    if ([info hasKey:UIImagePickerControllerMediaType]
        && [info hasKey:UIImagePickerControllerMediaURL]
        && (
            [info[UIImagePickerControllerMediaType] isEqualToString:(NSString *) kUTTypeMovie] ||
            [info[UIImagePickerControllerMediaType] isEqualToString:(NSString *) kUTTypeVideo]
            ))
    { // 视频或电影
        if (
            [info[UIImagePickerControllerMediaURL] isKindOfClass:[NSURL class]]
            ) {
            __block NSURL *mediaURL = (NSURL *) info[UIImagePickerControllerMediaURL];
            __strong typeof(self) weakSelf = self;
            [picker dismissViewControllerAnimated:YES completion:^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf addNewVideoFrame:mediaURL at:self.textView.selectedRange animated:YES
                                    userinfo:@{@"title": @"",
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
                  [info[UIImagePickerControllerMediaType] isEqualToString:(NSString *) kUTTypeImage]
                  ))
   { // 静态图片、动态图片
       if (
           [info hasKey:UIImagePickerControllerReferenceURL]
           && (
               [info[UIImagePickerControllerReferenceURL] isKindOfClass:[NSURL class]]
           )) { // 从别的什么地方保存的或者相册里的
               __weak typeof(self) weakSelf = self;
               __block NSURL *assetURL = (NSURL *) info[UIImagePickerControllerReferenceURL];
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
                       [strongSelf addNewImageFrame:image
                                                 at:strongSelf.textView.selectedRange
                                           animated:YES
                                           userinfo:@{@"title": @"",
                                                      @"type": @(imageType),
                                                      @"data": imageData }];
                   }];
               }];
       }
       else if (
                [info hasKey:UIImagePickerControllerOriginalImage]
                && [info[UIImagePickerControllerOriginalImage] isKindOfClass:[UIImage class]]
                ) { // 直接拍摄的，或者是相册里的原画
           NSData *imageData = nil;
           float quality = [sharedSettings preferredImageQuality];
           if (quality != kCourtesyQualityBest) {
               imageData = UIImageJPEGRepresentation(info[UIImagePickerControllerOriginalImage], quality);
           } else {
               imageData = [info[UIImagePickerControllerOriginalImage] imageDataRepresentation];
           }
           __block YYImage *image = [YYImage imageWithData:imageData];
           __weak typeof(self) weakSelf = self;
           [picker dismissViewControllerAnimated:YES completion:^{
               __strong typeof(self) strongSelf = weakSelf;
               [strongSelf addNewImageFrame:image
                                         at:strongSelf.textView.selectedRange
                                   animated:YES
                                   userinfo:@{@"title": @"",
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
    __block NSURL *newPath = filePath;
    __weak typeof(self) weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
                                       __strong typeof(self) strongSelf = weakSelf;
                                       [strongSelf addNewVideoFrame:newPath at:strongSelf.textView.selectedRange animated:YES
                                                           userinfo:@{@"title": @"",
                                                                      @"type": @(CourtesyAttachmentVideo),
                                                                      @"url": newPath }];
                                   }];
}

#pragma mark - Audio Frame Builder

- (CourtesyAudioFrameView *)addNewAudioFrame:(NSURL *)url
                                          at:(NSRange)range
                                    animated:(BOOL)animated
                                    userinfo:(NSDictionary *)info {
    CourtesyAudioFrameView *frameView = [[CourtesyAudioFrameView alloc] initWithFrame:CGRectMake(0, 0, (CGFloat) (self.textView.frame.size.width - kComposeLeftInsect - kComposeRightInsect), self.style.cardLineHeight * 2) andDelegate:self andUserinfo:info];
    [frameView setAudioURL:url];
    return [self insertFrameToTextView:frameView
                                    at:range
                              animated:animated];
}

#pragma mark - Image Frame Builder

- (CourtesyImageFrameView *)addNewImageFrame:(YYImage *)image
                                          at:(NSRange)range
                                    animated:(BOOL)animated
                                    userinfo:(NSDictionary *)info {
    CourtesyImageFrameView *frameView = [[CourtesyImageFrameView alloc] initWithFrame:CGRectMake(0, 0, (CGFloat) (self.textView.frame.size.width - kComposeLeftInsect - kComposeRightInsect), 0) andDelegate:self andUserinfo:info];
    [frameView setCenterImage:image];
    if (frameView.frame.size.height < self.style.cardLineHeight) return nil;
    return [self insertFrameToTextView:frameView
                                    at:range
                              animated:animated];
}

#pragma mark - Video Frame Builder

- (CourtesyVideoFrameView *)addNewVideoFrame:(NSURL *)url
                                          at:(NSRange)range
                                    animated:(BOOL)animated
                                    userinfo:(NSDictionary *)info {
    CourtesyVideoFrameView *frameView = [[CourtesyVideoFrameView alloc] initWithFrame:CGRectMake(0, 0, (CGFloat) (self.textView.frame.size.width - kComposeLeftInsect - kComposeRightInsect), 0) andDelegate:self andUserinfo:info];
    [frameView setVideoURL:url];
    return [self insertFrameToTextView:frameView at:range animated:animated];
}

#pragma mark - Insert Frame Helper

- (id)insertFrameToTextView:(UIView *)frameView
                         at:(NSRange)range
                   animated:(BOOL)animated {
    if (animated) [frameView setAlpha:0.0];
    // Add Frame View to Text View (Method 1)
    NSMutableString *insertHelper = [[NSMutableString alloc] initWithString:@"\n"];
    int t = (int) floor(frameView.height / self.style.cardLineHeight);
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
        [(CourtesyImageFrameView *)frameView setBindingLength:attachText.length];
    } else if ([frameView isKindOfClass:[CourtesyAudioFrameView class]]) {
        [(CourtesyAudioFrameView *)frameView setBindingLength:attachText.length];
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    if (range.length != 0 && range.location + range.length <= text.length) {
        [text replaceCharactersInRange:range withAttributedString:attachText];
    } else if (range.location <= text.length) {
        [text insertAttributedString:attachText atIndex:range.location];
    } else {
        CYLog(@"Insert Error!");
    }
    CYLog(@"attachment: location = %lu, length = %lu", (unsigned long) range.location, (unsigned long) attachText.length);
    [self.textView setAttributedText:text];
    if (animated) {
        [self.textView setSelectedRange:NSMakeRange(range.location + attachText.length, 0)];
        [self.textView scrollRangeToVisible:NSMakeRange(range.location, range.length)];
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
    if (!self.editable) {
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
                && [imageFrame.userinfo[@"type"] isKindOfClass:[NSNumber class]]
                ) {
                NSUInteger type = [(NSNumber *) imageFrame.userinfo[@"type"] unsignedIntegerValue];
                if (
                    type == CourtesyAttachmentImage
                    || type == CourtesyAttachmentVideo
                    ) { // 如果是静态图或者是视频缩略图
                    imageInfo.image = imageFrame.centerImage;
                }
                else if (type == CourtesyAttachmentAnimatedImage)
                { // 如果是动态图
                    imageInfo.image = [JTSAnimatedGIFUtility animatedImageWithAnimatedGIFData:imageFrame.userinfo[@"data"]];
                }
            }
        }
        imageInfo.referenceRect = imageFrame.centerImageView.frame;
        imageInfo.referenceView = imageFrame;
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                           mode:JTSImageViewControllerMode_Image
                                                                                backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        imageViewer.interactionsDelegate = self;
        [imageViewer showFromViewController:self
                                 transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
}

- (void)imageFrameShouldReplaced:(CourtesyImageFrameView *)imageFrame
                              by:(YYImage *)image
                        userinfo:(NSDictionary *)userinfo {
    NSRange beforeRange = [self getAttachmentRange:imageFrame];
    [self imageFrameShouldDeleted:imageFrame
                         animated:NO];
    [self addNewImageFrame:image
                        at:NSMakeRange(beforeRange.location, 0)
                  animated:NO
                  userinfo:@{
                             @"title": [userinfo hasKey:@"title"] ? userinfo[@"title"] : @"",
                             @"type": @(CourtesyAttachmentImage),
                             @"data": [image imageDataRepresentation]
                             }];
}

- (void)imageFrameShouldDeleted:(CourtesyImageFrameView *)imageFrame
                       animated:(BOOL)animated {
    if (!animated) [self removeImageFrameFromTextView:imageFrame];
    else {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{ imageFrame.alpha = 0.0; } completion:^(BOOL finished) {
            if (finished) [weakSelf removeImageFrameFromTextView:imageFrame];
        }];
    }
}

- (void)removeImageFrameFromTextView:(CourtesyImageFrameView *)imageFrame {
    CYLog(@"%@", self.textView.textLayout.attachments);
    [imageFrame removeFromSuperview];
    NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:[self.textView attributedText]];
    NSRange allRange = [mStr rangeOfAll];
    NSRange selfRange = [self getAttachmentRange:imageFrame];
    if (selfRange.location >= allRange.location &&
        selfRange.location + selfRange.length <= allRange.location + allRange.length) {
        [self.textView replaceRange:[YYTextRange rangeWithRange:selfRange] withText:@""];
    }
}

- (void)imageFrameShouldCropped:(CourtesyImageFrameView *)imageFrame {
    PECropViewController *cropViewController = [[PECropViewController alloc] init];
    cropViewController.delegate = imageFrame;
    cropViewController.image = imageFrame.centerImage;
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:cropViewController];
    [self presentViewController:navc
                       animated:YES
                     completion:nil];
}

- (void)imageFrameDidBeginEditing:(CourtesyImageFrameView *)imageFrame {
    _cardEdited = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect rect = [self getAttachmentRect:imageFrame];
        CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height + self.view.frame.size.height / 2, rect.size.width, 24);
        [self.textView scrollRectToVisible:newRect
                                  animated:YES];
    });
}

- (void)imageFrameDidEndEditing:(CourtesyImageFrameView *)imageFrame {
    
}

#pragma mark - UMSocialUIDelegate

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    if (response.responseCode == UMSResponseCodeSuccess) {
        
    }
    
}

#pragma mark - CourtesyCardPreviewGeneratorDelegate

- (void)generatorDidFinishWorking:(CourtesyCardPreviewGenerator *)generator result:(UIImage *)result {
    if ([sharedSettings switchPreviewAutoSave]) {
        [[PHPhotoLibrary sharedPhotoLibrary] saveImage:result
                                               toAlbum:@"礼记"
                                            completion:^(BOOL success) {
                                                if (success) {
                                                    dispatch_async_on_main_queue(^{
                                                        if (_previewContext) {
                                                            [JDStatusBarNotification showWithStatus:@"预览图已保存到「礼记」相簿"
                                                                                       dismissAfter:kStatusBarNotificationTime
                                                                                          styleName:JDStatusBarStyleSuccess];
                                                        } else {
                                                            [self.view hideToastActivity];
                                                            [self.view makeToast:@"预览图已保存到「礼记」相簿"
                                                                        duration:kStatusBarNotificationTime
                                                                        position:CSToastPositionCenter];
                                                        }
                                                    });
                                                }
                                            } failure:^(NSError * _Nullable error) {
                                                dispatch_async_on_main_queue(^{
                                                    if (_previewContext) {
                                                        [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"预览图保存失败 - %@", [error localizedDescription]]
                                                                                   dismissAfter:kStatusBarNotificationTime
                                                                                      styleName:JDStatusBarStyleError];
                                                    } else {
                                                        [self.view hideToastActivity];
                                                        [self.view makeToast:[NSString stringWithFormat:@"预览图保存失败 - %@", [error localizedDescription]]
                                                                    duration:kStatusBarNotificationTime
                                                                    position:CSToastPositionCenter];
                                                    }
                                                });
                                            }];
    }
    if (!_previewContext && result) {
        dispatch_async_on_main_queue(^{
            [self.view hideToastActivity];
            NSString *shareUrl = [NSString stringWithFormat:API_CARD_SHARE, self.card.token];
            [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
            [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
            [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:UMENG_APP_KEY
                                              shareText:[NSString stringWithFormat:@"「礼记」卡片分享：%@", shareUrl]
                                             shareImage:result
                                        shareToSnsNames:@[UMShareToEmail, UMShareToQQ, UMShareToQzone, UMShareToSina]
                                               delegate:self];
        });
    }
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

- (NSRange)getAttachmentRange:(id)atta {
    NSUInteger index = 0;
    for (id object in self.textView.textLayout.attachments) {
        if (![object isKindOfClass:[YYTextAttachment class]]) continue;
        YYTextAttachment *attachment = (YYTextAttachment *)object;
        id obj = attachment.content;
        if (obj == atta) {
            NSValue *range_val = self.textView.textLayout.attachmentRanges[index];
            NSRange range = [range_val rangeValue];
            NSUInteger bindingLength = 0;
            if ([obj isMemberOfClass:[CourtesyImageFrameView class]]) {
                bindingLength = [(CourtesyImageFrameView *)obj bindingLength];
            } else if ([obj isMemberOfClass:[CourtesyAudioFrameView class]]) {
                bindingLength = [(CourtesyAudioFrameView *)obj bindingLength];
            } else if ([obj isMemberOfClass:[CourtesyVideoFrameView class]]) {
                bindingLength = [(CourtesyVideoFrameView *)obj bindingLength];
            }
            NSRange realRange = NSMakeRange(range.location - bindingLength + 2, range.length + bindingLength - 1);
            CYLog(@"attachment: location = %lu, length = %lu", (unsigned long) realRange.location, (unsigned long) realRange.length);
            return realRange;
        }
        index++;
    }
    return NSMakeRange(0, 0);
}

- (CGRect)getAttachmentRect:(id)atta {
    NSUInteger index = 0;
    for (id object in self.textView.textLayout.attachments) {
        if (![object isKindOfClass:[YYTextAttachment class]]) continue;
        YYTextAttachment *attachment = (YYTextAttachment *)object;
        id obj = attachment.content;
        if (obj == atta) {
            NSValue *rect_val = self.textView.textLayout.attachmentRects[index];
            CGRect rect = [rect_val CGRectValue];
            return rect;
        }
        index++;
    }
    return CGRectMake(0, 0, 0, 0);
}

- (void)syncAttachmentsStyle {
    for (id object in self.textView.textLayout.attachments) {
        if (![object isKindOfClass:[YYTextAttachment class]]) continue;
        YYTextAttachment *attachment = (YYTextAttachment *)object;
        if (attachment.content) {
            if ([attachment.content respondsToSelector:@selector(reloadStyle)]) {
                objc_msgSend(attachment.content, @selector(reloadStyle));
            }
        }
    }
    self.authorHeader.nickLabelView.font = [_originalFont fontWithSize:12.0];
//    [self.jotViewController reloadStyle];
}

- (void)pauseAttachmentAudio {
    for (id object in self.textView.textLayout.attachments) {
        if (![object isKindOfClass:[YYTextAttachment class]]) continue;
        YYTextAttachment *attachment = (YYTextAttachment *)object;
        if (attachment.content) {
            if ([attachment.content respondsToSelector:@selector(pausePlaying)]) {
                objc_msgSend(attachment.content, @selector(pausePlaying));
            }
        }
    }
//    [self.jotViewController reloadStyle];
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
    return (_card.is_editable && isAuthor);
}

- (CourtesyCardDataModel *)cdata {
    return _card.local_template;
}

- (CourtesyCardStyleModel *)style {
    return _card.local_template.style;
}

- (void)setNewCardFont:(UIFont *)cardFont {
    if (!cardFont) return;
    _cardEdited = YES;
    CGFloat fontSize = self.card.local_template.fontSize;
    cardFont = [cardFont fontWithSize:fontSize];
    if (self.markdownParser) {
        self.markdownParser.currentFont = cardFont;
        self.markdownParser.fontSize = fontSize;
        self.markdownParser.headerFontSize = (CGFloat) (fontSize + 8.0);
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:self.originalAttributes];
    dict[NSFontAttributeName] = cardFont;
    _originalAttributes = dict;
    _originalFont = cardFont;
    self.textView.font = cardFont;
    self.textView.placeholderFont = cardFont;
    self.textView.typingAttributes = self.originalAttributes;
    self.titleLabel.font = [cardFont fontWithSize:12];
    [self syncAttachmentsStyle];
}

- (void)setEditable:(BOOL)editable {
    if (isAuthor) {
        if (editable == NO) {
            self.textView.inputAccessoryView = nil;
        } else {
            self.textView.inputAccessoryView = self.toolbarContainerView;
        }
        _card.is_editable = editable;
        self.textView.editable = editable;
        [self syncAttachmentsStyle];
    }
}

#pragma mark - YYTextViewDelegate

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ((textView.text.length + text.length - range.length) > self.style.maxContentLength) {
        [self.view makeToast:[NSString stringWithFormat:@"超出最大长度限制 (%lu)", (unsigned long)self.style.maxContentLength]
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return NO;
    } else if ([text containsString:@"\n"]) {
        self.textView.typingAttributes = self.originalAttributes;
    }
    if (!_cardEdited) {
        _cardEdited = YES;
    }
    return YES;
}

#pragma mark - YYTextKeyboardObserver

- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition {
    if (self.inputViewType == kCourtesyInputViewDefault) {
        self.keyboardFrame = transition.toFrame;
    }
}

#pragma mark - Memory Leaks

- (void)dealloc {
    CYLog(@"");
    if (!isAuthor) return;
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    CYLog(@"Memory warning!");
}

#pragma mark - Serialize

- (void)serialize {
    if (!isAuthor) return;
    @try {
        [self syncAttachmentsStyle];
        [self.view setUserInteractionEnabled:NO];
        [self.view makeToastActivity:CSToastPositionCenter];
        NSError *error = nil;
        CourtesyCardModel *card = self.card;
        card.modified_at = (NSUInteger) [[NSDate date] timeIntervalSince1970];
        if (card.isNewCard) {
            card.edited_count = 0;
            card.isNewCard = NO;
        } else {
            card.edited_count++;
        }
        card.local_template.content = self.textView.text;
        NSMutableArray *attachments_arr = [NSMutableArray new];
        for (id object in self.textView.textLayout.attachments) {
            if (![object isKindOfClass:[YYTextAttachment class]]) continue;
            YYTextAttachment *attachment = (YYTextAttachment *)object;
            if (attachment.content) {
                if ([attachment.content isMemberOfClass:[CourtesyImageFrameView class]]) {
                    CourtesyImageFrameView *imageFrameView = (CourtesyImageFrameView *)attachment.content;
                    CourtesyAttachmentType file_type = (CourtesyAttachmentType) [[imageFrameView.userinfo objectForKey:@"type"] unsignedIntegerValue];
                    NSData *binary = imageFrameView.userinfo[@"data"];
                    if (!binary) {
                        @throw NSCustomException(kCourtesyUnexceptedStatus, @"图片解析失败");
                        return;
                    }
                    
                    NSString *salt_hash = [binary sha256String];
                    
                    CourtesyCardAttachmentModel *a = [[CourtesyCardAttachmentModel alloc] initWithSaltHash:salt_hash fromDatabase:NO];
                    a.card_token = card.token;
                    a.type = file_type;
                    a.title = imageFrameView.labelText;
                    a.attachment_id = nil;
                    NSRange selfRange = [self getAttachmentRange:imageFrameView];
                    a.length = selfRange.length;
                    a.location = selfRange.location;
                    [attachments_arr addObject:a];
                    
                    NSString *file_path = [a attachmentPath];
                    if (![FCFileManager existsItemAtPath:file_path]) {
                        [binary writeToFile:file_path options:NSDataWritingWithoutOverwriting error:&error];
                        if (error) {
                            @throw NSCustomException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                            return;
                        }
                    }
                } else if ([attachment.content isMemberOfClass:[CourtesyVideoFrameView class]]) {
                    CourtesyVideoFrameView *videoFrameView = (CourtesyVideoFrameView *)attachment.content;
                    CourtesyAttachmentType file_type = (CourtesyAttachmentType) [videoFrameView.userinfo[@"type"] unsignedIntegerValue];
                    NSData *binary = nil;
                    NSURL *originalURL = videoFrameView.userinfo[@"url"];
                    if (!originalURL) {
                        @throw NSCustomException(kCourtesyUnexceptedStatus, @"找不到视频地址");
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
                        @throw NSCustomException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                        return;
                    }
                    NSString *salt_hash = [binary sha256String];
                    
                    CourtesyCardAttachmentModel *a = [[CourtesyCardAttachmentModel alloc] initWithSaltHash:salt_hash fromDatabase:NO];
                    a.card_token = card.token;
                    a.type = file_type;
                    a.title = videoFrameView.labelText;
                    a.attachment_id = nil;
                    NSRange selfRange = [self getAttachmentRange:videoFrameView];
                    a.length = selfRange.length;
                    a.location = selfRange.location;
                    [attachments_arr addObject:a];
                    
                    NSString *file_path = [a attachmentPath];
                    if (![FCFileManager existsItemAtPath:file_path]) {
                        [binary writeToFile:file_path options:NSDataWritingWithoutOverwriting error:&error];
                        if (error) {
                            @throw NSCustomException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                            return;
                        }
                    }
                    
                    // 保存视频缩略图
                    NSString *videoThumbnailPath = [a thumbnailPathWithSize:CGSizeMake(0, 0)];
                    if (![FCFileManager existsItemAtPath:videoThumbnailPath]) {
                        UIImage *originalImage = videoFrameView.centerImage;
                        CGFloat length = (originalImage.size.width > originalImage.size.height) ? originalImage.size.height : originalImage.size.width;
                        CGSize size = CGSizeMake(length, length);
                        UIImage *resizedImage = [originalImage imageByResizeToSize:size contentMode:UIViewContentModeScaleAspectFit];
                        NSData *thumbnailBinary = [resizedImage imageDataRepresentation];
                        [thumbnailBinary writeToFile:videoThumbnailPath
                                             options:NSDataWritingWithoutOverwriting
                                               error:&error];
                        if (error) {
                            @throw NSCustomException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                            return;
                        }
                    }
                } else if ([attachment.content isMemberOfClass:[CourtesyAudioFrameView class]]) {
                    CourtesyAudioFrameView *audioFrameView = (CourtesyAudioFrameView *)attachment.content;
                    CourtesyAttachmentType file_type = (CourtesyAttachmentType) [audioFrameView.userinfo[@"type"] unsignedIntegerValue];
                    NSData *binary = nil;
                    NSURL *originalURL = audioFrameView.userinfo[@"url"];
                    if (!originalURL) {
                        @throw NSCustomException(kCourtesyUnexceptedStatus, @"找不到音频地址");
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
                        @throw NSCustomException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                        return;
                    }
                    NSString *salt_hash = [binary sha256String];
                    
                    CourtesyCardAttachmentModel *a = [[CourtesyCardAttachmentModel alloc] initWithSaltHash:salt_hash fromDatabase:NO];
                    a.card_token = card.token;
                    a.type = file_type;
                    a.title = audioFrameView.labelText;
                    a.attachment_id = nil;
                    NSRange selfRange = [self getAttachmentRange:audioFrameView];
                    a.length = selfRange.length;
                    a.location = selfRange.location;
                    [attachments_arr addObject:a];
                    
                    NSString *file_path = [a attachmentPath];
                    if (![FCFileManager existsItemAtPath:file_path]) {
                        [binary writeToFile:file_path options:NSDataWritingWithoutOverwriting error:&error];
                        if (error) {
                            @throw NSCustomException(kCourtesyUnexceptedStatus, [error localizedDescription]);
                            return;
                        }
                    }
                }
            }
        }
        card.local_template.attachments = [attachments_arr copy];
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

#pragma mark - UIPreviewActionItem

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    if (isAuthor) {
        NSString *type = @"发布";
        if (self.card.hasPublished) {
            type = @"修改";
        }
        
        UIPreviewAction *tap1 = [UIPreviewAction actionWithTitle:type style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            [self publishCard];
            // TODO: Publish card selected.
        }];
        
        UIPreviewAction *tap2 = [UIPreviewAction actionWithTitle:@"保存到相册" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            [self performSelectorInBackground:@selector(generateTextViewLayer:) withObject:previewViewController];
        }];
        
        NSArray *taps = @[tap1, tap2];
        
        return taps;
    } else {
        UIPreviewAction *tap2 = [UIPreviewAction actionWithTitle:@"保存到相册" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            [self performSelectorInBackground:@selector(generateTextViewLayer:) withObject:previewViewController];
        }];
        
        NSArray *taps = @[tap2];
        
        return taps;
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self pauseAttachmentAudio];
        }
    }
}

@end
