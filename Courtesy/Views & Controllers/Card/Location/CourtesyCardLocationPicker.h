//
//  CourtesyCardLocationPicker.h
//  Courtesy
//
//  Created by Zheng on 5/16/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CourtesyCardLocationPicker;

@protocol CourtesyCardLocationPicker <NSObject>
- (void)locationPickerDidSucceed:(CourtesyCardLocationPicker *)picker;
- (void)locationPickerDidCanceled:(CourtesyCardLocationPicker *)picker;

@end

@interface CourtesyCardLocationPicker : UIViewController
@property (nonatomic, weak) id<CourtesyCardLocationPicker> masterViewController;

- (instancetype)initWithMasterController:(id)controller;
@end
