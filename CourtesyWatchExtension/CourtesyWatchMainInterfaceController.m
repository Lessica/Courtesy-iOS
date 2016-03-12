//
//  CourtesyWatchMainInterfaceController.m
//  watch Extension
//
//  Created by Zheng on 3/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "CourtesyWatchMainInterfaceController.h"


@interface CourtesyWatchMainInterfaceController()

@end


@implementation CourtesyWatchMainInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification {
    
}

// Thanks: http://jerryliu.org/ios%20programming/Apple%20Watch-Development-summary/
- (IBAction)warningButtonTapped:(id)sender {
    
}

@end



