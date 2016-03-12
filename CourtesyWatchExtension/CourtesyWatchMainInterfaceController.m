//
//  CourtesyWatchMainInterfaceController.m
//  watch Extension
//
//  Created by Zheng on 3/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyWatchQueryKeys.h"
#import "ExtensionDelegate.h"
#import "CourtesyWatchMainInterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface CourtesyWatchMainInterfaceController () <WCSessionDelegate>

@end


@implementation CourtesyWatchMainInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self checkHasLogin];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)checkHasLogin {
    if ([[WCSession defaultSession] isReachable]) {
        [[WCSession defaultSession] sendMessage:@{@"action": kCourtesyQueryLogin}
                                   replyHandler:^(NSDictionary *replyHandler) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           NSLog(@"%@", [NSString stringWithFormat:@"%s: %@", __func__, replyHandler]);
                                           if (replyHandler) {
                                               int status = [[replyHandler objectForKey:@"result"] intValue];
                                               if (status == 0) {
                                                   [self presentControllerWithName:kCourtesyWatchInterfaceNotLogin context:nil];
                                               }
                                           }
                                       });
                                   }
                                   errorHandler:^(NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           NSLog(@"%@", error);
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
    if (message) {
        int status = [[message objectForKey:kCourtesyQueryLogin] intValue];
        if (status == 0) {
            [self presentControllerWithName:kCourtesyWatchInterfaceNotLogin context:nil];
        }
    }
    if (replyHandler) {
        replyHandler(@{@"result" : @"yes"});
    }
}

@end



