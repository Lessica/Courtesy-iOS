//
//  CourtesyWatchMainInterfaceController.m
//  watch Extension
//
//  Created by Zheng on 3/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "CourtesyWatchMainInterfaceController.h"

@interface CourtesyWatchMainInterfaceController ()

@end


@implementation CourtesyWatchMainInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    self.phoneSessionManager = [CourtesyPhoneSessionManager new];
    [self.phoneSessionManager startSession];
    self.phoneSessionManager.delegate = self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self.phoneSessionManager checkLoginStatus];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)sessionRequestSucceed:(CourtesyPhoneSessionManager *)manager
              withLoginStatus:(int)status {
    if (status == 1) {
        
    } else if (status == 0) {
        [self presentControllerWithName:kCourtesyWatchInterfaceNotLogin context:nil];
    }
}

- (void)sessionRequestFailed:(CourtesyPhoneSessionManager *)manager
                   withError:(NSError *)error {
    
}

- (void)session:(CourtesyPhoneSessionManager *)manager didReceiveNewMessage:(NSString *)message {
    
}

@end



