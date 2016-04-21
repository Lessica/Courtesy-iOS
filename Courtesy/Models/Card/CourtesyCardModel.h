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
- (void)cardDidFinishSaving:(CourtesyCardModel *)card isNewRecord:(BOOL)newRecord willPublish:(BOOL)willPublish;
- (void)cardDidFailedSaving:(CourtesyCardModel *)card;

@end

@interface CourtesyCardModel : JSONModel
@property (nonatomic, copy) NSString<Optional> *qr_id;
@property (nonatomic, assign) BOOL is_editable;
@property (nonatomic, assign) BOOL is_public;
@property (nonatomic, assign) NSUInteger view_count;
@property (nonatomic, assign) NSUInteger created_at;
@property (nonatomic, assign) NSUInteger modified_at;
@property (nonatomic, assign) NSUInteger first_read_at;
@property (nonatomic, assign) NSUInteger visible_at;

@property (nonatomic, copy)   NSString *token;
@property (nonatomic, assign) NSUInteger edited_count;
@property (nonatomic, assign) NSUInteger stars;
@property (nonatomic, strong) CourtesyAccountModel<Ignore> *author;
@property (nonatomic, strong) CourtesyAccountModel<Ignore> *read_by;
@property (nonatomic, strong) CourtesyCardDataModel *local_template;
@property (nonatomic, assign) BOOL newcard;
@property (nonatomic, weak)   id<CourtesyCardDelegate> delegate;

- (instancetype)initWithCardToken:(NSString *)token;
- (NSString *)saveToLocalDatabaseWithPublishFlag:(BOOL)willPublish;
- (void)deleteInLocalDatabase;

@end
