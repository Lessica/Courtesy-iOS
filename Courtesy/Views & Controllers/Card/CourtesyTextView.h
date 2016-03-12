//
//  CourtesyTextView.h
//  Courtesy
//
//  Created by Zheng on 3/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <YYKit/YYKit.h>
#import <objc/message.h>
#import <objc/runtime.h>

@interface CourtesyTextView : YYTextView
@property (nonatomic, assign) CGSize minContentSize;
@property (nonatomic, strong) YYTextContainerView *yyContainerView;

@end
