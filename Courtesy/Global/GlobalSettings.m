//
//  GlobalSettings.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "GlobalSettings.h"
#import "JSONHTTPClient.h"

#define kCourtesyDB @"kCourtesyDB"
#define kCourtesyDBCurrentLoginAccount @"kCourtesyDBCurrentLoginAccount"
#define kSwitchAutoSave @"switchAutoSave"
#define kSwitchAutoPublic @"switchAutoPublic"

@interface GlobalSettings () <CourtesyFetchAccountInfoDelegate>

@end

@implementation GlobalSettings {
    YYCache *appStorage;
    YYReachability *localReachability;
}

- (instancetype)init {
    if (self = [super init]) {
        // 初始化基本设置
        self.switchAutoPublic = NO;
        self.switchAutoPublic = NO;
        self.fetchedCurrentAccount = NO;
        // 初始化网络设置
        [JSONHTTPClient setDefaultTextEncoding:NSUTF8StringEncoding];
        [JSONHTTPClient setRequestContentType:@"application/json"];
        [JSONHTTPClient setCachingPolicy:NSURLRequestReloadIgnoringCacheData];
        [JSONHTTPClient setTimeoutInSeconds:20];
        // 初始化网络状态监听
        localReachability = [YYReachability reachability];
        localReachability.notifyBlock = ^(YYReachability *reachability) {
            if (reachability.status == YYReachabilityStatusNone) {
                [JDStatusBarNotification showWithStatus:@"网络连接失败"
                                           dismissAfter:kStatusBarNotificationTime
                                              styleName:JDStatusBarStyleError];
                return;
            }
            if (reachability.status == YYReachabilityStatusWWAN) {
                [JDStatusBarNotification showWithStatus:@"正在使用蜂窝数据网络"
                                           dismissAfter:kStatusBarNotificationTime
                                              styleName:JDStatusBarStyleSuccess];
            } else if (reachability.status == YYReachabilityStatusWiFi) {
                [JDStatusBarNotification showWithStatus:@"正在使用无线局域网"
                                           dismissAfter:kStatusBarNotificationTime
                                              styleName:JDStatusBarStyleSuccess];
            }
        };
        // 初始化推送通知
        if (![self hasNotificationPermission]) [self requestedNotifications];
        // 初始化数据库设置
        if (!appStorage) appStorage = [[YYCache alloc] initWithName:kCourtesyDB];
        self.currentAccount = [[CourtesyAccountModel alloc] initWithDelegate:self];
        if (!appStorage || !self.currentAccount) {
            @throw NSException(kCourtesyAllocFailed, @"应用程序启动失败");
        }
        // 初始化账户信息
        if ([self sessionKey] != nil) {
            if ([appStorage containsObjectForKey:kCourtesyDBCurrentLoginAccount]) {
                NSError *error = nil;
                NSDictionary *dict = (NSDictionary *)[appStorage objectForKey:kCourtesyDBCurrentLoginAccount];
                self.currentAccount = [[CourtesyAccountModel alloc] initWithDictionary:dict error:&error];
                [self.currentAccount setDelegate:self];
                if (error || !_currentAccount) {
                    self.currentAccount = [[CourtesyAccountModel alloc] initWithDelegate:self];
                    // 如果缓存中数据不正常则需要移除
                    [appStorage removeObjectForKey:kCourtesyDBCurrentLoginAccount];
                } else {
                    CYLog(@"Login as: %@", _currentAccount.email);
                    // 检测到登录状态，启动信息获取线程
                    [self fetchCurrentAccountInfo];
                }
            } else {
                CYLog(@"No login cache");
                [self removeCookies];
            }
        } else if ([appStorage containsObjectForKey:kCourtesyDBCurrentLoginAccount]) {
            CYLog(@"Login expired");
            [appStorage removeObjectForKey:kCourtesyDBCurrentLoginAccount];
        } else {
            CYLog(@"Not login");
        }
    }
    return self;
}

+ (id)sharedInstance {
    static GlobalSettings *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - 账户相关

- (CourtesyAccountModel *)currentAccount {
    if (!_currentAccount) {
        _currentAccount = [[CourtesyAccountModel alloc] initWithDelegate:self];
    }
    return _currentAccount;
}

#pragma mark - 登录

- (BOOL)hasLogin {
    return (self.currentAccount != nil && [self.currentAccount email] != nil);
}

// 将当前账户及其 Profile 存入账户

- (void)reloadAccount {
    [appStorage setObject:[self.currentAccount toDictionary] forKey:kCourtesyDBCurrentLoginAccount];
}

- (void)setHasLogin:(BOOL)hasLogin {
    if (hasLogin) {
        if (!self.currentAccount || ![self.currentAccount email]) return;
        [self reloadAccount];
        // 已登录，启动信息获取线程
        [self fetchCurrentAccountInfo];
    } else {
        CYLog(@"Logout or expired!");
        [self removeCookies];
        if (!self.currentAccount) return;
        self.currentAccount = [[CourtesyAccountModel alloc] initWithDelegate:self];
        if ([appStorage containsObjectForKey:kCourtesyDBCurrentLoginAccount]) {
            [appStorage removeObjectForKey:kCourtesyDBCurrentLoginAccount];
        }
        [NSNotificationCenter sendCTAction:kActionLogout message:nil];
    }
}

#pragma mark - 获取用户信息

- (void)fetchCurrentAccountInfo {
    [NSNotificationCenter sendCTAction:kActionFetching message:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [self.currentAccount sendRequestFetchAccountInfo];
    });
}

#pragma mark - CourtesyFetchAccountInfoDelegate

- (void)fetchAccountInfoSucceed:(CourtesyAccountModel *)sender {
    [NSNotificationCenter sendCTAction:kActionFetchSucceed message:nil];
}

- (void)fetchAccountInfoFailed:(CourtesyAccountModel *)sender
                  errorMessage:(NSString *)message {
    [NSNotificationCenter sendCTAction:kActionFetchFailed message:message];
}

#pragma mark - 会话相关
// 从系统原生 CookieJar 中取得 Cookie
- (NSString *)sessionKey {
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        if ([[cookie domain] isEqualToString:API_DOMAIN] && [[cookie name] isEqualToString:@"sessionid"]) {
            CYLog(@"Current session key: %@", [cookie value]);
            return [cookie value];
        }
    }
    return nil;
}

// 移除 CookieJar 中所有 Cookie
- (void)removeCookies {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 推送相关

- (BOOL)hasNotificationPermission {
    return (UIUserNotificationTypeNone != [[UIApplication sharedApplication] currentUserNotificationSettings].types);
}

- (UIUserNotificationSettings *)requestedNotifications {
    UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
    action1.identifier = @"action1_identifier";
    action1.title=@"Accept";
    action1.activationMode = UIUserNotificationActivationModeForeground;
    
    UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
    action2.identifier = @"action2_identifier";
    action2.title=@"Reject";
    action2.activationMode = UIUserNotificationActivationModeBackground;
    action2.authenticationRequired = YES;
    action2.destructive = YES;
    
    UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
    categorys.identifier = @"category1";
    [categorys setActions:@[action1, action2] forContext:(UIUserNotificationActionContextDefault)];
    
    UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert
                                                                                 categories:[NSSet setWithObject:categorys]];
    
    return userSettings;
}

#pragma mark - 个性化设置相关

- (BOOL)switchAutoPublic {
    return [(NSNumber *)[appStorage objectForKey:kSwitchAutoPublic] isEqualToNumber:@0] ? NO : YES;
}

- (void)setSwitchAutoPublic:(BOOL)switchAutoPublic {
    [appStorage setObject:(switchAutoPublic ? @1 : @0) forKey:kSwitchAutoPublic];
}

- (BOOL)switchAutoSave {
    return [(NSNumber *)[appStorage objectForKey:kSwitchAutoSave] isEqualToNumber:@0] ? NO : YES;
}

- (void)setSwitchAutoSave:(BOOL)switchAutoSave {
    [appStorage setObject:(switchAutoSave ? @1 : @0) forKey:kSwitchAutoSave];
}

@end
