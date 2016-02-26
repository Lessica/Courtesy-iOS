//
//  CourtesyAccountModel.h
//  Courtesy
//
//  Created by Zheng on 2/23/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "JSONModel.h"
#import "CourtesyAccountProfileModel.h"

@class CourtesyAccountModel;

@protocol CourtesyFetchAccountInfoDelegate <NSObject>

@optional
- (void)fetchAccountInfoSucceed:(CourtesyAccountModel *)sender;
@optional
- (void)fetchAccountInfoFailed:(CourtesyAccountModel *)sender
                  errorMessage:(NSString *)message;

@end

@interface CourtesyAccountModel : JSONModel

@property (nonatomic, assign) NSUInteger user_id;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, assign) NSUInteger registered_at;
@property (nonatomic, assign) NSUInteger last_login_at;
@property (nonatomic, assign) NSUInteger card_count;
@property (nonatomic, assign) BOOL has_profile;
@property (nonatomic, strong) CourtesyAccountProfileModel<Optional> *profile;
@property (nonatomic, weak) id<Ignore, CourtesyFetchAccountInfoDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate;
- (BOOL)isFetching;
- (BOOL)fetched;
- (void)fetchAccountInfo;

@end
