//
//  CourtesyCardLocationTableViewController.h
//  Courtesy
//
//  Created by Zheng on 5/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

typedef void(^SelectLocationSuccessBlock)(AMapPOI *poi);

@interface CourtesyCardLocationTableViewController : UIViewController

@property (nonatomic, strong)   AMapPOI                      *oldPoi;
@property (nonatomic, copy)     SelectLocationSuccessBlock   successBlock;

@end
