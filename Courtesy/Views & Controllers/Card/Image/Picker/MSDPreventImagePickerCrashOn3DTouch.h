//
//  MSDPreventImagePickerCrashOn3DTouch.h
//  Courtesy
//
//  Created by Zheng on 3/14/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#ifndef MSDPreventImagePickerCrashOn3DTouch_h
#define MSDPreventImagePickerCrashOn3DTouch_h

/**
 Fixes a crash on (at least) iOS 9.0 and iOS 9.1 in UIImagePickerController when 3D Touching a photo.
 
 This function is idempotent. You can call it multiple times with no ill effect.
 */
extern void MSDPreventImagePickerCrashOn3DTouch(void);

#endif /* MSDPreventImagePickerCrashOn3DTouch_h */
