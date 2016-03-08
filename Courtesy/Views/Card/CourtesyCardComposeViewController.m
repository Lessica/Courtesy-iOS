//
//  CourtesyCardComposeViewController.m
//  Courtesy
//
//  Created by Zheng on 3/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

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

#define kComposeDefaultFontSize 16
#define kComposeDefaultLineSpacing 8
#define kComposeLineHeight 28
#define kComposeTopInsect 24
#define kComposeBottomInsect 24
#define kComposeLeftInsect 24
#define kComposeRightInsect 24
#define kComposeTopBarInsectPortrait 64
#define kComposeTopBarInsectLandscape 48

@interface CourtesyCardComposeViewController () <YYTextViewDelegate, YYTextKeyboardObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CourtesyImageFrameDelegate, WechatShortVideoDelegate, MPMediaPickerControllerDelegate, CourtesyAudioFrameDelegate, AudioNoteRecorderDelegate>
@property (nonatomic, assign) YYTextView *textView;
@property (nonatomic, strong) UIView *fakeBar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *circleCloseBtn;
@property (nonatomic, strong) UIImageView *circleApproveBtn;
@property (nonatomic, strong) CourtesyJotViewController *jotViewController;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDictionary *originalAttributes;
@property (nonatomic, strong) UIFont *originalFont;

@end

@implementation CourtesyCardComposeViewController

- (instancetype)init {
    if (self = [super init]) {
        self.fd_interactivePopDisabled = YES;
        self.title = @"新卡片";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Init of main view */
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    //self.modalPresentationCapturesStatusBarAppearance = NO;
    self.edgesForExtendedLayout =  UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    
    /* Init of Navigation Bar Items (if there is a navigation bar actually) */
    UIBarButtonItem *item = [UIBarButtonItem new];
    item.image = [UIImage imageNamed:@"30-send"];
    item.target = self;
    item.action = @selector(done:);
    self.navigationItem.rightBarButtonItem = item;
    
    /* Init of toolbar container view */
    UIScrollView *toolbarContainerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    toolbarContainerView.scrollEnabled = YES;
    toolbarContainerView.alwaysBounceHorizontal = YES;
    toolbarContainerView.showsHorizontalScrollIndicator = NO;
    toolbarContainerView.showsVerticalScrollIndicator = NO;
    toolbarContainerView.backgroundColor = [UIColor whiteColor];
    
    /* Init of toolbar */
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width * 2, 40)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.barTintColor = [UIColor whiteColor];
    toolbar.backgroundColor = [UIColor clearColor];
    
    /* Elements of tool bar items */
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *myToolBarItems = [NSMutableArray array];
    
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"45-voice"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewVoice:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"36-frame"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewFrame:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"31-camera"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewVideo:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"37-url"] style:UIBarButtonItemStylePlain target:self action:@selector(addUrl:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"50-freehand"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleFreehand:)]];
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
    [toolbar setTintColor:[UIColor grayColor]];
    [toolbar setItems:myToolBarItems animated:YES];
    
    /* Initial text */
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"说点什么吧……"];
    text.font = [UIFont systemFontOfSize:kComposeDefaultFontSize];
    text.lineSpacing = kComposeDefaultLineSpacing;
    text.lineBreakMode = NSLineBreakByWordWrapping;
    _originalFont = text.font;
    _originalAttributes = text.attributes;
    
    /* Init of text view */
    YYTextView *textView = [YYTextView new];
    textView.delegate = self;
    textView.typingAttributes = _originalAttributes;
    textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture"]];
    textView.alwaysBounceVertical = YES;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Set initial text */
    textView.attributedText = text;
    textView.textColor = [UIColor darkGrayColor];
    [textView setTypingAttributes:[text attributes]];
    
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
    textView.allowsPasteAttributedString = YES; // 允许粘贴富文本
    
    /* Undo */
    textView.allowsUndoAndRedo = YES;
    textView.maximumUndoLevel = 10;
    
    /* Line height fixed */
    YYTextLinePositionSimpleModifier *mod = [YYTextLinePositionSimpleModifier new];
    mod.fixedLineHeight = kComposeLineHeight;
    textView.linePositionModifier = mod;
    
    /* Toolbar */
    [toolbarContainerView setContentSize:toolbar.frame.size];
    [toolbarContainerView addSubview:toolbar];
    textView.inputAccessoryView = toolbarContainerView;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    /* Place holder */
    textView.placeholderText = @"说点什么吧……";
    textView.placeholderTextColor = [UIColor lightGrayColor];
    
    /* Indicator (Tint Color) */
    textView.tintColor = [UIColor darkGrayColor];
    
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
    
    /* Init of Fake Status Bar */
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    _fakeBar = [[UIView alloc] initWithFrame:frame];
    _fakeBar.alpha = 0.65;
    _fakeBar.backgroundColor = [UIColor blackColor];
    _fakeBar.hidden = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    
    /* Tap Gesture of Fake Status Bar */
    UITapGestureRecognizer *tapFakeBar = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
        if (_textView) {
            [_textView scrollToTopAnimated:YES];
        }
    }];
    tapFakeBar.numberOfTouchesRequired = 1;
    tapFakeBar.numberOfTapsRequired = 1;
    [_fakeBar addGestureRecognizer:tapFakeBar];
    [_fakeBar setUserInteractionEnabled:YES];
    
    /* Layouts of Fake Status Bar */
    [self.view addSubview:_fakeBar];
    [self.view bringSubviewToFront:_fakeBar];
    
    /* Init of close circle button */
    _circleCloseBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    _circleCloseBtn.backgroundColor = [UIColor blackColor];
    _circleCloseBtn.tintColor = [UIColor whiteColor];
    _circleCloseBtn.alpha = 0.45;
    _circleCloseBtn.image = [[UIImage imageNamed:@"39-close-circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _circleCloseBtn.layer.masksToBounds = YES;
    _circleCloseBtn.layer.cornerRadius = _circleCloseBtn.frame.size.height / 2;
    _circleCloseBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Tap gesture of close button */
    UITapGestureRecognizer *tapCloseBtn = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(closeComposeView:)];
    tapCloseBtn.numberOfTouchesRequired = 1;
    tapCloseBtn.numberOfTapsRequired = 1;
    [_circleCloseBtn addGestureRecognizer:tapCloseBtn];
    [_circleCloseBtn setUserInteractionEnabled:YES];
    
    /* Auto layouts of close button */
    [self.view addSubview:_circleCloseBtn];
    [self.view bringSubviewToFront:_circleCloseBtn];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_circleCloseBtn
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_circleCloseBtn
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_circleCloseBtn
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_fakeBar
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_circleCloseBtn
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeadingMargin
                                                         multiplier:1
                                                           constant:0]];
    
    /* Init of approve circle buttons */
    _circleApproveBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    _circleApproveBtn.backgroundColor = [UIColor blackColor];
    _circleApproveBtn.tintColor = [UIColor whiteColor];
    _circleApproveBtn.alpha = 0.45;
    _circleApproveBtn.image = [[UIImage imageNamed:@"40-approve-circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _circleApproveBtn.layer.masksToBounds = YES;
    _circleApproveBtn.layer.cornerRadius = _circleApproveBtn.frame.size.height / 2;
    _circleApproveBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Tap gesture of approve button */
    UITapGestureRecognizer *tapApproveBtn = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(done:)];
    tapApproveBtn.numberOfTouchesRequired = 1;
    tapApproveBtn.numberOfTapsRequired = 1;
    [_circleApproveBtn addGestureRecognizer:tapApproveBtn];
    [_circleApproveBtn setUserInteractionEnabled:YES];
    
    /* Auto layouts of approve button */
    [self.view addSubview:_circleApproveBtn];
    [self.view bringSubviewToFront:_circleApproveBtn];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_circleApproveBtn
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_circleApproveBtn
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:32]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_circleApproveBtn
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_fakeBar
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_circleApproveBtn
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailingMargin
                                                         multiplier:1
                                                           constant:0]];
    
    /* Init of Title Label */
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 24)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor darkGrayColor];
    _titleLabel.font = [UIFont systemFontOfSize:12];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Init of Current Date */
    _dateFormatter = [NSDateFormatter new];
    [_dateFormatter setDateFormat:@"yyyy年M月d日 EEEE h:m"];
    [_dateFormatter setLocale:[NSLocale currentLocale]];
    _titleLabel.text = [_dateFormatter stringFromDate:[NSDate date]];
    
    /* Auto layouts of Title Label */
    [_textView addSubview:_titleLabel];
    [_textView bringSubviewToFront:_titleLabel];
    [_textView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:240]];
    [_textView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:24]];
    [_textView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_textView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [_textView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_textView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [textView becomeFirstResponder];
    });
    
    [_textView addObserver:self forKeyPath:@"typingAttributes" options:NSKeyValueObservingOptionNew context:nil];
    [[YYTextKeyboardManager defaultManager] addObserver:self];
}

#pragma mark - Text Attributes Holder

// 监听输入属性的改变，禁止继承前文属性 (Fuck)
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"typingAttributes"]) {
        _textView.typingAttributes = _originalAttributes;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [_textView removeObserver:self forKeyPath:@"typingAttributes"];
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

#pragma mark - Rotate

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            _fakeBar.hidden = NO;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            _fakeBar.top = 0;
            _textView.contentInset = UIEdgeInsetsMake(kComposeTopBarInsectPortrait, 0, 0, 0);
        }];
    } else {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            _fakeBar.hidden = YES;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            _fakeBar.top = - _fakeBar.height;
            _textView.contentInset = UIEdgeInsetsMake(kComposeTopBarInsectLandscape, 0, 0, 0);
        }];
    }
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Selection Menu (TODO)

- (BOOL)canBecomeFirstResponder {
    return YES;
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

- (void)closeComposeView:(id)sender {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:^() {
        [self.view removeAllSubviews];
    }];
}

- (void)done:(id)sender {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    [self.view makeToast:@"暂时还不能发布"
                duration:kStatusBarNotificationTime
                position:CSToastPositionCenter];
}

#pragma mark - Toolbar Actions

- (void)setRangeBold:(UIBarButtonItem *)sender {
    NSRange range = _textView.selectedRange;
    if (range.length <= 0) {
        [self.view makeToast:@"请选择需要设置粗体的文字"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[_textView attributedText]];
    NSAttributedString *sub = [string attributedSubstringFromRange:range];
    UIFont *font = [sub font];
    if (![font isBold]) {
        [string setFont:[font fontWithBold] range:range];
    } else {
        [string setFont:[font fontWithNormal] range:range];
    }
    [_textView setAttributedText:string];
    [_textView setSelectedRange:range];
    [_textView scrollRangeToVisible:range];
}

- (void)setRangeItalic:(UIBarButtonItem *)sender {
    NSRange range = _textView.selectedRange;
    if (range.length <= 0) {
        [self.view makeToast:@"请选择需要设置斜体的文字"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[_textView attributedText]];
    NSAttributedString *sub = [string attributedSubstringFromRange:range];
    UIFont *font = [sub font];
    if (![font isItalic]) {
        [string setFont:[font fontWithItalic] range:range];
    } else {
        [string setFont:[font fontWithNormal] range:range];
    }
    [_textView setAttributedText:string];
    [_textView setSelectedRange:range];
    [_textView scrollRangeToVisible:range];
}

- (void)addUrl:(UIBarButtonItem *)sender {
    NSRange range = _textView.selectedRange;
    if (range.length <= 0) {
        [self.view makeToast:@"请选择需要设置为链接的文字"
                    duration:kStatusBarNotificationTime
                    position:CSToastPositionCenter];
        return;
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[_textView attributedText]];
    [[CourtesyTextBindingParser sharedInstance] parseText:string selectedRange:&range];
    [_textView setAttributedText:string];
    [_textView setSelectedRange:range];
    [_textView scrollRangeToVisible:range];
}

- (void)addNewFrame:(UIBarButtonItem *)sender {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    LGAlertView *alert = [[LGAlertView alloc] initWithTitle:@"插入图像"
                                                    message:@"请选择一种方式"
                                                      style:LGAlertViewStyleActionSheet
                                               buttonTitles:@[@"相机", @"从相册选取"]
                                          cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:nil
                                              actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                                if (index == 0) {
                                                                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                    picker.delegate = self;
                                                                    picker.allowsEditing = NO;
                                                                    [self presentViewController:picker animated:YES completion:nil];
                                                                } else {
                                                                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                    picker.delegate = self;
                                                                    picker.allowsEditing = NO;
                                                                    [self presentViewController:picker animated:YES completion:nil];
                                                                }
                                                            }
                                              cancelHandler:^(LGAlertView *alertView) {
                                                                if (!_textView.isFirstResponder) {
                                                                    [_textView becomeFirstResponder];
                                                                }
                                                            } destructiveHandler:nil];
    [alert showAnimated:YES completionHandler:nil];
}

- (void)addNewVoice:(UIBarButtonItem *)sender {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    LGAlertView *alert = [[LGAlertView alloc] initWithTitle:@"插入音频"
                                                    message:@"请选择一种方式"
                                                      style:LGAlertViewStyleActionSheet
                                               buttonTitles:@[@"录音", @"从音乐库选取"]
                                          cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:nil
                                              actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                  if (index == 0) {
                                                      AudioNoteRecorderViewController *vc = [[AudioNoteRecorderViewController alloc] initWithMasterViewController:self];
                                                      vc.delegate = self;
                                                      [self presentViewController:vc animated:YES completion:nil];
                                                  } else {
                                                      MPMediaPickerController * mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
                                                      mediaPicker.delegate = self;
                                                      mediaPicker.allowsPickingMultipleItems = NO;
                                                      [self presentViewController:mediaPicker animated:YES completion:nil];
                                                  }
                                              }
                                              cancelHandler:^(LGAlertView *alertView) {
                                                  if (!_textView.isFirstResponder) {
                                                      [_textView becomeFirstResponder];
                                                  }
                                              } destructiveHandler:nil];
    [alert showAnimated:YES completionHandler:nil];
}

- (void)addNewVideo:(UIBarButtonItem *)sender {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    LGAlertView *alert = [[LGAlertView alloc] initWithTitle:@"插入视频"
                                                    message:@"请选择一种方式"
                                                      style:LGAlertViewStyleActionSheet
                                               buttonTitles:@[@"随手录", @"相机", @"从相册选取"]
                                          cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:nil
                                              actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                                  if (index == 0) {
                                                      WechatShortVideoController *shortVideoController = [WechatShortVideoController new];
                                                      shortVideoController.delegate = self;
                                                      [self presentViewController:shortVideoController animated:YES completion:nil];
                                                  } else if (index == 1) {
                                                      UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                      picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo];
                                                      picker.videoMaximumDuration = 30.0;
                                                      picker.delegate = self;
                                                      picker.allowsEditing = YES;
                                                      [self presentViewController:picker animated:YES completion:nil];
                                                  } else if (index == 2) {
                                                      UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                      picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo];
                                                      picker.videoMaximumDuration = 30.0;
                                                      picker.videoQuality = [sharedSettings preferredVideoQuality];
                                                      picker.delegate = self;
                                                      picker.allowsEditing = YES;
                                                      [self presentViewController:picker animated:YES completion:nil];
                                                  }
                                              }
                                              cancelHandler:^(LGAlertView *alertView) {
                                                  if (!_textView.isFirstResponder) {
                                                      [_textView becomeFirstResponder];
                                                  }
                                              } destructiveHandler:nil];
    [alert showAnimated:YES completionHandler:nil];
}

- (void)setAlignLeft:(UIBarButtonItem *)sender {
    [self setTextViewAlignment:NSTextAlignmentLeft];
}

- (void)setAlignCenter:(UIBarButtonItem *)sender {
    [self setTextViewAlignment:NSTextAlignmentCenter];
}

- (void)setAlignRight:(UIBarButtonItem *)sender {
    [self setTextViewAlignment:NSTextAlignmentRight];
}

- (void)toggleFreehand:(UIBarButtonItem *)sender {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    // TODO: 添加涂鸦
}

- (void)setFont:(UIBarButtonItem *)sender {
    // TODO: 更改字体
}

- (void)setTextViewAlignment:(NSTextAlignment)alignment {
    NSRange range = _textView.selectedRange;
    if (range.length <= 0 && [_textView.typingAttributes hasKey:NSParagraphStyleAttributeName]) {
        NSParagraphStyle *paragraphStyle = [_textView.typingAttributes objectForKey:NSParagraphStyleAttributeName];
        NSMutableParagraphStyle *newParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        [newParagraphStyle setParagraphStyle:paragraphStyle];
        newParagraphStyle.alignment = alignment;
        NSMutableDictionary *newTypingAttributes = [[NSMutableDictionary alloc] initWithDictionary:_textView.typingAttributes];
        [newTypingAttributes setObject:newParagraphStyle forKey:NSParagraphStyleAttributeName];
        [_textView setTypingAttributes:newTypingAttributes];
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[_textView attributedText]];
    [string setAlignment:alignment];
    [_textView setAttributedText:string];
    [_textView setSelectedRange:range];
    [_textView scrollRangeToVisible:range];
}

#pragma mark - AudioNoteRecorderDelegate

- (void)audioNoteRecorderDidCancel:(AudioNoteRecorderViewController *)audioNoteRecorder {
    [audioNoteRecorder dismissViewControllerAnimated:YES completion:^() {
        if (!_textView.isFirstResponder) {
            [_textView becomeFirstResponder];
        }
    }];
}

- (void)audioNoteRecorderDidTapDone:(AudioNoteRecorderViewController *)audioNoteRecorder
                    withRecordedURL:(NSURL *)recordedURL {
    [audioNoteRecorder dismissViewControllerAnimated:YES completion:^() {
        [self addNewAudioFrame:recordedURL
                            at:_textView.selectedRange
                      animated:YES
                      userinfo:@{
                                 @"title": @"新录音",
                                 @"type": @"audio",
                                 @"url": recordedURL
                                 }];
    }];
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:^() {
        if (!_textView.isFirstResponder) {
            [_textView becomeFirstResponder];
        }
    }];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
 didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    if (!mediaItemCollection) {
        return;
    }
    if (mediaItemCollection.count == 1) {
        if (mediaItemCollection.mediaTypes <= MPMediaTypeAnyAudio) {
            for (MPMediaItem *item in [mediaItemCollection items]) {
                if ([item hasProtectedAsset] == NO && [item isCloudItem] == NO) {
                    CYLog(@"%@", [item title]);
                    CYLog(@"%@", [item assetURL]);
                    [self addNewAudioFrame:[item assetURL]
                                        at:_textView.selectedRange
                                  animated:YES
                                  userinfo:@{
                                             @"title": [item title],
                                             @"type": @"audio",
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
    [picker dismissViewControllerAnimated:YES completion:^() {
        if (!_textView.isFirstResponder) {
            [_textView becomeFirstResponder];
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([info hasKey:UIImagePickerControllerEditedImage] || [info hasKey:UIImagePickerControllerOriginalImage]) {
        __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        [picker dismissViewControllerAnimated:YES completion:^{
            [self addNewImageFrame:image
                                at:_textView.selectedRange
                          animated:YES
                          userinfo:info];
        }];
    } else if ([info hasKey:UIImagePickerControllerMediaType] && [info hasKey:UIImagePickerControllerMediaURL]
               && (
                   [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie] ||
                   [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeVideo]
                  )) {
       __block NSURL *mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
       [picker dismissViewControllerAnimated:YES completion:^{
           [self addNewVideoFrame:mediaURL
                               at:_textView.selectedRange
                         animated:YES
                         userinfo:info];
       }];
   } else {
       [picker dismissViewControllerAnimated:YES completion:nil];
   }
}

#pragma mark - WeChatShortVideoDelegate

- (void)finishWechatShortVideoCapture:(WechatShortVideoController *)controller
                                 path:(NSURL *)filePath {
    [controller dismissViewControllerAnimated:YES
                                   completion:^{
                                       [self addNewVideoFrame:filePath
                                                           at:_textView.selectedRange
                                                     animated:YES
                                                     userinfo:@{
                                                                UIImagePickerControllerMediaType: (NSString *)kUTTypeMovie,
                                                                UIImagePickerControllerMediaURL: filePath
                                                                }];
                                   }];
}

#pragma mark - Audio Frame Builder

- (CourtesyAudioFrameView *)addNewAudioFrame:(NSURL *)url
                                          at:(NSRange)range
                                    animated:(BOOL)animated
                                    userinfo:(NSDictionary *)info {
    CourtesyAudioFrameView *frameView = [[CourtesyAudioFrameView alloc] initWithFrame:CGRectMake(0, 0, _textView.frame.size.width - kComposeLeftInsect - kComposeRightInsect, kComposeLineHeight * 2)];
    [frameView setDelegate:self];
    [frameView setUserinfo:info];
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
    CourtesyImageFrameView *frameView = [[CourtesyImageFrameView alloc] initWithFrame:CGRectMake(0, 0, _textView.frame.size.width - kComposeLeftInsect - kComposeRightInsect, 0)];
    [frameView setDelegate:self];
    [frameView setUserinfo:info];
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
    CourtesyVideoFrameView *frameView = [[CourtesyVideoFrameView alloc] initWithFrame:CGRectMake(0, 0, _textView.frame.size.width - 48, 0)];
    [frameView setDelegate:self];
    [frameView setUserinfo:info];
    [frameView setVideoURL:url];
    
    return [self insertFrameToTextView:frameView
                                    at:range
                              animated:animated];
}

#pragma mark - Insert Frame Helper

- (id)insertFrameToTextView:(UIView *)frameView
                           at:(NSRange)range
                     animated:(BOOL)animated {
    if (animated) {
        [frameView setAlpha:0.0];
    }
    // Add Frame View to Text View (Method 1)
    NSMutableString *insertHelper = [[NSMutableString alloc] initWithString:@"\n"];
    int t = floor(frameView.height / kComposeLineHeight);
    for (int i = 0; i < t; i++) {
        [insertHelper appendString:@"\n"];
    }
    NSMutableAttributedString *attachText = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:insertHelper attributes:_originalAttributes]];
    [attachText appendAttributedString:[NSMutableAttributedString attachmentStringWithContent:frameView
                                                                                  contentMode:UIViewContentModeCenter
                                                                               attachmentSize:frameView.size alignToFont:_originalFont alignment:YYTextVerticalAlignmentBottom]];
    [attachText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:_originalAttributes]];
    YYTextBinding *binding = [YYTextBinding bindingWithDeleteConfirm:YES];
    [attachText setTextBinding:binding range:NSMakeRange(0, attachText.length)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    [text insertAttributedString:attachText atIndex:range.location];
    if ([frameView isKindOfClass:[CourtesyImageFrameView class]]) {
        [(CourtesyImageFrameView *)frameView setSelfRange:NSMakeRange(range.location, attachText.length)];
    } else if ([frameView isKindOfClass:[CourtesyAudioFrameView class]]) {
        [(CourtesyAudioFrameView *)frameView setSelfRange:NSMakeRange(range.location, attachText.length)];
    }
    [_textView setAttributedText:text];
    [_textView scrollRangeToVisible:range];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [frameView setAlpha:1.0];
        } completion:^(BOOL finished) {
            
        }];
    }
    return frameView;
}

#pragma mark - CourtesyAudioFrameDelegate

- (void)audioFrameTapped:(CourtesyAudioFrameView *)audioFrame {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
}

#pragma mark - CourtesyImageFrameDelegate

- (void)imageFrameTapped:(CourtesyImageFrameView *)imageFrame {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
}

- (void)imageFrameShouldReplaced:(CourtesyImageFrameView *)imageFrame
                              by:(UIImage *)image
                        userinfo:(NSDictionary *)userinfo {
    [self imageFrameShouldDeleted:imageFrame
                         animated:NO];
    [self addNewImageFrame:image
                        at:imageFrame.selfRange
                  animated:NO
                  userinfo:userinfo];
}

- (void)imageFrameShouldDeleted:(CourtesyImageFrameView *)imageFrame
                       animated:(BOOL)animated {
    if (!animated) {
        [self removeImageFrameFromTextView:imageFrame];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            imageFrame.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self removeImageFrameFromTextView:imageFrame];
            }
        }];
    }
}

- (void)removeImageFrameFromTextView:(CourtesyImageFrameView *)imageFrame {
    CYLog(@"%@", _textView.textLayout.attachments);
    [imageFrame removeFromSuperview];
    NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithAttributedString:[_textView attributedText]];
    NSRange allRange = [mStr rangeOfAll];
    if (imageFrame.selfRange.location >= allRange.location &&
        imageFrame.selfRange.location + imageFrame.selfRange.length <= allRange.location + allRange.length) {
        [mStr deleteCharactersInRange:imageFrame.selfRange];
        [_textView setAttributedText:mStr];
    }
}

- (void)imageFrameShouldCropped:(CourtesyImageFrameView *)imageFrame {
    PECropViewController *cropViewController = [[PECropViewController alloc] init];
    cropViewController.delegate = imageFrame;
    cropViewController.image = imageFrame.centerImage;
    
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:cropViewController];
    [self presentViewController:navc animated:YES completion:nil];
}

#pragma mark - YYTextKeyboardObserver

- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition {
    
}

#pragma mark - Memory Leaks

- (void)didReceiveMemoryWarning {
    CYLog(@"Memory warning!");
}

@end
