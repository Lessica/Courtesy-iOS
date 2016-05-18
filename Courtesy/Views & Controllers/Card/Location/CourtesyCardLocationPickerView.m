//
//  CourtesyCardLocationPickerView.m
//  Courtesy
//
//  Created by Zheng on 5/17/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardLocationPickerView.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@implementation CourtesyCardLocationPickerView

//#pragma mark - 地理位置
//
//- (void)initGeoCompleteBlock
//{
//    __weak typeof(self) weakSelf = self;
//    self.geoCompletionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
//    {
//        __strong typeof(self) strongSelf = weakSelf;
//        strongSelf.circleLocationBtn.userInteractionEnabled = YES;
//        if (error)
//        {
//            [strongSelf.circleLocationBtn setTitle:@"定位失败" forState:UIControlStateNormal];
//            if (error.code == AMapLocationErrorLocateFailed)
//            {
//                return;
//            }
//        }
//        
//        if (location)
//        {
//            if (regeocode)
//            {
//                NSString *briefAddress = [NSString stringWithFormat:@"%@%@", regeocode.city, regeocode.POIName];
//                [strongSelf.circleLocationBtn setTitle:briefAddress forState:UIControlStateNormal];
//                strongSelf.cdata.geoLocation.address = briefAddress;
//                strongSelf.cdata.geoLocation.latitude = location.coordinate.latitude;
//                strongSelf.cdata.geoLocation.longitude = location.coordinate.longitude;
//                strongSelf.cardEdited = YES;
//            }
//        }
//    };
//}
//
//- (void)configLocationManager
//{
//    self.locationManager = [[AMapLocationManager alloc] init];
//    [self.locationManager setDelegate:self];
//    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
//    [self.locationManager setPausesLocationUpdatesAutomatically:YES];
//    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
//    [self.locationManager setLocationTimeout:LocationTimeout];
//    [self.locationManager setReGeocodeTimeout:ReGeocodeTimeout];
//}
//
//- (void)reGeocodeAction
//{
//    if ([self.cdata.geoLocation hasLocation]) {
//        [self.circleLocationBtn setTitle:@"添加位置" forState:UIControlStateNormal];
//        [self.cdata.geoLocation clearLocation];
//        self.cardEdited = YES;
//    } else {
//        self.circleLocationBtn.userInteractionEnabled = NO;
//        [self.circleLocationBtn setTitle:@"定位中……" forState:UIControlStateNormal];
//        [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.geoCompletionBlock];
//    }
//}

@end
