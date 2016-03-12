//
//  CourtesyProfileCityTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/26/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyProfileCityTableViewController.h"
#import "CNCityPickerView.h"
#import <CoreLocation/CoreLocation.h>

@interface CourtesyProfileCityTableViewController () <CLLocationManagerDelegate> {
    IBOutlet CNCityPickerView *_cityPickerView;
}
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (weak, nonatomic) IBOutlet UITextField *cityField;

@end

@implementation CourtesyProfileCityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak UITextField *field = _cityField;
    [_cityPickerView setValueChangedCallback:^(NSString *province, NSString *city, NSString *area) {
        field.text = [NSString stringWithFormat:@"%@ - %@ - %@", province, city, area];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _cityField.text = [NSString stringWithFormat:@"%@ - %@ - %@", kProfile.province, kProfile.city, kProfile.area];
}

- (IBAction)saveButtonCliced:(id)sender {
    [self.view endEditing:YES];
    NSArray *arr = [_cityField.text componentsSeparatedByString:@" - "];
    if ([arr count] == 3) {
        [kProfile setProvince:[arr objectAtIndex:0]];
        [kProfile setCity:[arr objectAtIndex:1]];
        [kProfile setArea:[arr objectAtIndex:2]];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        if ([CLLocationManager locationServicesEnabled]) {
            if (!_locationManager) {
                self.locationManager = [[CLLocationManager alloc] init];
                if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [self.locationManager requestWhenInUseAuthorization];
                }
                [self.locationManager setDelegate:self];
                [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
                [self.locationManager setDistanceFilter:100];
                [self.locationManager startUpdatingLocation];
                [self.locationManager startUpdatingHeading];
            }
        } else {
            LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"提示"
                                                                message:@"请在「设置 - 隐私 - 定位服务」中，找到应用程序「礼记」，并允许其访问您的位置信息。"
                                                                  style:LGAlertViewStyleAlert
                                                           buttonTitles:nil
                                                      cancelButtonTitle:@"好"
                                                 destructiveButtonTitle:nil];
            [alertView showAnimated:YES completionHandler:nil];
        }
    }
}

#pragma mark - CLLocationManangerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    [self.locationManager stopUpdatingLocation];
    CLLocation* location = locations.lastObject;
    [self reverseGeocoder:location];
}

#pragma mark Geocoder

- (void)reverseGeocoder:(CLLocation *)currentLocation {
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || placemarks.count == 0) {
            CYLog(@"%@", error);
        } else {
            CLPlacemark* placemark = placemarks.firstObject;
            NSDictionary *dict = [placemark addressDictionary];
            if (dict && [dict hasKey:@"State"] && [dict hasKey:@"City"] && [dict hasKey:@"SubLocality"]) {
                _cityField.text = [NSString stringWithFormat:@"%@ - %@ - %@",
                                   [[placemark addressDictionary] objectForKey:@"State"],
                                   [[placemark addressDictionary] objectForKey:@"City"],
                                   [[placemark addressDictionary] objectForKey:@"SubLocality"]];
            }
        }
    }];
}

@end
