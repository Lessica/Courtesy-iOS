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
@property (nonatomic, strong) NSString *currentLocationString;
@property (weak, nonatomic) IBOutlet UITextField *cityField;

@end

@implementation CourtesyProfileCityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak UITextField *field = _cityField;
    __weak typeof(self) weakSelf = self;
    [_cityPickerView setValueChangedCallback:^(NSString *province, NSString *city, NSString *area) {
        field.text = [[weakSelf class] generateCityStringWithState:province andCity:city andSubLocality:area];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _cityField.text = [[self class] generateCityStringWithState:kProfile.province andCity:kProfile.city andSubLocality:kProfile.area];
}

- (IBAction)saveButtonCliced:(id)sender {
    [self.view endEditing:YES];
    NSArray *arr = [_cityField.text componentsSeparatedByString:@" - "];
    if ([arr count] == 3) {
        [kProfile setProvince:arr[0]];
        [kProfile setCity:arr[1]];
        [kProfile setArea:arr[2]];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        if ([CLLocationManager locationServicesEnabled]) {
            if (self.currentLocationString) {
                self.cityField.text = self.currentLocationString;
            }
            else
            {
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
            SetCourtesyAleryViewStyle(alertView, self.view)
            [alertView showAnimated:YES completionHandler:nil];
        }
    }
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers]; // 不需要精确
    }
    return _locationManager;
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
                self.currentLocationString = [[self class] generateCityStringWithState:dict [@"State"] andCity:dict [@"City"] andSubLocality:dict [@"SubLocality"]];
                self.cityField.text = self.currentLocationString;
            }
        }
    }];
}

#pragma mark - 生成城市字符串

+ (NSString *)generateCityStringWithState:(NSString *)state
                            andCity:(NSString *)city
                     andSubLocality:(NSString *)subLocality
{
    NSString *finalString = @"";
    if (state) {
        finalString = [finalString stringByAppendingString:state];
    }
    if (city) {
        if (state) {
            finalString = [finalString stringByAppendingString:@" - "];
        }
        finalString = [finalString stringByAppendingString:city];
    }
    if (subLocality) {
        if (city) {
            finalString = [finalString stringByAppendingString:@" - "];
        }
        finalString = [finalString stringByAppendingString:subLocality];
    }
    return finalString;
}

@end
