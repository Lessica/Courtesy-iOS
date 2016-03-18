//
//  CourtesyJotViewController.h
//  Courtesy
//
//  Created by Zheng on 3/4/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "jot.h"
#import "CourtesyCardComposeViewController.h"

@interface CourtesyJotViewController : JotViewController
@property (nonatomic, assign) BOOL controlEnabled;

- (instancetype)initWithMasterController:(CourtesyCardComposeViewController<JotViewControllerDelegate> *)controller;
- (void)reloadStyle;
@end
