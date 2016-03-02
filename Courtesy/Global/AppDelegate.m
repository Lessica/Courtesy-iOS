//
//  AppDelegate.m
//  Courtesy
//
//  Created by i_82 on 2016-02-20.
//  Copyright (c) 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "JVFloatingDrawerViewController.h"
#import "JVFloatingDrawerSpringAnimator.h"
#import "CourtesyLeftDrawerTableViewController.h"

static NSString * const kJVDrawersStoryboardName = @"Drawers";
static NSString * const kJVLeftDrawerStoryboardID = @"JVLeftDrawerViewControllerStoryboardID";
static NSString * const kJVRightDrawerStoryboardID = @"JVRightDrawerViewControllerStoryboardID";
static NSString * const kCourtesyProfileTableViewControllerStoryboardID = @"CourtesyProfileTableViewControllerStoryboardID";
static NSString * const kCourtesyMyTabViewControllerStoryboardID = @"CourtesyMyTabViewControllerStoryboardID";
static NSString * const kCourtesyStarTableViewControllerStoryboardID = @"CourtesyStarTableViewControllerStoryboardID";
static NSString * const kCourtesyGalleryTableViewControllerStoryboardID = @"CourtesyGalleryTableViewControllerStoryboardID";
static NSString * const kJVDrawerSettingsViewControllerStoryboardID = @"JVDrawerSettingsViewControllerStoryboardID";
static NSString * const kCourtesySettingsViewControllerStoryboardID = @"CourtesySettingsViewControllerStoryboardID";
static NSString * const kJVGitHubProjectPageViewControllerStoryboardID = @"JVGitHubProjectPageViewControllerStoryboardID";

@interface AppDelegate ()
@property (nonatomic, strong, readonly) UIStoryboard *drawersStoryboard;
@end

@implementation AppDelegate

@synthesize drawersStoryboard = _drawersStoryboard;

#pragma mark - 继承应用状态响应方法

#pragma mark - 注册友盟SDK及推送消息
- (void)globalInit {
    // 初始化全局设置
    sharedSettings;
    // 初始化界面
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.drawerViewController;
    self.window.tintColor = [UIColor magicColor];
    [self configureDrawerViewController];
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 友盟推送
    [UMessage startWithAppkey:UMENG_APP_KEY launchOptions:launchOptions];
    [UMessage registerRemoteNotificationAndUserNotificationSettings:[sharedSettings requestedNotifications]];
    // 友盟社会化分享
    [UMSocialData setAppKey:UMENG_APP_KEY];
    [self globalInit];
    if ([launchOptions hasKey:UIApplicationLaunchOptionsShortcutItemKey]) {
        // Some thing that should not respond to immediately...
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [UMessage registerDeviceToken:deviceToken];
}

// 快捷方式
// Thanks: http://www.jianshu.com/p/74fe6cbc542b
- (void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if (shortcutItem) {
        SEL selector;
        if ([shortcutItem.type isEqualToString:@"Scan"]) {
            selector = @selector(shortcutScan);
        } else if ([shortcutItem.type isEqualToString:@"Compose"]) {
            selector = @selector(shortcutCompose);
        } else if ([shortcutItem.type isEqualToString:@"Share"]) {
            selector = @selector(shortcutShare);
        }
        [(CourtesyLeftDrawerTableViewController *)_leftDrawerViewController performSelector:selector withObject:nil afterDelay:1.0];
        if (completionHandler) {
            completionHandler(YES);
        }
        return;
    } else if (completionHandler) {
        completionHandler(NO);
    }
}

// 从后台唤醒
- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([sharedSettings hasLogin] && ![kAccount isRequestingFetchAccountInfo] && ![sharedSettings fetchedCurrentAccount]) {
        [sharedSettings fetchCurrentAccountInfo];
    }
}

// Bug: http://stackoverflow.com/questions/32344082/error-handlenonlaunchspecificactions-in-ios9
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {}
- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}

#pragma mark - 注册框架故事板

- (UIStoryboard *)drawersStoryboard {
    if(!_drawersStoryboard) {
        _drawersStoryboard = [UIStoryboard storyboardWithName:kJVDrawersStoryboardName bundle:nil];
    }
    
    return _drawersStoryboard;
}

- (JVFloatingDrawerSpringAnimator *)drawerAnimator {
    if (!_drawerAnimator) {
        _drawerAnimator = [[JVFloatingDrawerSpringAnimator alloc] init];
    }
    
    return _drawerAnimator;
}

#pragma mark - 全局视图操作控制

+ (AppDelegate *)globalDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)toggleLeftDrawer:(id)sender animated:(BOOL)animated {
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideLeft animated:animated completion:nil];
}

- (void)toggleRightDrawer:(id)sender animated:(BOOL)animated {
    [self.drawerViewController toggleDrawerWithSide:JVFloatingDrawerSideRight animated:animated completion:nil];
}

#pragma mark - 注册框架视图控制器

- (JVFloatingDrawerViewController *)drawerViewController {
    if (!_drawerViewController) {
        _drawerViewController = [[JVFloatingDrawerViewController alloc] init];
    }
    
    return _drawerViewController;
}

#pragma mark - 注册两侧视图控制器

- (UITableViewController *)leftDrawerViewController {
    if (!_leftDrawerViewController) {
        _leftDrawerViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVLeftDrawerStoryboardID];
    }
    
    return _leftDrawerViewController;
}

- (UITableViewController *)rightDrawerViewController {
    if (!_rightDrawerViewController) {
        _rightDrawerViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVRightDrawerStoryboardID];
    }
    
    return _rightDrawerViewController;
}

#pragma mark - 注册中央视图控制器

- (void)configureDrawerViewController {
    self.drawerViewController.leftViewController = self.leftDrawerViewController;
    self.drawerViewController.rightViewController = self.rightDrawerViewController;
    self.drawerViewController.centerViewController = self.galleryViewController;
    
    self.drawerViewController.animator = self.drawerAnimator;
    
    self.drawerViewController.backgroundImage = [UIImage imageNamed:@"sky"];
}

#pragma mark - 各个菜单视图

- (UIViewController *)myViewController {
    if (!_myViewController) {
        _myViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kCourtesyMyTabViewControllerStoryboardID];
    }
    
    return _myViewController;
}

- (UIViewController *)starViewController {
    if (!_starViewController) {
        _starViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kCourtesyStarTableViewControllerStoryboardID];
    }
    
    return _starViewController;
}

- (UIViewController *)galleryViewController {
    if (!_galleryViewController) {
        _galleryViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kCourtesyGalleryTableViewControllerStoryboardID];
    }
    
    return _galleryViewController;
}

- (UIViewController *)settingsViewController {
    if (!_settingsViewController) {
        _settingsViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kCourtesySettingsViewControllerStoryboardID];
    }
    
    return _settingsViewController;
}

- (UIViewController *)drawerSettingsViewController {
    if (!_drawerSettingsViewController) {
        _drawerSettingsViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVDrawerSettingsViewControllerStoryboardID];
    }
    
    return _drawerSettingsViewController;
}

- (UIViewController *)githubViewController {
    if (!_githubViewController) {
        _githubViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kJVGitHubProjectPageViewControllerStoryboardID];
    }
    
    return _githubViewController;
}

- (UIViewController *)profileViewController {
    if (!_profileViewController) {
        _profileViewController = [self.drawersStoryboard instantiateViewControllerWithIdentifier:kCourtesyProfileTableViewControllerStoryboardID];
    }
    return _profileViewController;
}

@end
