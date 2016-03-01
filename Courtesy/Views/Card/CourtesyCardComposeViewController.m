//
//  CourtesyCardComposeViewController.m
//  Courtesy
//
//  Created by Zheng on 3/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyTextBindingParser.h"
#import "CourtesyCardComposeViewController.h"

@interface CourtesyCardComposeViewController () <YYTextViewDelegate, YYTextKeyboardObserver>
@property (nonatomic, assign) YYTextView *textView;

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
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    //__weak typeof(self) _self = self;
    
    /* Init of Navigation Bar Items */
    UIBarButtonItem *item = [UIBarButtonItem new];
    item.image = [UIImage imageNamed:@"30-send"];
    item.target = self;
    item.action = @selector(done:);
    self.navigationItem.rightBarButtonItem = item;
    
    /* Init of toolbar */
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    toolbar.alpha = 0.85;
    
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
    [toolbar setTintColor:[UIColor blueberryColor]];
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
    text.font = [UIFont fontWithName:@"Times New Roman" size:16];
    text.lineSpacing = 8;
    text.lineBreakMode = NSLineBreakByWordWrapping;
    
    /* Init of text view */
    YYTextView *textView = [YYTextView new];
    textView.delegate = self;
    textView.backgroundColor = [UIColor clearColor];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    /* Set initial text */
    textView.attributedText = text;
    textView.textColor = [UIColor darkGrayColor];
    [textView setTypingAttributes:[text attributes]];
    
    /* Margin */
    textView.textContainerInset = UIEdgeInsetsMake(24, 24, 24, 24);
    textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [textView becomeFirstResponder];
    });
    
    [[YYTextKeyboardManager defaultManager] addObserver:self];
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

#pragma mark - Navigation Bar Items

- (void)done:(UIBarButtonItem *)item {
    if (_textView.isFirstResponder) {
        [_textView resignFirstResponder];
    }
    [self.navigationController.view makeToast:@"暂时还不能发布"
                                     duration:kStatusBarNotificationTime
                                     position:CSToastPositionCenter];
}

#pragma mark - YYTextViewDelegate

- (void)textViewDidBeginEditing:(YYTextView *)textView {
    
}

- (void)textViewDidEndEditing:(YYTextView *)textView {
    
}

- (void)textViewDidChange:(YYTextView *)textView {
    if (textView.text.length == 0) {
        textView.textColor = [UIColor darkGrayColor];
    }
}

#pragma mark - Toolbar Actions

- (void)setRangeBold:(UIBarButtonItem *)sender {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[_textView attributedText]];
    NSRange range = _textView.selectedRange;
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
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[_textView attributedText]];
    NSRange range = _textView.selectedRange;
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
    
}

- (void)addNewFrame:(UIBarButtonItem *)sender {
    
}

- (void)addNewVoice:(UIBarButtonItem *)sender {
    
}

- (void)addNewVideo:(UIBarButtonItem *)sender {
    
}

#pragma mark - YYTextKeyboardObserver

@end
