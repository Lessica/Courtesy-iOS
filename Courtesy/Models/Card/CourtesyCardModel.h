//
//  CourtesyCardModel.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAccountModel.h"
#import "CourtesyCardDataModel.h"

@class CourtesyCardModel;

@protocol CourtesyCardDelegate <NSObject>

- (void)cardDidFinishLoading:(CourtesyCardModel *)card;
- (void)cardDidFinishSaving:(CourtesyCardModel *)card newRecord:(BOOL)newRecord;
- (void)cardDidFailedSaving:(CourtesyCardModel *)card;

@end

@interface CourtesyCardModel : JSONModel
@property (nonatomic, assign) BOOL is_editable;
@property (nonatomic, assign) BOOL is_public;
@property (nonatomic, assign) NSUInteger view_count;
@property (nonatomic, assign) NSUInteger created_at;
@property (nonatomic, strong) NSDate<Ignore> *created_at_object;
@property (nonatomic, assign) NSUInteger modified_at;
@property (nonatomic, strong) NSDate<Ignore> *modified_at_object;
@property (nonatomic, assign) NSUInteger first_read_at;
@property (nonatomic, strong) NSDate<Ignore> *first_read_at_object;
@property (nonatomic, copy)   NSString *token;
@property (nonatomic, copy)   NSString<Ignore> *local_token;
@property (nonatomic, assign) NSUInteger edited_count;
@property (nonatomic, assign) NSUInteger stars;
@property (nonatomic, strong) CourtesyAccountModel<Ignore> *author;
@property (nonatomic, strong) CourtesyAccountModel<Ignore> *read_by;
@property (nonatomic, copy)   NSString *local_template;
@property (nonatomic, strong) CourtesyCardDataModel<Ignore> *card_data;
@property (nonatomic, assign) BOOL newcard;
@property (nonatomic, weak)   id<CourtesyCardDelegate> delegate;

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError * __autoreleasing *)err;
- (NSString *)saveToLocalDatabase;
- (void)deleteInLocalDatabase;

@end
