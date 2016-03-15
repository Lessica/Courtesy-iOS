//
//  GlobalSettings.h
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//  It is a singleton.

#import "JSONModel.h"
#import "CourtesyAccountModel.h"
#import "CourtesyWatchSessionManager.h"
#import <YYKit/YYCache.h>
#import <YYKit/YYReachability.h>

@interface GlobalSettings : NSObject

// 单例
+ (id)sharedInstance;

@property (nonatomic, assign) BOOL hasLogin;
@property (nonatomic, copy) NSString<Ignore> *sessionKey;
@property (nonatomic, readonly) UIUserNotificationSettings<Ignore> *requestedNotifications;
@property (nonatomic, assign) BOOL hasNotificationPermission;
@property (nonatomic, strong) CourtesyAccountModel<Ignore> *currentAccount;
@property (nonatomic, assign) BOOL fetchedCurrentAccount;
@property (nonatomic, strong) CourtesyWatchSessionManager *watchSessionManager;
@property (nonatomic, strong) YYCache *appStorage;
@property (nonatomic, strong) YYReachability *localReachability;

@property (nonatomic, assign) BOOL switchAutoSave;
@property (nonatomic, assign) BOOL switchAutoPublic;
@property (nonatomic, assign) BOOL switchMarkdown;
@property (nonatomic, assign) NSInteger preferredImageQuality;
@property (nonatomic, assign) NSInteger preferredVideoQuality;

- (void)fetchCurrentAccountInfo;
- (void)reloadAccount;

@end
