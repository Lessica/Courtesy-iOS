//
//  CourtesyCardComposeViewController.m
//  Courtesy
//
//  Created by Zheng on 3/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyTextBindingParser.h"
#import "CourtesyCardComposeViewController.h"

@interface CourtesyCardComposeViewController () <YYTextViewDelegate, YYTextKeyboardObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, assign) YYTextView *textView;
@property (nonatomic, strong) CourtesyTextBindingParser *bindingParser;
@property (nonatomic, strong) UIView *fakeBar;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSDictionary *originalAttributes;

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture"]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    //self.modalPresentationCapturesStatusBarAppearance = NO;
    self.edgesForExtendedLayout =  UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    //__weak typeof(self) _self = self;
    
    /* Init of Navigation Bar Items (if there is a navigation bar actually) */
    UIBarButtonItem *item = [UIBarButtonItem new];
    item.image = [UIImage imageNamed:@"30-send"];
    item.target = self;
    item.action = @selector(done:);
    self.navigationItem.rightBarButtonItem = item;
    
    /* Init of toolbar */
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.barTintColor = [UIColor whiteColor];
    toolbar.backgroundColor = [UIColor clearColor];
    
    /* Elements of tool bar items */
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *myToolBarItems = [NSMutableArray array];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"33-bold"] style:UIBarButtonItemStylePlain target:self action:@selector(setRangeBold:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"32-italic"] style:UIBarButtonItemStylePlain target:self action:@selector(setRangeItalic:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"37-url"] style:UIBarButtonItemStylePlain target:self action:@selector(addUrl:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"36-frame"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewFrame:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"34-music"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewVoice:)]];
    [myToolBarItems addObject:flexibleSpace];
    [myToolBarItems addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"31-camera"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewVideo:)]];
    [toolbar setTintColor:[UIColor grayColor]];
    [toolbar setItems:myToolBarItems animated:YES];
    
//    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addSubview:toolbar];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:toolbar
//                                                        attribute:NSLayoutAttributeWidth
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:self.view
//                                                        attribute:NSLayoutAttributeWidth
//                                                       multiplier:1
//                                                         constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:toolbar
//                                                        attribute:NSLayoutAttributeHeight
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:nil
//                                                        attribute:NSLayoutAttributeNotAnAttribute
//                                                       multiplier:1
//                                                         constant:40]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:toolbar
//                                                        attribute:NSLayoutAttributeCenterX
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:self.view
//                                                        attribute:NSLayoutAttributeCenterX
//                                                       multiplier:1
//                                                         constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:toolbar
//                                                        attribute:NSLayoutAttributeTop
//                                                        relatedBy:NSLayoutRelationEqual
//                                                           toItem:self.view
//                                                        attribute:NSLayoutAttributeTopMargin
//                                                       multiplier:1
//                                                         constant:0]];
    
    /* Initial text */
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"说点什么吧……"];
    _font = [UIFont fontWithName:@"Times New Roman" size:16];
    text.font = _font;
    text.lineSpacing = 8;
    text.lineBreakMode = NSLineBreakByWordWrapping;
    _originalAttributes = text.attributes;
    
    /* Init of text view */
    YYTextView *textView = [YYTextView new];
    textView.delegate = self;
    textView.typingAttributes = _originalAttributes;
    textView.backgroundColor = [UIColor clearColor];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Set initial text */
    textView.attributedText = text;
    textView.textColor = [UIColor darkGrayColor];
    [textView setTypingAttributes:[text attributes]];
    
    /* Margin */
    textView.textContainerInset = UIEdgeInsetsMake(24, 24, 24, 24);
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        textView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
    } else {
        textView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    textView.scrollIndicatorInsets = textView.contentInset;
    textView.selectedRange = NSMakeRange(text.length, 0);
    
    /* Auto correction */
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    /* Paste */
    textView.allowsUndoAndRedo = YES;
    textView.allowsPasteImage = NO;
    
    /* Undo */
    textView.allowsPasteAttributedString = NO;
    textView.maximumUndoLevel = 10;
    
    /* Line height fixed */
    YYTextLinePositionSimpleModifier *mod = [YYTextLinePositionSimpleModifier new];
    mod.fixedLineHeight = 28;
    textView.linePositionModifier = mod;
    
    /* Toolbar */
    textView.inputAccessoryView = toolbar;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    /* Place holder */
    textView.placeholderText = @"说点什么吧……";
    textView.placeholderTextColor = [UIColor lightGrayColor];
    
    /* Text binding */
    /* [textView setTextParser:[CourtesyTextBindingParser new]]; */
    
    /* Indicator (Tint Color) */
    textView.tintColor = [UIColor darkGrayColor];
    
    /* Layout of Text View */
    self.textView = textView;
    [self.view addSubview:textView];
    
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
    UIImageView *circleCloseBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    circleCloseBtn.backgroundColor = [UIColor blackColor];
    circleCloseBtn.tintColor = [UIColor whiteColor];
    circleCloseBtn.alpha = 0.45;
    circleCloseBtn.image = [[UIImage imageNamed:@"39-close-circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    circleCloseBtn.layer.masksToBounds = YES;
    circleCloseBtn.layer.cornerRadius = circleCloseBtn.frame.size.height / 2;
    circleCloseBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Tap gesture of close button */
    UITapGestureRecognizer *tapCloseBtn = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(closeComposeView:)];
    tapCloseBtn.numberOfTouchesRequired = 1;
    tapCloseBtn.numberOfTapsRequired = 1;
    [circleCloseBtn addGestureRecognizer:tapCloseBtn];
    [circleCloseBtn setUserInteractionEnabled:YES];
    
    /* Auto layouts of close button */
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
                                                             toItem:_fakeBar
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
    
    /* Init of approve circle buttons */
    UIImageView *circleApproveBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    circleApproveBtn.backgroundColor = [UIColor blackColor];
    circleApproveBtn.tintColor = [UIColor whiteColor];
    circleApproveBtn.alpha = 0.45;
    circleApproveBtn.image = [[UIImage imageNamed:@"40-approve-circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    circleApproveBtn.layer.masksToBounds = YES;
    circleApproveBtn.layer.cornerRadius = circleApproveBtn.frame.size.height / 2;
    circleApproveBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Tap gesture of approve button */
    UITapGestureRecognizer *tapApproveBtn = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(done:)];
    tapApproveBtn.numberOfTouchesRequired = 1;
    tapApproveBtn.numberOfTapsRequired = 1;
    [circleApproveBtn addGestureRecognizer:tapApproveBtn];
    [circleApproveBtn setUserInteractionEnabled:YES];
    
    /* Auto layouts of approve button */
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
                                                             toItem:_fakeBar
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [textView becomeFirstResponder];
    });
    
    /* Init of Text Binding Parser */
    _bindingParser = [CourtesyTextBindingParser new];
    
    [_textView addObserver:self forKeyPath:@"typingAttributes" options:NSKeyValueObservingOptionNew context:nil];
    [[YYTextKeyboardManager defaultManager] addObserver:self];
}

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
            _textView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        }];
    } else {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            _fakeBar.hidden = YES;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            _fakeBar.top = - _fakeBar.height;
            _textView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
        }];
    }
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Selection Menu

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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done:(id)sender {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    [self.view makeToast:@"暂时还不能发布"
                duration:kStatusBarNotificationTime
                position:CSToastPositionCenter];
}

#pragma mark - YYTextViewDelegate

- (void)textViewDidChange:(YYTextView *)textView {
    if (textView.text.length == 0) {
        textView.textColor = [UIColor darkGrayColor];
    }
}

#pragma mark - Toolbar Actions

- (void)setRangeBold:(UIBarButtonItem *)sender {
    NSRange range = _textView.selectedRange;
    if (range.length <= 0) {
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
    _textView.attributedText = string;
    [_textView setSelectedRange:range];
    [_textView scrollRangeToVisible:range];
}

- (void)setRangeItalic:(UIBarButtonItem *)sender {
    NSRange range = _textView.selectedRange;
    if (range.length <= 0) {
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
    _textView.attributedText = string;
    [_textView setSelectedRange:range];
    [_textView scrollRangeToVisible:range];
}

- (void)addUrl:(UIBarButtonItem *)sender {
    NSRange range = _textView.selectedRange;
    if (range.length <= 0) {
        return;
    }
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[_textView attributedText]];
    [_bindingParser parseText:string selectedRange:&range];
    _textView.attributedText = string;
    [_textView setSelectedRange:range];
    [_textView scrollRangeToVisible:range];
}

- (void)addNewFrame:(UIBarButtonItem *)sender {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    LGAlertView *alert = [[LGAlertView alloc] initWithTitle:@"插入图像" message:@"请选择一种方式" style:LGAlertViewStyleActionSheet buttonTitles:@[@"相机", @"本地相册"] cancelButtonTitle:@"取消" destructiveButtonTitle:nil actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
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
    } cancelHandler:^(LGAlertView *alertView) {
        if (!_textView.isFirstResponder) {
            [_textView becomeFirstResponder];
        }
    } destructiveHandler:nil];
    [alert showAnimated:YES completionHandler:nil];
}

- (void)addNewVoice:(UIBarButtonItem *)sender {
    
}

- (void)addNewVideo:(UIBarButtonItem *)sender {
    
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
    [picker dismissViewControllerAnimated:YES completion:nil];
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    [self addNewImageFrame:image];
}

#pragma mark - Image Frame Builder

- (void)addNewImageFrame:(UIImage *)image {
    // Calculate Image Scaled Height
    CGFloat maxWidth = _textView.contentSize.width - 60;
    CGFloat scaleValue = 0;
    CGFloat height = 0;
    
    // Init of Image View
    UIImageView *imageView = nil;
    if (image.size.width > maxWidth) {
        scaleValue = maxWidth / image.size.width;
        height = image.size.height * scaleValue;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        height = image.size.height;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, height)];
        imageView.contentMode = UIViewContentModeCenter;
    }
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    imageView.image = image;
    
    
    // Init of Frame View
    UIView *frameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _textView.frame.size.width - 48, imageView.height + 12)];
    frameView.backgroundColor = [UIColor whiteColor];
    frameView.layer.shadowColor = [UIColor blackColor].CGColor;
    frameView.layer.shadowOffset = CGSizeMake(1, 1);
    frameView.layer.shadowOpacity = 0.45;
    frameView.layer.shadowRadius = 1;
    
    // Add Image View to Frame View
    [frameView addSubview:imageView];
    imageView.center = frameView.center;
    
    
    
    NSRange range = _textView.selectedRange;
    
    // Add Frame View to Text View (Method 1)
    NSMutableString *insertHelper = [[NSMutableString alloc] initWithString:@"\n"];
    int t = floor(frameView.height / 28);
    for (int i = 0; i < t; i++) {
        [insertHelper appendString:@"\n"];
    }
    NSMutableAttributedString *attachText = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:insertHelper attributes:_originalAttributes]];
    [attachText appendAttributedString:[NSMutableAttributedString attachmentStringWithContent:frameView
                                                                                  contentMode:UIViewContentModeCenter
                                                                               attachmentSize:frameView.size alignToFont:_font alignment:YYTextVerticalAlignmentBottom]];
    [attachText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:_originalAttributes]];
    YYTextBinding *binding = [YYTextBinding bindingWithDeleteConfirm:YES];
    [attachText setTextBinding:binding range:NSMakeRange(0, attachText.length)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    [text insertAttributedString:attachText atIndex:range.location];
    _textView.attributedText = text;
    
    [_textView scrollRangeToVisible:range];
}

#pragma mark - YYTextKeyboardObserver

@end
