//
//  CourtesyCardLocationTableViewController.m
//  Courtesy
//
//  Created by Zheng on 5/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "MJRefresh.h"
#import "CourtesyCardLocationTableViewController.h"
#import "CourtesyCardLocationTableViewCell.h"

#define kCourtesyLocationNotShow @"不显示位置"

#define kCourtesyCardLocationPickerCellReuseIdentifier @"kCourtesyCardLocationPickerCellReuseIdentifier"

@interface CourtesyCardLocationTableViewController ()
<
CLLocationManagerDelegate,
AMapSearchDelegate,
UITableViewDelegate,
UITableViewDataSource,
AMapLocationManagerDelegate
>

@property (nonatomic, strong) NSMutableArray *addressArray;
@property (nonatomic, strong) UITableView    *mTableView;
@property (nonatomic, assign) BOOL           needClear;
@property (nonatomic, assign) NSInteger      pageIndex;
@property (nonatomic, assign) NSInteger      pageCount;

@property (nonatomic, strong) AMapSearchAPI  *search;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, copy)   AMapLocatingCompletionBlock geoCompletionBlock;

@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;

@end

@implementation CourtesyCardLocationTableViewController

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"定位中……";
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = closeItem;
    
    [self resetAddressArray];
    [self initGeoCompleteBlock];
    
    if (self.oldPoi) {
        AMapPOI *poi                = self.oldPoi;
        self.latitude = poi.location.latitude;
        self.longitude = poi.location.longitude;
    }
    
    [self.view addSubview:self.mTableView];
    [self.mTableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetAddressArray {
    [self.addressArray removeAllObjects];
    self.needClear = NO;
    AMapPOI *first  = [[AMapPOI alloc] init];
    first.name      = kCourtesyLocationNotShow;
    [self.addressArray addObject:first];
}

#pragma mark - getData
- (void)headRefreshing {
    self.pageIndex = 0;
    self.pageCount = 20;
    self.needClear = YES;
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:self.geoCompletionBlock];
}

- (void)footRefreshing {
    if (self.latitude == 0 || self.longitude == 0) {
        [self.mTableView.mj_header endRefreshing];
        return;
    }
    self.pageIndex += 1;
    [self sendRequest];
}

- (void)sendRequest {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location                    = [AMapGeoPoint locationWithLatitude:self.latitude longitude:self.longitude];
    request.keywords                    = @"";
    request.sortrule                    = 0;
    request.requireExtension            = YES;
    request.radius                      = 1000;
    request.page                        = self.pageIndex;
    request.offset                      = self.pageCount;
    request.types                       = @"050000|060000|070000|080000|090000|100000|110000|120000|130000|140000|150000|160000|170000";
    
    [self.search AMapPOIAroundSearch:request];
}

#pragma mark - AMapSearchDelegate
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    if (response.pois.count == 0){
        return;
    }
    
    if (self.needClear) {
        [self resetAddressArray];
    }
    if (self.addressArray.count == 1) {
        AMapPOI *poi = [[AMapPOI alloc] init];
        poi.city     = ((AMapPOI *)response.pois.firstObject).city;
        [self.addressArray addObject:poi];
    }
    
    [self.addressArray addObjectsFromArray:response.pois];
    
    [self.mTableView reloadData];
    
    self.mTableView.mj_footer.hidden = response.pois.count != self.pageCount;
    
    [self.mTableView.mj_header endRefreshing];
    [self.mTableView.mj_footer endRefreshing];
    
    self.title = @"添加位置";
}

#pragma mark TableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"CourtesyCardLocationTableViewCell";
    CourtesyCardLocationTableViewCell *cell    = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    AMapPOI *info               = self.addressArray[indexPath.row];
    cell.textLabel.text         = info.name.length > 0 ? info.name : info.city;
    cell.detailTextLabel.text   = info.address;
    
    cell.accessoryType  = UITableViewCellAccessoryNone;
    
    if (!self.oldPoi && indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (self.oldPoi && [self.oldPoi.name isEqualToString:info.name]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addressArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AMapPOI *info = self.addressArray[indexPath.row];
    for (UITableViewCell *cell in [tableView visibleCells]) {
        cell.accessoryType  = UITableViewCellAccessoryNone;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if (self.successBlock) {
        self.successBlock([info.name isEqualToString:kCourtesyLocationNotShow] ? nil : info);
    }
}

#pragma mark - get set
- (UITableView *)mTableView {
    if (!_mTableView) {
        _mTableView = ({
            __weak __typeof(self) weakSelf = self;
            
            UITableView *mTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
            mTableView.allowsSelection = YES;
            mTableView.showsHorizontalScrollIndicator = NO;
            mTableView.showsVerticalScrollIndicator   = NO;
            mTableView.rowHeight                      = 44;
            mTableView.dataSource                     = self;
            mTableView.delegate                       = self;
            mTableView.tableFooterView                = [UIView new];
            [mTableView registerClass:[CourtesyCardLocationTableViewCell class] forCellReuseIdentifier:@"CourtesyCardLocationTableViewCell"];
            
            mTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf headRefreshing];
            }];
            mTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf footRefreshing];
            }];
            mTableView;
        });
    }
    return _mTableView;
}

- (NSMutableArray *)addressArray {
    if (!_addressArray) {
        _addressArray = ({
            [[NSMutableArray alloc] init];
        });
    }
    return _addressArray;
}

- (AMapSearchAPI *)search {
    if (!_search) {
        _search = ({
            [AMapSearchServices sharedServices].apiKey = AUTONAVI_APP_KEY;
            AMapSearchAPI *api = [[AMapSearchAPI alloc] init];
            api.delegate       = self;
            api;
        });
    }
    return _search;
}

- (void)setSuccessBlock:(SelectLocationSuccessBlock)successBlock {
    _successBlock = successBlock;
}

- (void)initGeoCompleteBlock
{
    __weak typeof(self) weakSelf = self;
    self.geoCompletionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        __strong typeof(self) strongSelf = weakSelf;
        if (error)
        {
            strongSelf.title = @"定位失败";
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        if (location)
        {
            strongSelf.latitude = location.coordinate.latitude;
            strongSelf.longitude = location.coordinate.longitude;
            [strongSelf footRefreshing];
        }
    };
}

- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        [MAMapServices sharedServices].apiKey = AUTONAVI_APP_KEY;
        [AMapLocationServices sharedServices].apiKey = AUTONAVI_APP_KEY;
        AMapLocationManager *locationManager = [[AMapLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager setPausesLocationUpdatesAutomatically:YES];
        [locationManager setAllowsBackgroundLocationUpdates:YES];
        [locationManager setLocationTimeout:3.0];
        [locationManager setReGeocodeTimeout:3.0];
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (void)dealloc {
    CYLog(@"");
}

@end
