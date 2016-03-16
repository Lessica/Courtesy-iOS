//
//  CourtesyCardModel.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "JSONModel.h"
#import "CourtesyAccountModel.h"
#import "CourtesyCardDataModel.h"

@interface CourtesyCardModel : JSONModel
@property (nonatomic, assign) BOOL is_editable;
@property (nonatomic, assign) BOOL is_public;
@property (nonatomic, assign) NSUInteger view_count;
@property (nonatomic, assign) NSUInteger created_at;
@property (nonatomic, strong, nonnull) NSDate<Ignore> *created_at_object;
@property (nonatomic, assign) NSUInteger modified_at;
@property (nonatomic, strong, nonnull) NSDate<Ignore> *modified_at_object;
@property (nonatomic, assign) NSUInteger first_read_at;
@property (nonatomic, strong, nullable) NSDate<Ignore> *first_read_at_object;
@property (nonatomic, copy, nullable) NSString *token;
@property (nonatomic, assign) NSUInteger edited_count;
@property (nonatomic, assign) NSUInteger stars;
@property (nonatomic, strong, nonnull) CourtesyAccountModel *author;
@property (nonatomic, strong, nullable) CourtesyAccountModel *read_by;
@property (nonatomic, copy, nullable) NSString *local_template;
@property (nonatomic, strong, nullable) CourtesyCardDataModel<Ignore> *card_data;
@property (nonatomic, assign) BOOL newcard;

@end
