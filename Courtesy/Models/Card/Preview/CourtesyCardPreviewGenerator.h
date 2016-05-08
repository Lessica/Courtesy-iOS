//
//  CourtesyCardPreviewGenerator.h
//  Courtesy
//
//  Created by Zheng on 3/11/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPreviewStyleManager.h"

@class CourtesyCardPreviewGenerator;

@protocol CourtesyCardPreviewGeneratorDelegate <NSObject>

@optional
- (void)generatorDidFinishWorking:(CourtesyCardPreviewGenerator *)generator result:(UIImage *)result;

@end

@interface CourtesyCardPreviewGenerator : NSObject
@property (nonatomic, strong) CourtesyCardPreviewStyleModel *previewStyle;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, weak) id<CourtesyCardPreviewGeneratorDelegate> delegate;

- (void)generate;

@end
