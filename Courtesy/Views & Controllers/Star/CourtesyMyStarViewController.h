//
//  CourtesyMainTableViewController.h
//  Courtesy
//
//  Created by Zheng on 2/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "ZLSwipeableView.h"

@interface CourtesyMyStarViewController : UIViewController <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>
@property (nonatomic, strong) ZLSwipeableView *swipeableView;

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView;
@end
