//
//  CourtesyCardLocationModel.h
//  Courtesy
//
//  Created by Zheng on 5/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

@interface CourtesyCardLocationModel : JSONModel
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;

- (BOOL)hasLocation;
- (void)clearLocation;

@end
