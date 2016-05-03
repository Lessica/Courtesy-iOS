//
//  CourtesyCardPreviewGenerator.h
//  Courtesy
//
//  Created by Zheng on 3/11/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPreviewStyleModel.h"

@class CourtesyCardPreviewGenerator;

@protocol CourtesyCardPreviewGeneratorDelegate <NSObject>

@optional
- (void)generatorDidFinishWorking:(CourtesyCardPreviewGenerator *)generator result:(UIImage *)result;

@end

@interface CourtesyCardPreviewGenerator : NSObject
@property (nonatomic, strong) CourtesyCardPreviewStyleModel *previewStyle;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) id<CourtesyCardPreviewGeneratorDelegate> delegate;

- (void)generate;

@end
