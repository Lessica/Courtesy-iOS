//
//  UIImagePickerController+LandScapeImagePicker.h
//  Courtesy
//
//  Created by Zheng on 3/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePickerController (LandScapeImagePicker)

- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;

@end