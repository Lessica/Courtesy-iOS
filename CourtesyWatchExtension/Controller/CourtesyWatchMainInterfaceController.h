//
//  CourtesyWatchMainInterfaceController.h
//  watch Extension
//
//  Created by Zheng on 3/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "CourtesyPhoneSessionManager.h"

#define kCourtesyWatchInterfaceNotLogin @"kCourtesyWatchInterfaceNotLogin"
#define kCourtesyWatchInterfaceMain @"kCourtesyWatchInterfaceMain"
#define kCourtesyWatchInterfaceGallery @"kCourtesyWatchInterfaceGallery"
#define kCourtesyWatchInterfaceMy @"kCourtesyWatchInterfaceMy"
#define kCourtesyWatchInterfaceStar @"kCourtesyWatchInterfaceStar"

#define kCourtesyNotLoginArray @[kCourtesyWatchInterfaceNotLogin]
#define kCourtesyMainArray @[kCourtesyWatchInterfaceMain, kCourtesyWatchInterfaceGallery, kCourtesyWatchInterfaceMy, kCourtesyWatchInterfaceStar]

@interface CourtesyWatchMainInterfaceController : WKInterfaceController <CourtesyPhoneSessionDelegate>
@property (nonatomic, strong) CourtesyPhoneSessionManager *phoneSessionManager;

@end
