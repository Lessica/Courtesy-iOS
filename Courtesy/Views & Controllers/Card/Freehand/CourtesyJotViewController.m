//
//  CourtesyJotViewController.m
//  Courtesy
//
//  Created by Zheng on 3/4/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyJotViewController.h"
#import "CourtesyJotColorButton.h"

@interface CourtesyJotViewController ()
@property (nonatomic, assign) BOOL colorEnabled;
@property (nonatomic, assign) BOOL lineEnabled;
@property (nonatomic, strong) UIButton *toggleBtn;
@property (nonatomic, strong) UIButton *restoreBtn;
@property (nonatomic, strong) UIButton *colorToggleBtn;
@property (nonatomic, strong) UIButton *lineToggleBtn;
@property (nonatomic, strong) NSMutableArray <CourtesyJotColorButton *> *buttonArray;
@property (nonatomic, strong) UIButton *largeBtn;
@property (nonatomic, strong) UIButton *mediumBtn;
@property (nonatomic, strong) UIButton *smallBtn;

@end

@implementation CourtesyJotViewController

- (CourtesyCardStyleModel *)style {
    return ((CourtesyCardComposeViewController *)self.delegate).card.card_data.style;
}

- (instancetype)initWithMasterController:(CourtesyCardComposeViewController<JotViewControllerDelegate> *)controller {
    if (self = [super init]) {
        self.delegate = controller;
        self.buttonArray = [[NSMutableArray alloc] init];
        
        UIButton *colorToggleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [colorToggleBtn setImage:[[UIImage imageNamed:@"62-jot-pallette"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [colorToggleBtn setImage:[[UIImage imageNamed:@"62-jot-pallette"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        colorToggleBtn.layer.masksToBounds = YES;
        colorToggleBtn.layer.cornerRadius = colorToggleBtn.frame.size.height / 2;
        colorToggleBtn.translatesAutoresizingMaskIntoConstraints = NO;
        colorToggleBtn.selected = NO;
        [colorToggleBtn setTarget:self action:@selector(toggleColor:) forControlEvents:UIControlEventTouchUpInside];
        colorToggleBtn.alpha = 0.0;
        colorToggleBtn.hidden = YES;
        self.colorToggleBtn = colorToggleBtn;
        [self.view addSubview:colorToggleBtn];
        [self.view bringSubviewToFront:colorToggleBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:colorToggleBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:colorToggleBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:colorToggleBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottomMargin
                                                             multiplier:1
                                                               constant:-20]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:colorToggleBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailingMargin
                                                             multiplier:1
                                                               constant:0]];
        
        UIButton *lineToggleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [lineToggleBtn setImage:[[UIImage imageNamed:@"63-jot-line"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [lineToggleBtn setImage:[[UIImage imageNamed:@"63-jot-line"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        lineToggleBtn.layer.masksToBounds = YES;
        lineToggleBtn.layer.cornerRadius = lineToggleBtn.frame.size.height / 2;
        lineToggleBtn.translatesAutoresizingMaskIntoConstraints = NO;
        lineToggleBtn.selected = NO;
        [lineToggleBtn setTarget:self action:@selector(toggleLine:) forControlEvents:UIControlEventTouchUpInside];
        lineToggleBtn.alpha = 0.0;
        lineToggleBtn.hidden = YES;
        self.lineToggleBtn = lineToggleBtn;
        [self.view addSubview:lineToggleBtn];
        [self.view bringSubviewToFront:lineToggleBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lineToggleBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lineToggleBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lineToggleBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottomMargin
                                                             multiplier:1
                                                               constant:-20]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lineToggleBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:colorToggleBtn
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1
                                                               constant:-12]];
        
        UIButton *circleToggleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [circleToggleBtn setImage:[[UIImage imageNamed:@"58-jot-edit"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [circleToggleBtn setImage:[[UIImage imageNamed:@"57-jot-font"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        circleToggleBtn.layer.masksToBounds = YES;
        circleToggleBtn.layer.cornerRadius = circleToggleBtn.frame.size.height / 2;
        circleToggleBtn.translatesAutoresizingMaskIntoConstraints = NO;
        circleToggleBtn.selected = NO;
        [circleToggleBtn setTarget:self action:@selector(toggleMode:) forControlEvents:UIControlEventTouchUpInside];
        circleToggleBtn.alpha = 0.0;
        circleToggleBtn.hidden = YES;
        self.toggleBtn = circleToggleBtn;
        [self.view addSubview:circleToggleBtn];
        [self.view bringSubviewToFront:circleToggleBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleToggleBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleToggleBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleToggleBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottomMargin
                                                             multiplier:1
                                                               constant:-20]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleToggleBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:lineToggleBtn
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1
                                                               constant:-12]];
        
        UIButton *circleRestoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [circleRestoreBtn setImage:[[UIImage imageNamed:@"60-jot-restore"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [circleRestoreBtn setImage:nil forState:UIControlStateSelected];
        circleRestoreBtn.layer.masksToBounds = YES;
        circleRestoreBtn.layer.cornerRadius = circleRestoreBtn.frame.size.height / 2;
        circleRestoreBtn.translatesAutoresizingMaskIntoConstraints = NO;
        circleRestoreBtn.selected = NO;
        [circleRestoreBtn setTarget:self action:@selector(tryRestore:) forControlEvents:UIControlEventTouchUpInside];
        circleRestoreBtn.alpha = 0.0;
        circleRestoreBtn.hidden = YES;
        self.restoreBtn = circleRestoreBtn;
        [self.view addSubview:circleRestoreBtn];
        [self.view bringSubviewToFront:circleRestoreBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleRestoreBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleRestoreBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleRestoreBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottomMargin
                                                             multiplier:1
                                                               constant:-20]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleRestoreBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:circleToggleBtn
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1
                                                               constant:-12]];
        
        UIButton *largeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [largeBtn setImage:[[UIImage imageNamed:@"64-jot-large"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [largeBtn setImage:nil forState:UIControlStateSelected];
        largeBtn.layer.masksToBounds = YES;
        largeBtn.layer.cornerRadius = largeBtn.frame.size.height / 2;
        largeBtn.translatesAutoresizingMaskIntoConstraints = NO;
        largeBtn.selected = NO;
        [largeBtn setTarget:self action:@selector(drawLarge:) forControlEvents:UIControlEventTouchUpInside];
        largeBtn.alpha = 0.0;
        largeBtn.hidden = YES;
        self.largeBtn = largeBtn;
        [self.view addSubview:largeBtn];
        [self.view bringSubviewToFront:largeBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:largeBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:largeBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:largeBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:lineToggleBtn
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:-12]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:largeBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:lineToggleBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:0]];
        
        UIButton *mediumBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [mediumBtn setImage:[[UIImage imageNamed:@"65-jot-medium"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [mediumBtn setImage:nil forState:UIControlStateSelected];
        mediumBtn.layer.masksToBounds = YES;
        mediumBtn.layer.cornerRadius = mediumBtn.frame.size.height / 2;
        mediumBtn.translatesAutoresizingMaskIntoConstraints = NO;
        mediumBtn.selected = NO;
        [mediumBtn setTarget:self action:@selector(drawMedium:) forControlEvents:UIControlEventTouchUpInside];
        mediumBtn.alpha = 0.0;
        mediumBtn.hidden = YES;
        self.mediumBtn = mediumBtn;
        [self.view addSubview:mediumBtn];
        [self.view bringSubviewToFront:mediumBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mediumBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mediumBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mediumBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:largeBtn
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:-12]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:mediumBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:lineToggleBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:0]];
        
        UIButton *smallBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [smallBtn setImage:[[UIImage imageNamed:@"66-jot-small"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [smallBtn setImage:nil forState:UIControlStateSelected];
        smallBtn.layer.masksToBounds = YES;
        smallBtn.layer.cornerRadius = smallBtn.frame.size.height / 2;
        smallBtn.translatesAutoresizingMaskIntoConstraints = NO;
        smallBtn.selected = NO;
        [smallBtn setTarget:self action:@selector(drawSmall:) forControlEvents:UIControlEventTouchUpInside];
        smallBtn.alpha = 0.0;
        smallBtn.hidden = YES;
        self.smallBtn = smallBtn;
        [self.view addSubview:smallBtn];
        [self.view bringSubviewToFront:smallBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:smallBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:smallBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:smallBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:mediumBtn
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:-12]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:smallBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:lineToggleBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1
                                                               constant:0]];
        
        [self reloadStyle];
    }
    return self;
}

- (void)reloadStyle {
    [self.buttonArray removeAllObjects];
    for (UIColor *btnColor in self.style.jotColorArray) {
        CourtesyJotColorButton *newBtn = [[CourtesyJotColorButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        newBtn.color = newBtn.backgroundColor = newBtn.tintColor = btnColor;
        [newBtn setImage:[[UIImage imageNamed:@"61-jot-color"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [newBtn setImage:nil forState:UIControlStateSelected];
        newBtn.layer.masksToBounds = YES;
        newBtn.layer.cornerRadius = newBtn.frame.size.height / 2;
        newBtn.translatesAutoresizingMaskIntoConstraints = NO;
        newBtn.selected = NO;
        [newBtn setTarget:self action:@selector(drawWithColorBtn:) forControlEvents:UIControlEventTouchUpInside];
        newBtn.alpha = 0.0;
        newBtn.hidden = YES;
        [self.view addSubview:newBtn];
        [self.view bringSubviewToFront:newBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:newBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:newBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:newBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailingMargin
                                                             multiplier:1
                                                               constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:newBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:[self.buttonArray lastObject] ? [self.buttonArray lastObject] : _colorToggleBtn
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:-12]];
        [self.buttonArray addObject:newBtn];
    }
    _colorToggleBtn.backgroundColor =
    _lineToggleBtn.backgroundColor =
    _toggleBtn.backgroundColor =
    _restoreBtn.backgroundColor =
    _largeBtn.backgroundColor =
    _mediumBtn.backgroundColor =
    _smallBtn.backgroundColor = self.style.buttonBackgroundColor;
    _colorToggleBtn.tintColor =
    _lineToggleBtn.tintColor =
    _toggleBtn.tintColor =
    _restoreBtn.tintColor =
    _largeBtn.tintColor =
    _mediumBtn.tintColor =
    _smallBtn.tintColor = self.style.buttonTintColor;
    self.font = ((CourtesyCardComposeViewController *)self.delegate).originalFont;
    self.textColor = self.style.cardTextColor;
}

- (void)setLineEnabled:(BOOL)lineEnabled {
    if (lineEnabled) {
        self.largeBtn.hidden =
        self.mediumBtn.hidden =
        self.smallBtn.hidden = NO;
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.largeBtn.alpha =
                             self.mediumBtn.alpha =
                             self.smallBtn.alpha = self.style.standardAlpha - 0.2;
                         } completion:nil];
    } else {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.largeBtn.alpha =
                             self.mediumBtn.alpha =
                             self.smallBtn.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             self.largeBtn.hidden =
                             self.mediumBtn.hidden =
                             self.smallBtn.hidden = YES;
                         }];
    }
}

- (void)setColorEnabled:(BOOL)colorEnabled {
    if (colorEnabled) {
        for (CourtesyJotColorButton *btn in self.buttonArray) {
            btn.hidden = NO;
        }
        [UIView animateWithDuration:0.2
                         animations:^{
                             for (CourtesyJotColorButton *btn in self.buttonArray) {
                                 btn.alpha = 1.0;
                             }
                         } completion:nil];
    } else {
        [UIView animateWithDuration:0.2
                         animations:^{
                             for (CourtesyJotColorButton *btn in self.buttonArray) {
                                 btn.alpha = 0.0;
                             }
                         } completion:^(BOOL finished) {
                             for (CourtesyJotColorButton *btn in self.buttonArray) {
                                 btn.hidden = YES;
                             }
                         }];
    }
}

- (void)setControlEnabled:(BOOL)controlEnabled {
    if (controlEnabled) {
        self.lineToggleBtn.hidden =
        self.colorToggleBtn.hidden =
        self.restoreBtn.hidden =
        self.toggleBtn.hidden = NO;
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.lineToggleBtn.alpha =
                             self.colorToggleBtn.alpha =
                             self.restoreBtn.alpha =
                             self.toggleBtn.alpha = self.style.standardAlpha - 0.2;
                         } completion:nil];
    } else {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.colorToggleBtn.selected = NO;
                             self.lineToggleBtn.selected = NO;
                             [self setColorEnabled:NO];
                             [self setLineEnabled:NO];
                             self.lineToggleBtn.alpha =
                             self.colorToggleBtn.alpha =
                             self.restoreBtn.alpha =
                             self.toggleBtn.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             self.lineToggleBtn.hidden =
                             self.colorToggleBtn.hidden =
                             self.restoreBtn.hidden =
                             self.toggleBtn.hidden = YES;
                         }];
    }
}

- (void)toggleColor:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self setColorEnabled:sender.selected];
}

- (void)toggleLine:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self setLineEnabled:sender.selected];
}

- (void)toggleMode:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.state = JotViewStateText;
    } else {
        self.state = JotViewStateDrawing;
    }
}

- (void)tryRestore:(UIButton *)sender {
    if (self.toggleBtn.selected) {
        [self clearText];
    } else {
        [self clearDrawing];
    }
}

- (void)drawWithColorBtn:(CourtesyJotColorButton *)btn {
    self.textColor = btn.color;
    self.drawingColor = btn.color;
}

- (void)drawLarge:(UIButton *)sender {
    if (self.toggleBtn.selected) {
        self.fontSize = 48.0;
    } else {
        self.drawingStrokeWidth = 24.0;
    }
}

- (void)drawMedium:(UIButton *)sender {
    if (self.toggleBtn.selected) {
        self.fontSize = 36.0;
    } else {
        self.drawingStrokeWidth = 18.0;
    }
}

- (void)drawSmall:(UIButton *)sender {
    if (self.toggleBtn.selected) {
        self.fontSize = 24.0;
    } else {
        self.drawingStrokeWidth = 12.0;
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
