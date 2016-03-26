//
//  CourtesyWatchSessionManager.m
//  Courtesy
//
//  Created by Zheng on 3/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#ifdef WATCH_SUPPORT

#import "CourtesyWatchSessionManager.h"

@implementation CourtesyWatchSessionManager

- (void)startSession {
    if ([WCSession isSupported]) { // What's the fuking memory leak?
        WCSession *watchSession = [WCSession defaultSession];
        watchSession.delegate = self;
        [watchSession activateSession];
    }
}

- (void)notifyLoginStatus {
    [[WCSession defaultSession] sendMessage:@{kCourtesyQueryLogin: [NSNumber numberWithBool:[sharedSettings hasLogin]]}
                               replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                                   CYLog(@"%@", replyMessage);
                               } errorHandler:^(NSError * _Nonnull error) {
                                   CYLog(@"%@", error);
                               }];
}

// Interactive Message
- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * __nonnull))replyHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        CYLog(@"%@", message);
    });
    if (!message || ![message hasKey:@"action"]) return;
    NSString *action = [message stringValueForKey:@"action" default:@"alive"];
    if ([action isEqualToString:kCourtesyQueryLogin]) {
        replyHandler(@{@"result" : [NSNumber numberWithBool:[sharedSettings hasLogin]]});
    } else {
        replyHandler(@{@"result" : @"yes"});
    }
}

@end

#endif
