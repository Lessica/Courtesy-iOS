//
//  CourtesyCardResourceModel.h
//  Courtesy
//
//  Created by Zheng on 4/21/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

@interface CourtesyCardResourceModel : JSONModel
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *sha256;
@property (nonatomic, copy) NSString *mime;
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, assign) NSUInteger size;

@end
