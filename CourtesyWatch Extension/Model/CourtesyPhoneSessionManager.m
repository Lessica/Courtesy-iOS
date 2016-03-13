//
//  CourtesyPhoneSessionManager.m
//  Courtesy
//
//  Created by Zheng on 3/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyPhoneSessionManager.h"

@implementation CourtesyPhoneSessionManager

- (void)startSession {
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)checkLoginStatus {
    __weak typeof(self) weakSelf = self;
    [self sessionSendNewAction:kCourtesyQueryLogin message:@"" withReplyBlock:^(NSDictionary *replyBlock) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!replyBlock) return;
        int status = [[replyBlock objectForKey:@"result"] intValue];
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sessionRequestSucceed:withLoginStatus:)])
            [strongSelf.delegate sessionRequestSucceed:strongSelf withLoginStatus:status];
    }];
}

- (void)sessionSendNewAction:(NSString *)action message:(NSString *)message withReplyBlock:(void(^) (NSDictionary *))replyBlock {
    if ([[WCSession defaultSession] isReachable]) {
        __weak typeof(self) weakSelf = self;
        [[WCSession defaultSession] sendMessage:@{@"action": action, @"message": message}
                                   replyHandler:replyBlock
                                   errorHandler:^(NSError *error) {
                                       __strong typeof(self) strongSelf = weakSelf;
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(sessionRequestFailed:withError:)]) {
                                               [strongSelf.delegate sessionRequestFailed:strongSelf withError:error];
                                           }
                                       });
                                   }
         ];
    }
}

#pragma mark - WCSessionDelegate

- (void)sessionWatchStateDidChange:(WCSession *)session
{
    NSLog(@"%s: session = %@", __func__, session);
}

// Application Context
- (void)session:(nonnull WCSession *)session didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", [NSString stringWithFormat:@"%s: %@", __func__, applicationContext]);
    });
}

// User Info Transfer
- (void)session:(nonnull WCSession *)session didReceiveUserInfo:(nonnull NSDictionary<NSString *,id> *)userInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", [NSString stringWithFormat:@"%s: %@", __func__, userInfo]);
    });
}

// File Transfer
- (void)session:(nonnull WCSession *)session didReceiveFile:(nonnull WCSessionFile *)file
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", [NSString stringWithFormat:@"%s: %@", __func__, file]);
    });
}

// Interactive Message
- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * __nonnull))replyHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", [NSString stringWithFormat:@"%s: %@", __func__, message]);
    });
    if (!message) return;
    if ([message objectForKey:kCourtesyQueryLogin]) {
        int status = [[message objectForKey:kCourtesyQueryLogin] intValue];
        if (self.delegate && [self.delegate respondsToSelector:@selector(sessionRequestSucceed:withLoginStatus:)])
            [self.delegate sessionRequestSucceed:self withLoginStatus:status];
    }
    if (replyHandler) replyHandler(@{@"result" : @"yes"});
}

@end
