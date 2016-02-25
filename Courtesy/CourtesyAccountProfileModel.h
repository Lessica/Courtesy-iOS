//
//  CourtesyAccountProfileModel.h
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "JSONModel.h"

@interface CourtesyAccountProfileModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *nick;
@property (nonatomic, copy) NSString<Optional> *avatar;
@property (nonatomic, copy) NSString<Optional> *mobile;
@property (nonatomic, copy) NSString<Optional> *birthday;
@property (nonatomic, copy) NSString<Optional> *province;
@property (nonatomic, copy) NSString<Optional> *city;
@property (nonatomic, copy) NSString<Optional> *constellation;
@property (nonatomic, copy) NSString<Optional> *hemotype;
// ... any profile info

@end
