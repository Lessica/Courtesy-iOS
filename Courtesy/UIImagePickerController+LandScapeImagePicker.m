//
//  UIImagePickerController+LandScapeImagePicker.m
//  Courtesy
//
//  Created by Zheng on 3/3/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "UIImagePickerController+LandScapeImagePicker.h"

@implementation UIImagePickerController (LandScapeImagePicker)

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
