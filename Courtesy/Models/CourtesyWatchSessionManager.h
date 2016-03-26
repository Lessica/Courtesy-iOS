//
//  CourtesyWatchSessionManager.h
//  Courtesy
//
//  Created by Zheng on 3/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#ifdef WATCH_SUPPORT

#import "CourtesyWatchQueryKeys.h"
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface CourtesyWatchSessionManager : NSObject <WCSessionDelegate>

- (void)startSession;
- (void)notifyLoginStatus;

@end

#endif