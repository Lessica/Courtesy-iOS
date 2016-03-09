//
//  CourtesyJotViewController.h
//  Courtesy
//
//  Created by Zheng on 3/4/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <jot/jot.h>
#import <UIKit/UIKit.h>

@interface CourtesyJotViewController : JotViewController
@property (nonatomic, strong) UIColor *buttonBackgroundColor;
@property (nonatomic, strong) UIColor *buttonTintColor;
@property (nonatomic, strong) NSNumber *standardAlpha;
@property (nonatomic, assign) BOOL controlEnabled;

@end
