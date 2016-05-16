//
//  CourtesyCardLocationPicker.m
//  Courtesy
//
//  Created by Zheng on 5/16/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardLocationPicker.h"

@implementation CourtesyCardLocationPicker

- (instancetype)initWithMasterController:(id)controller {
    if (self = [super init]) {
        _masterViewController = controller;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    
    
}

@end
