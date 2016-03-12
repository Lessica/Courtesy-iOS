//
//  CourtesyCardPreviewGenerator.h
//  Courtesy
//
//  Created by Zheng on 3/11/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CourtesyCardPreviewGenerator;

@protocol CourtesyCardPreviewGeneratorDelegate <NSObject>

@optional
- (void)generatorDidFinishWorking:(CourtesyCardPreviewGenerator *)generator result:(UIImage *)result;

@end

@interface CourtesyCardPreviewGenerator : NSObject
@property (nonatomic, strong) UIImage *headImage;
@property (nonatomic, strong) UIImage *bodyImage;
@property (nonatomic, strong) UIImage *footerImage;
@property (nonatomic, strong) UIImage *contentImage;
@property (nonatomic, weak) id<CourtesyCardPreviewGeneratorDelegate> delegate;

- (void)generate;

@end
