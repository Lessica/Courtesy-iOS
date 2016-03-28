//
//  JVFloatingDrawerViewController.h
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-11.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JVFloatingDrawerAnimation;

typedef NS_ENUM(NSInteger, JVFloatingDrawerSide) {
    JVFloatingDrawerSideNone = 0,
    JVFloatingDrawerSideLeft,
    JVFloatingDrawerSideRight
};

@protocol JVFloatingDrawerCenterViewController <NSObject>
@optional
- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide;

@end

@interface JVFloatingDrawerViewController : UIViewController

#pragma mark - Managed View Controllers

@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

#pragma mark - Reveal Widths

@property (nonatomic, assign) CGFloat leftDrawerWidth;
@property (nonatomic, assign) CGFloat rightDrawerWidth;

#pragma mark - Interaction

@property (nonatomic, assign, getter=isDragToRevealEnabled) BOOL dragToRevealEnabled;

- (void)openDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated
                completion:(void(^)(BOOL finished))completion;

- (void)closeDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated
                 completion:(void(^)(BOOL finished))completion;

- (void)toggleDrawerWithSide:(JVFloatingDrawerSide)drawerSide animated:(BOOL)animated
                  completion:(void(^)(BOOL finished))completion;

#pragma mark - Animation

@property (nonatomic, strong) id<JVFloatingDrawerAnimation> animator;

#pragma mark - Background

@property (nonatomic, strong) UIImage *backgroundImage;

#pragma mark - Pan Gesture

@property (nonatomic, assign) CGFloat minimumDragDistance;
@property (nonatomic, assign) CGFloat dragRespondingWidth;

@end
