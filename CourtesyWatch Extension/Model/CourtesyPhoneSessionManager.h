//
//  CourtesyPhoneSessionManager.h
//  Courtesy
//
//  Created by Zheng on 3/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyWatchQueryKeys.h"
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@class CourtesyPhoneSessionManager;

@protocol CourtesyPhoneSessionDelegate <NSObject>

@optional
- (void)sessionRequestSucceed:(CourtesyPhoneSessionManager *)manager
              withLoginStatus:(int)status;
@optional
- (void)sessionRequestFailed:(CourtesyPhoneSessionManager *)manager
                   withError:(NSError *)error;
@optional
- (void)session:(CourtesyPhoneSessionManager *)manager didReceiveNewMessage:(NSString *)message;

@end

@interface CourtesyPhoneSessionManager : NSObject <WCSessionDelegate>
@property (nonatomic, weak) id<CourtesyPhoneSessionDelegate> delegate;

- (void)startSession;
- (void)checkLoginStatus;

@end
