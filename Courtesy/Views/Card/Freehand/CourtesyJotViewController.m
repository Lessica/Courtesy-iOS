//
//  CourtesyJotViewController.m
//  Courtesy
//
//  Created by Zheng on 3/4/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyJotViewController.h"

@interface CourtesyJotViewController ()
@property (nonatomic, strong) UIButton *toggleBtn;
@property (nonatomic, strong) UIButton *restoreBtn;
@property (nonatomic, strong) UIButton *redColorBtn;
@property (nonatomic, strong) UIButton *yellowColorBtn;
@property (nonatomic, strong) UIButton *blueColorBtn;
@property (nonatomic, strong) UIButton *blackColorBtn;
@property (nonatomic, strong) UIButton *whiteColorBtn;

@end

@implementation CourtesyJotViewController

- (instancetype)init {
    if (self = [super init]) {
        UIButton *circleToggleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        circleToggleBtn.backgroundColor = tryValue(self.buttonBackgroundColor, [UIColor blackColor]);
        circleToggleBtn.tintColor = tryValue(self.buttonTintColor, [UIColor whiteColor]);
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
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailingMargin
                                                             multiplier:1
                                                               constant:0]];
        
        UIButton *circleRestoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        circleRestoreBtn.backgroundColor = tryValue(self.buttonBackgroundColor, [UIColor blackColor]);
        circleRestoreBtn.tintColor = tryValue(self.buttonTintColor, [UIColor whiteColor]);
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
        
        UIButton *circleBlackBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        circleBlackBtn.backgroundColor =
        circleBlackBtn.tintColor = [UIColor blackColor];
        [circleBlackBtn setImage:[[UIImage imageNamed:@"61-jot-color"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [circleBlackBtn setImage:nil forState:UIControlStateSelected];
        circleBlackBtn.layer.masksToBounds = YES;
        circleBlackBtn.layer.cornerRadius = circleBlackBtn.frame.size.height / 2;
        circleBlackBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        circleBlackBtn.layer.shadowOffset = CGSizeMake(1, 1);
        circleBlackBtn.layer.shadowOpacity = 0.618;
        circleBlackBtn.translatesAutoresizingMaskIntoConstraints = NO;
        circleBlackBtn.selected = NO;
        [circleBlackBtn setTarget:self action:@selector(drawBlack:) forControlEvents:UIControlEventTouchUpInside];
        circleBlackBtn.alpha = 0.0;
        circleBlackBtn.hidden = YES;
        self.blackColorBtn = circleBlackBtn;
        [self.view addSubview:circleBlackBtn];
        [self.view bringSubviewToFront:circleBlackBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBlackBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBlackBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBlackBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:circleToggleBtn
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:-12]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBlackBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailingMargin
                                                             multiplier:1
                                                               constant:0]];
        
        UIButton *circleWhiteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        circleWhiteBtn.backgroundColor =
        circleWhiteBtn.tintColor = [UIColor wheatColor];
        [circleWhiteBtn setImage:[[UIImage imageNamed:@"61-jot-color"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [circleWhiteBtn setImage:nil forState:UIControlStateSelected];
        circleWhiteBtn.layer.masksToBounds = YES;
        circleWhiteBtn.layer.cornerRadius = circleWhiteBtn.frame.size.height / 2;
        circleWhiteBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        circleWhiteBtn.layer.shadowOffset = CGSizeMake(1, 1);
        circleWhiteBtn.layer.shadowOpacity = 0.618;
        circleWhiteBtn.translatesAutoresizingMaskIntoConstraints = NO;
        circleWhiteBtn.selected = NO;
        [circleWhiteBtn setTarget:self action:@selector(drawWhite:) forControlEvents:UIControlEventTouchUpInside];
        circleWhiteBtn.alpha = 0.0;
        circleWhiteBtn.hidden = YES;
        self.whiteColorBtn = circleWhiteBtn;
        [self.view addSubview:circleWhiteBtn];
        [self.view bringSubviewToFront:circleWhiteBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleWhiteBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleWhiteBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleWhiteBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:circleBlackBtn
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:-12]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleWhiteBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailingMargin
                                                             multiplier:1
                                                               constant:0]];
        
        UIButton *circleBlueBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        circleBlueBtn.backgroundColor =
        circleBlueBtn.tintColor = [UIColor blueberryColor];
        [circleBlueBtn setImage:[[UIImage imageNamed:@"61-jot-color"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [circleBlueBtn setImage:nil forState:UIControlStateSelected];
        circleBlueBtn.layer.masksToBounds = YES;
        circleBlueBtn.layer.cornerRadius = circleBlueBtn.frame.size.height / 2;
        circleBlueBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        circleBlueBtn.layer.shadowOffset = CGSizeMake(1, 1);
        circleBlueBtn.layer.shadowOpacity = 0.618;
        circleBlueBtn.translatesAutoresizingMaskIntoConstraints = NO;
        circleBlueBtn.selected = NO;
        [circleBlueBtn setTarget:self action:@selector(drawBlue:) forControlEvents:UIControlEventTouchUpInside];
        circleBlueBtn.alpha = 0.0;
        circleBlueBtn.hidden = YES;
        self.blueColorBtn = circleBlueBtn;
        [self.view addSubview:circleBlueBtn];
        [self.view bringSubviewToFront:circleBlueBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBlueBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBlueBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBlueBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:circleWhiteBtn
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:-12]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleBlueBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailingMargin
                                                             multiplier:1
                                                               constant:0]];
        
        UIButton *circleYellowBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        circleYellowBtn.backgroundColor =
        circleYellowBtn.tintColor = [UIColor emeraldColor];
        [circleYellowBtn setImage:[[UIImage imageNamed:@"61-jot-color"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [circleYellowBtn setImage:nil forState:UIControlStateSelected];
        circleYellowBtn.layer.masksToBounds = YES;
        circleYellowBtn.layer.cornerRadius = circleYellowBtn.frame.size.height / 2;
        circleYellowBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        circleYellowBtn.layer.shadowOffset = CGSizeMake(1, 1);
        circleYellowBtn.layer.shadowOpacity = 0.618;
        circleYellowBtn.translatesAutoresizingMaskIntoConstraints = NO;
        circleYellowBtn.selected = NO;
        [circleYellowBtn setTarget:self action:@selector(drawYellow:) forControlEvents:UIControlEventTouchUpInside];
        circleYellowBtn.alpha = 0.0;
        circleYellowBtn.hidden = YES;
        self.yellowColorBtn = circleYellowBtn;
        [self.view addSubview:circleYellowBtn];
        [self.view bringSubviewToFront:circleYellowBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleYellowBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleYellowBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleYellowBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:circleBlueBtn
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:-12]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleYellowBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailingMargin
                                                             multiplier:1
                                                               constant:0]];
        
        UIButton *circleRedBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        circleRedBtn.backgroundColor =
        circleRedBtn.tintColor = [UIColor brickRedColor];
        [circleRedBtn setImage:[[UIImage imageNamed:@"61-jot-color"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [circleRedBtn setImage:nil forState:UIControlStateSelected];
        circleRedBtn.layer.masksToBounds = YES;
        circleRedBtn.layer.cornerRadius = circleRedBtn.frame.size.height / 2;
        circleRedBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        circleRedBtn.layer.shadowOffset = CGSizeMake(1, 1);
        circleRedBtn.layer.shadowOpacity = 0.618;
        circleRedBtn.translatesAutoresizingMaskIntoConstraints = NO;
        circleRedBtn.selected = NO;
        [circleRedBtn setTarget:self action:@selector(drawRed:) forControlEvents:UIControlEventTouchUpInside];
        circleRedBtn.alpha = 0.0;
        circleRedBtn.hidden = YES;
        self.redColorBtn = circleRedBtn;
        [self.view addSubview:circleRedBtn];
        [self.view bringSubviewToFront:circleRedBtn];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleRedBtn
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleRedBtn
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:32]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleRedBtn
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:circleYellowBtn
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:-12]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:circleRedBtn
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailingMargin
                                                             multiplier:1
                                                               constant:0]];
        
        self.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)setControlEnabled:(BOOL)controlEnabled {
    if (controlEnabled) {
        self.redColorBtn.hidden =
        self.yellowColorBtn.hidden =
        self.blueColorBtn.hidden =
        self.whiteColorBtn.hidden =
        self.blackColorBtn.hidden =
        self.restoreBtn.hidden =
        self.toggleBtn.hidden = NO;
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.redColorBtn.alpha =
                             self.yellowColorBtn.alpha =
                             self.blueColorBtn.alpha =
                             self.whiteColorBtn.alpha =
                             self.blackColorBtn.alpha = 1.0;
                             self.restoreBtn.alpha =
                             self.toggleBtn.alpha = [tryValue(self.standardAlpha, [NSNumber numberWithFloat:0.618]) floatValue] - 0.2;
                         } completion:nil];
    } else {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.redColorBtn.alpha =
                             self.yellowColorBtn.alpha =
                             self.blueColorBtn.alpha =
                             self.whiteColorBtn.alpha =
                             self.blackColorBtn.alpha =
                             self.restoreBtn.alpha =
                             self.toggleBtn.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             self.redColorBtn.hidden =
                             self.yellowColorBtn.hidden =
                             self.blueColorBtn.hidden =
                             self.whiteColorBtn.hidden =
                             self.blackColorBtn.hidden =
                             self.restoreBtn.hidden =
                             self.toggleBtn.hidden = YES;
                         }];
    }
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

- (void)drawBlack:(UIButton *)sender {
    if (self.toggleBtn.selected) {
        self.textColor = [UIColor blackColor];
    } else {
        self.drawingColor = [UIColor blackColor];
    }
}

- (void)drawRed:(UIButton *)sender {
    if (self.toggleBtn.selected) {
        self.textColor = [UIColor brickRedColor];
    } else {
        self.drawingColor = [UIColor brickRedColor];
    }
}

- (void)drawYellow:(UIButton *)sender {
    if (self.toggleBtn.selected) {
        self.textColor = [UIColor emeraldColor];
    } else {
        self.drawingColor = [UIColor emeraldColor];
    }
}

- (void)drawBlue:(UIButton *)sender {
    if (self.toggleBtn.selected) {
        self.textColor = [UIColor blueberryColor];
    } else {
        self.drawingColor = [UIColor blueberryColor];
    }
}

- (void)drawWhite:(UIButton *)sender {
    if (self.toggleBtn.selected) {
        self.textColor = [UIColor wheatColor];
    } else {
        self.drawingColor = [UIColor wheatColor];
    }
}

@end
