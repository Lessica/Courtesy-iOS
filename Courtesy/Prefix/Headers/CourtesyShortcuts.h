//
//  CourtesyShortcuts.h
//  Courtesy
//
//  Created by Zheng on 3/9/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#ifndef CourtesyShortcuts_h
#define CourtesyShortcuts_h

#define tryValue(property, value) (property = property ? property : value)
#define sharedSettings [GlobalSettings sharedInstance]
#define kLogin [sharedSettings hasLogin]
#define kAccount [sharedSettings currentAccount]
#define kProfile [kAccount profile]

#define SetCourtesyAleryViewStyle(alertView, parentView) \
    alertView.coverColor = [UIColor colorWithWhite:1.f alpha:0.9]; \
    alertView.layerShadowColor = [UIColor colorWithWhite:0.f alpha:0.3]; \
    alertView.layerShadowRadius = 4.f; \
    alertView.layerCornerRadius = 0.f; \
    alertView.layerBorderWidth = 2.f; \
    alertView.layerBorderColor = \
    alertView.buttonsTitleColor = \
    alertView.cancelButtonTitleColor = \
    alertView.buttonsBackgroundColorHighlighted = \
    alertView.activityIndicatorViewColor = \
    alertView.progressViewProgressTintColor = \
    alertView.cancelButtonBackgroundColorHighlighted = [UIColor magicColor]; \
    alertView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.7]; \
    alertView.buttonsHeight = 44.f; \
    alertView.titleFont = [UIFont boldSystemFontOfSize:18.f]; \
    alertView.titleTextColor = [UIColor blackColor]; \
    alertView.messageTextColor = [UIColor blackColor]; \
    alertView.width = MIN(parentView.bounds.size.width, parentView.bounds.size.height); \
    alertView.offsetVertical = 0.f; \
    alertView.cancelButtonOffsetY = 0.f; \
    alertView.titleTextAlignment = NSTextAlignmentLeft; \
    alertView.messageTextAlignment = NSTextAlignmentLeft; \
    alertView.buttonsTextAlignment = NSTextAlignmentRight; \
    alertView.cancelButtonTextAlignment = NSTextAlignmentRight; \
    alertView.destructiveButtonTextAlignment = NSTextAlignmentRight;

#endif /* CourtesyShortcuts_h */
