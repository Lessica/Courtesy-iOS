//
//  CourtesyCardLocationTableViewController.m
//  Courtesy
//
//  Created by Zheng on 5/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardLocationTableViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>

#define kCourtesyCardLocationPickerCellReuseIdentifier @"kCourtesyCardLocationPickerCellReuseIdentifier"

@interface CourtesyCardLocationTableViewController () <CLLocationManagerDelegate, AMapSearchDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *pois;
@property (nonatomic, strong) AMapSearchAPI *search;

@end

@implementation CourtesyCardLocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加位置";
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = closeItem;
    
    self.tableView.allowsSelection = YES;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCourtesyCardLocationPickerCellReuseIdentifier];
    
    [self initLocationManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pois count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCourtesyCardLocationPickerCellReuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCourtesyCardLocationPickerCellReuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    NSUInteger index = indexPath.row;
    NSDictionary *dict = [_pois objectAtIndex:index];
    cell.textLabel.text = dict[@"SubLocality"];
    
    return cell;
}

#pragma mark - 地理位置

- (NSMutableArray <NSDictionary *> *)pois {
    if (!_pois) {
        _pois = [NSMutableArray new];
    }
    return _pois;
}

- (void)initLocationManager {
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
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

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
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

- (AMapSearchAPI *)search {
    if (!_search) {
        AMapSearchAPI *search = [[AMapSearchAPI alloc] init];
        search.delegate = self;
    }
    return _search;
}

- (void)reverseGeocoder:(CLLocation *)currentLocation {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    request.keywords                    = @"";
    request.sortrule                    = 0;
    request.requireExtension            = YES;
    request.radius                      = 1000;
    request.page                        = 0;
    request.offset                      = 20;
    request.types                       = @"050000|060000|070000|080000|090000|100000|110000|120000|130000|140000|150000|160000|170000";

    request.requireExtension = YES;
    [self.search AMapPOIAroundSearch:request];
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    if (response.pois.count == 0) {
        return;
    }
    
    for (AMapPOI *p in response.pois) {
        [self.pois addObject:@{@"name": p.description}];
    }
}

@end
