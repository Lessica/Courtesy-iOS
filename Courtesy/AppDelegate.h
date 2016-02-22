//
//  AppDelegate.h
//  Courtesy
//
//  Created by i_82 on 2016-02-20.
//  Copyright (c) 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CourtesyQRScanViewController;
@class JVFloatingDrawerViewController;
@class JVFloatingDrawerSpringAnimator;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) JVFloatingDrawerViewController *drawerViewController;
@property (nonatomic, strong) JVFloatingDrawerSpringAnimator *drawerAnimator;

@property (nonatomic, strong) UITableViewController *leftDrawerViewController;
@property (nonatomic, strong) UITableViewController *rightDrawerViewController;
@property (nonatomic, strong) CourtesyQRScanViewController *scanViewController;
@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *settingsViewController;
@property (nonatomic, strong) UIViewController *drawerSettingsViewController;
@property (nonatomic, strong) UIViewController *githubViewController;

+ (AppDelegate *)globalDelegate;

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated;
- (void)toggleRightDrawer:(id)sender animated:(BOOL)animated;
- (void)toggleScanView:(UIViewController *)sender animated:(BOOL)animated;

@end

