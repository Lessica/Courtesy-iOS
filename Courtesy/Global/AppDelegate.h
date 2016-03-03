//
//  AppDelegate.h
//  Courtesy
//
//  Created by i_82 on 2016-02-20.
//  Copyright (c) 2016 82Flex. All rights reserved.
//

@class JVFloatingDrawerViewController;
@class JVFloatingDrawerSpringAnimator;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) JVFloatingDrawerViewController *drawerViewController;
@property (nonatomic, strong) JVFloatingDrawerSpringAnimator *drawerAnimator;

@property (nonatomic, strong) UITableViewController *leftDrawerViewController;
@property (nonatomic, strong) UITableViewController *rightDrawerViewController;
@property (nonatomic, strong) UIViewController *myViewController;
@property (nonatomic, strong) UIViewController *starViewController;
@property (nonatomic, strong) UIViewController *galleryViewController;
@property (nonatomic, strong) UIViewController *settingsViewController;
@property (nonatomic, strong) UIViewController *drawerSettingsViewController;
@property (nonatomic, strong) UIViewController *githubViewController;
@property (nonatomic, strong) UIViewController *profileViewController;
@property (nonatomic, strong) UIViewController *emptyViewController;

+ (AppDelegate *)globalDelegate;

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated;
- (void)toggleRightDrawer:(id)sender animated:(BOOL)animated;

@end

