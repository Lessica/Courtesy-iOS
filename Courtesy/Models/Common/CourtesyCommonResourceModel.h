//
//  CourtesyCommonResourceModel.h
//  Courtesy
//
//  Created by Zheng on 4/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

@interface CourtesyCommonResourceModel : JSONModel
@property (nonatomic, copy) NSString *rid;
@property (nonatomic, copy) NSString *sha256;
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, strong) NSURL<Ignore> *remoteUrl;

- (NSString *)type;
@end
