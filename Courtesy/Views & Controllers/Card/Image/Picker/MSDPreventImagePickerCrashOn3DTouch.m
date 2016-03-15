//
//  MSDPreventImagePickerCrashOn3DTouch.m
//  Courtesy
//
//  Created by Zheng on 3/14/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "MSDPreventImagePickerCrashOn3DTouch.h"
#import <PhotosUI/PhotosUI.h>
#import <objc/message.h>
#import <objc/runtime.h>

static void ReplaceMethod(Class cls, SEL original, SEL replacement, id block) {
    IMP implementation = imp_implementationWithBlock(block);
    Method originalMethod = class_getInstanceMethod(cls, original);
    class_addMethod(cls, replacement, implementation, method_getTypeEncoding(originalMethod));
    Method replacementMethod = class_getInstanceMethod(cls, replacement);
    if (class_addMethod(cls, original, method_getImplementation(replacementMethod), method_getTypeEncoding(replacementMethod))) {
        class_replaceMethod(cls, replacement, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}

static void FixImagePicker3DTouchCrash(void) {
    // Load PhotosUI and bail if 3D Touch is unavailable. (UIViewControllerPreviewing may be redundant, as PUPhotosGridViewController only seems to exist on iOS 9, but I'm being cautious.)
    NSBundle *PhotosUI = [NSBundle bundleWithPath:@"/System/Library/Frameworks/PhotosUI.framework"];
    Class klass = [PhotosUI classNamed:[NSString stringWithFormat:@"%@%@%@", @"PU", @"P", @"hotosGridViewController"]];
    if (!(klass && objc_getProtocol("UIViewControllerPreviewing"))) {
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    SEL selector = @selector(msd_previewingContext:viewControllerForLocation:);
    ReplaceMethod(klass, @selector(previewingContext:viewControllerForLocation:), selector, ^UIViewController *(id self, id<UIViewControllerPreviewing> previewingContext, CGPoint location) {
        
        // Default implementation throws on iOS 9.0 and 9.1.
        @try {
            return ((UIViewController *(*)(id, SEL, id, CGPoint))objc_msgSend)(self, selector, previewingContext, location);
        } @catch (NSException *e) {
            return nil;
        }
    });
    
#pragma clang diagnostic pop
}

void MSDPreventImagePickerCrashOn3DTouch(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FixImagePicker3DTouchCrash();
    });
}
