//
//  CourtesyJotViewController.m
//  Courtesy
//
//  Created by Zheng on 3/4/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyJotViewController.h"

@interface CourtesyJotViewController ()
@property (nonatomic, assign) BOOL colorEnabled;
@property (nonatomic, assign) BOOL lineEnabled;
@property (nonatomic, strong) UIButton *toggleBtn;
@property (nonatomic, strong) UIButton *restoreBtn;
@property (nonatomic, strong) UIButton *colorToggleBtn;
@property (nonatomic, strong) UIButton *lineToggleBtn;
@property (nonatomic, strong) NSMutableArray <UIButton *> *buttonArray;
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
        [controller.view addSubview:colorToggleBtn];
        
        [colorToggleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@32);
            make.height.equalTo(@32);
            make.bottom.equalTo(controller.view.mas_bottomMargin).with.offset(-20);
            make.trailing.equalTo(controller.view.mas_trailingMargin).with.offset(0);
        }];
        
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
        [controller.view addSubview:lineToggleBtn];
        
        [lineToggleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@32);
            make.height.equalTo(@32);
            make.bottom.equalTo(controller.view.mas_bottomMargin).with.offset(-20);
            make.trailing.equalTo(colorToggleBtn.mas_leading).with.offset(-12);
        }];
        
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
        [controller.view addSubview:circleToggleBtn];
        
        [circleToggleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@32);
            make.height.equalTo(@32);
            make.bottom.equalTo(controller.view.mas_bottomMargin).with.offset(-20);
            make.trailing.equalTo(lineToggleBtn.mas_leading).with.offset(-12);
        }];
        
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
        [controller.view addSubview:circleRestoreBtn];
        
        [circleRestoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@32);
            make.height.equalTo(@32);
            make.bottom.equalTo(controller.view.mas_bottomMargin).with.offset(-20);
            make.trailing.equalTo(circleToggleBtn.mas_leading).with.offset(-12);
        }];
        
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
        [controller.view addSubview:largeBtn];
        
        [largeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@32);
            make.height.equalTo(@32);
            make.bottom.equalTo(lineToggleBtn.mas_top).with.offset(-12);
            make.trailing.equalTo(lineToggleBtn.mas_trailing).with.offset(0);
        }];
        
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
        [controller.view addSubview:mediumBtn];
        
        [mediumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@32);
            make.height.equalTo(@32);
            make.bottom.equalTo(largeBtn.mas_top).with.offset(-12);
            make.trailing.equalTo(lineToggleBtn.mas_trailing).with.offset(0);
        }];
        
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
        [controller.view addSubview:smallBtn];
        
        [smallBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@32);
            make.height.equalTo(@32);
            make.bottom.equalTo(mediumBtn.mas_top).with.offset(-12);
            make.trailing.equalTo(lineToggleBtn.mas_trailing).with.offset(0);
        }];
        
        [self reloadStyle];
    }
    return self;
}

- (void)reloadStyle {
    CourtesyCardComposeViewController *controller = (CourtesyCardComposeViewController<JotViewControllerDelegate> *)self.delegate;
    for (UIButton *btn in self.buttonArray) {
        [btn removeFromSuperview];
    }
    [self.buttonArray removeAllObjects];
    for (UIColor *btnColor in self.style.jotColorArray) {
        UIButton *newBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        newBtn.backgroundColor = newBtn.tintColor = btnColor;
        [newBtn setImage:[[UIImage imageNamed:@"61-jot-color"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [newBtn setImage:nil forState:UIControlStateSelected];
        newBtn.layer.masksToBounds = YES;
        newBtn.layer.cornerRadius = newBtn.frame.size.height / 2;
        newBtn.translatesAutoresizingMaskIntoConstraints = NO;
        newBtn.selected = NO;
        [newBtn setTarget:self action:@selector(drawWithColorBtn:) forControlEvents:UIControlEventTouchUpInside];
        newBtn.alpha = 0.0;
        newBtn.hidden = YES;
        [controller.view addSubview:newBtn];
        
        [newBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@32);
            make.height.equalTo(@32);
            make.bottom.equalTo(([self.buttonArray lastObject] ? [self.buttonArray lastObject] : _colorToggleBtn).mas_top).with.offset(-12);
            make.trailing.equalTo(controller.view.mas_trailingMargin).with.offset(0);
        }];
        
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
    self.font = controller.originalFont;
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
        for (UIButton *btn in self.buttonArray) {
            btn.hidden = NO;
        }
        [UIView animateWithDuration:0.2
                         animations:^{
                             for (UIButton *btn in self.buttonArray) {
                                 btn.alpha = 1.0;
                             }
                         } completion:nil];
    } else {
        [UIView animateWithDuration:0.2
                         animations:^{
                             for (UIButton *btn in self.buttonArray) {
                                 btn.alpha = 0.0;
                             }
                         } completion:^(BOOL finished) {
                             for (UIButton *btn in self.buttonArray) {
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

- (void)drawWithColorBtn:(UIButton *)btn {
    self.textColor = btn.tintColor;
    self.drawingColor = btn.tintColor;
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
