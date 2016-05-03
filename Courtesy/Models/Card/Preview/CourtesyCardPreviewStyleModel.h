//
//  CourtesyCardPreviewStyleModel.h
//  Courtesy
//
//  Created by Zheng on 3/14/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

typedef enum : NSUInteger {
    kCourtesyCardPreviewStyleDefault = 0
} CourtesyCardPreviewStyleType;

@interface CourtesyCardPreviewStyleModel : NSObject
@property (nonatomic, strong) UIImage *previewHeader;
@property (nonatomic, strong) UIImage *previewBody;
@property (nonatomic, strong) UIImage *previewFooter;
@property (nonatomic, strong) NSString *previewFooterText;
@property (nonatomic, assign) CGPoint previewFooterOrigin;
@property (nonatomic, strong) NSDictionary *previewFooterAttributes;

@end
