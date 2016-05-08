//
//  GlobalSettings.m
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppStorage.h"
#import "GlobalSettings.h"
#import "JSONHTTPClient.h"
#import "CourtesyLoginRegisterModel.h"

#define kCourtesyDBCurrentLoginAccount @"kCourtesyDBCurrentLoginAccount"
#define kCourtesyConfigSwitchAutoPublic @"kCourtesyConfigSwitchAutoPublic"
#define kCourtesyConfigSwitchMarkdown @"kCourtesyConfigSwitchMarkdown"
#define kCourtesyConfigSwitchPreviewNeedsShadows @"kCourtesyConfigSwitchPreviewNeedsShadows"
#define kCourtesyConfigSwitchPreviewAvatar @"kCourtesyConfigSwitchPreviewAvatar"
#define kCourtesyConfigPreferredImageQuality @"kCourtesyConfigPreferredImageQuality"
#define kCourtesyConfigPreferredVideoQuality @"kCourtesyConfigPreferredVideoQuality"
#define kCourtesyConfigPreferredFontType @"kCourtesyConfigPreferredFontType"
#define kCourtesyConfigPreferredStyleID @"kCourtesyConfigPreferredStyleID"
#define kCourtesyConfigPreferredPreviewStyleID @"kCourtesyConfigPreferredPreviewStyleID"
#define kCourtesyConfigPreferredFontSize @"kCourtesyConfigPreferredFontSize"

#ifdef WATCH_SUPPORT
@interface GlobalSettings () <CourtesyFetchAccountInfoDelegate, WCSessionDelegate, TencentSessionDelegate, TencentApiInterfaceDelegate, TCAPIRequestDelegate>
#else
@interface GlobalSettings () <CourtesyFetchAccountInfoDelegate, TencentSessionDelegate, TencentApiInterfaceDelegate, TCAPIRequestDelegate>
#endif

@end

@implementation GlobalSettings

- (instancetype)init {
    if (self = [super init]) {
        // 初始化基本设置
        self.fetchedCurrentAccount = NO;
        // 初始化提示消息
        [CSToastManager setTapToDismissEnabled:YES];
        [CSToastManager setQueueEnabled:NO];
        // 初始化网络设置
        [JSONHTTPClient setDefaultTextEncoding:NSUTF8StringEncoding];
        [JSONHTTPClient setRequestContentType:@"application/json"];
        [JSONHTTPClient setCachingPolicy:NSURLRequestReloadIgnoringCacheData];
        [JSONHTTPClient setTimeoutInSeconds:20];
        // 初始化网络状态监听
        self.localReachability = [YYReachability reachability];
        self.localReachability.notifyBlock = ^(YYReachability *reachability) {
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
        self.currentAccount = [[CourtesyAccountModel alloc] initWithDelegate:self];
        if (!self.appStorage || !self.currentAccount) {
            @throw NSCustomException(kCourtesyAllocFailed, @"应用程序启动失败");
        }
#ifdef WATCH_SUPPORT
        // 初始化 Apple Watch 通信管理器
        self.watchSessionManager = [CourtesyWatchSessionManager new];
        [self.watchSessionManager startSession];
#endif
        // 初始化账户信息
        if ([self sessionKey] != nil) {
            if ([self.appStorage containsObjectForKey:kCourtesyDBCurrentLoginAccount]) {
                NSError *error = nil;
                NSDictionary *dict = (NSDictionary *)[self.appStorage objectForKey:kCourtesyDBCurrentLoginAccount];
                self.currentAccount = [[CourtesyAccountModel alloc] initWithDictionary:dict error:&error];
                [self.currentAccount setDelegate:self];
                if (error || !_currentAccount) {
                    self.currentAccount = [[CourtesyAccountModel alloc] initWithDelegate:self];
                    // 如果缓存中数据不正常则需要移除
                    [self.appStorage removeObjectForKey:kCourtesyDBCurrentLoginAccount];
                } else {
                    CYLog(@"Login as: %@", _currentAccount.email);
                    // 检测到登录状态，启动信息获取线程
                    [self fetchCurrentAccountInfo];
                }
            } else {
                CYLog(@"No login cache");
                [self removeCookies];
            }
        } else if ([self.appStorage containsObjectForKey:kCourtesyDBCurrentLoginAccount]) {
            CYLog(@"Login expired");
            [self.appStorage removeObjectForKey:kCourtesyDBCurrentLoginAccount];
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

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
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
    [self.appStorage setObject:[self.currentAccount toDictionary] forKey:kCourtesyDBCurrentLoginAccount];
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
        if ([self.appStorage containsObjectForKey:kCourtesyDBCurrentLoginAccount]) {
            [self.appStorage removeObjectForKey:kCourtesyDBCurrentLoginAccount];
        }
        [NSNotificationCenter sendCTAction:kCourtesyActionLogout message:nil];
    }
#ifdef WATCH_SUPPORT
    [self.watchSessionManager notifyLoginStatus];
#endif
}

#pragma mark - 获取用户信息

- (void)fetchCurrentAccountInfo {
    [NSNotificationCenter sendCTAction:kCourtesyActionFetching message:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        [self.currentAccount sendRequestFetchAccountInfo];
    });
}

#pragma mark - CourtesyFetchAccountInfoDelegate

- (void)fetchAccountInfoSucceed:(CourtesyAccountModel *)sender {
    [NSNotificationCenter sendCTAction:kCourtesyActionFetchSucceed message:nil];
}

- (void)fetchAccountInfoFailed:(CourtesyAccountModel *)sender
                  errorMessage:(NSString *)message {
    [NSNotificationCenter sendCTAction:kCourtesyActionFetchFailed message:message];
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
    if (![self.appStorage objectForKey:kCourtesyConfigSwitchAutoPublic]) {
        return YES;
    }
    return [(NSNumber *)[self.appStorage objectForKey:kCourtesyConfigSwitchAutoPublic] isEqualToNumber:@0] ? NO : YES;
}

- (void)setSwitchAutoPublic:(BOOL)switchAutoPublic {
    [self.appStorage setObject:(switchAutoPublic ? @1 : @0) forKey:kCourtesyConfigSwitchAutoPublic];
}

- (BOOL)switchMarkdown {
    if (![self.appStorage objectForKey:kCourtesyConfigSwitchMarkdown]) {
        return YES;
    }
    return [(NSNumber *)[self.appStorage objectForKey:kCourtesyConfigSwitchMarkdown] isEqualToNumber:@0] ? NO : YES;
}

- (void)setSwitchMarkdown:(BOOL)switchMarkdown {
    [self.appStorage setObject:(switchMarkdown ? @1 : @0) forKey:kCourtesyConfigSwitchMarkdown];
}

- (BOOL)switchPreviewAvatar {
    if (![self.appStorage objectForKey:kCourtesyConfigSwitchPreviewAvatar]) {
        return YES;
    }
    return [(NSNumber *)[self.appStorage objectForKey:kCourtesyConfigSwitchPreviewAvatar] isEqualToNumber:@0] ? NO : YES;
}

- (void)setSwitchPreviewAvatar:(BOOL)switchPreviewAvatar {
    [self.appStorage setObject:(switchPreviewAvatar ? @1 : @0) forKey:kCourtesyConfigSwitchPreviewAvatar];
}

- (BOOL)switchPreviewNeedsShadows {
    if (![self.appStorage objectForKey:kCourtesyConfigSwitchPreviewNeedsShadows]) {
        return NO;
    }
    return [(NSNumber *)[self.appStorage objectForKey:kCourtesyConfigSwitchPreviewNeedsShadows] isEqualToNumber:@0] ? NO : YES;
}

- (void)setSwitchPreviewNeedsShadows:(BOOL)switchPreviewNeedsShadows {
    [self.appStorage setObject:(switchPreviewNeedsShadows ? @1 : @0) forKey:kCourtesyConfigSwitchPreviewNeedsShadows];
}

- (float)preferredImageQuality {
    if (![self.appStorage objectForKey:kCourtesyConfigPreferredImageQuality]) {
        return kCourtesyQualityMedium;
    }
    return [(NSNumber *)[self.appStorage objectForKey:kCourtesyConfigPreferredImageQuality] floatValue];
}

- (void)setPreferredImageQuality:(float)preferredImageQuality {
    [self.appStorage setObject:[NSNumber numberWithFloat:preferredImageQuality] forKey:kCourtesyConfigPreferredImageQuality];
}

- (UIImagePickerControllerQualityType)preferredVideoQuality {
    if (![self.appStorage objectForKey:kCourtesyConfigPreferredVideoQuality]) {
        return UIImagePickerControllerQualityTypeMedium;
    }
    return [(NSNumber *)[self.appStorage objectForKey:kCourtesyConfigPreferredVideoQuality] integerValue];
}

- (void)setPreferredVideoQuality:(UIImagePickerControllerQualityType)preferredVideoQuality {
    [self.appStorage setObject:[NSNumber numberWithInteger:preferredVideoQuality] forKey:kCourtesyConfigPreferredVideoQuality];
}

- (NSUInteger)preferredFontType {
    if (![self.appStorage objectForKey:kCourtesyConfigPreferredFontType]) {
        return 0;
    }
    return [(NSNumber *)[self.appStorage objectForKey:kCourtesyConfigPreferredFontType] unsignedIntegerValue];
}

- (void)setPreferredFontType:(NSUInteger)preferredFontType {
    [self.appStorage setObject:[NSNumber numberWithUnsignedInteger:preferredFontType] forKey:kCourtesyConfigPreferredFontType];
}

- (NSUInteger)preferredStyleID {
    if (![self.appStorage objectForKey:kCourtesyConfigPreferredStyleID]) {
        return 0;
    }
    return [(NSNumber *)[self.appStorage objectForKey:kCourtesyConfigPreferredStyleID] unsignedIntegerValue];
}

- (void)setPreferredStyleID:(NSUInteger)preferredStyleID {
    [self.appStorage setObject:[NSNumber numberWithUnsignedInteger:preferredStyleID] forKey:kCourtesyConfigPreferredStyleID];
}

- (NSUInteger)preferredPreviewStyleType {
    if (![self.appStorage objectForKey:kCourtesyConfigPreferredPreviewStyleID]) {
        return 0;
    }
    return [(NSNumber *)[self.appStorage objectForKey:kCourtesyConfigPreferredPreviewStyleID] unsignedIntegerValue];
}

- (void)setPreferredPreviewStyleType:(NSUInteger)preferredPreviewStyleType {
    [self.appStorage setObject:[NSNumber numberWithUnsignedInteger:preferredPreviewStyleType] forKey:kCourtesyConfigPreferredPreviewStyleID];
}

- (CGFloat)preferredFontSize {
    if (![self.appStorage objectForKey:kCourtesyConfigPreferredFontSize]) {
        return 16.0;
    }
    return [(NSNumber *)[self.appStorage objectForKey:kCourtesyConfigPreferredFontSize] floatValue];
}

- (void)setPreferredFontSize:(CGFloat)preferredFontSize {
    [self.appStorage setObject:[NSNumber numberWithFloat:preferredFontSize] forKey:kCourtesyConfigPreferredFontSize];
}

#pragma mark - 腾讯互联接口

- (TencentOAuth *)tencentAuth {
    if (!_tencentAuth) {
        _tencentAuth = [[TencentOAuth alloc] initWithAppId:TENCENT_APP_ID andDelegate:self];
    }
    return _tencentAuth;
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCourtesyNotificationInfo
                                                        object:@{@"action": kTencentLoginCancelled,
                                                                 @"message": @"用户取消登录"}];
}

- (void)tencentDidNotNetWork {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCourtesyNotificationInfo
                                                        object:@{@"action": kTencentLoginFailed,
                                                                 @"message": @"请检查网络连接"}];
}

- (void)tencentDidLogin {
    kAccount.tencentModel.openId = _tencentAuth.openId;
    kAccount.tencentModel.accessToken = _tencentAuth.accessToken;
    kAccount.tencentModel.expirationTime = [_tencentAuth.expirationDate timeIntervalSince1970];
    [self reloadAccount];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCourtesyNotificationInfo
                                                        object:@{@"action": kTencentLoginSuccessed}];
}

- (void)getUserInfoResponse:(APIResponse *)response {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCourtesyNotificationInfo
                                                        object:@{@"action": kTencentGetUserInfoSucceed,
                                                                 @"response": response}];
}

@end
