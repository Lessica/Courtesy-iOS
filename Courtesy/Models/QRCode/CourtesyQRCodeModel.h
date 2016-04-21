//
//  CourtesyQRCodeModel.h
//  Courtesy
//
//  Created by Zheng on 2/28/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonRequestModel.h"

@class CourtesyQRCodeModel;

@protocol CourtesyQRCodeQueryDelegate <NSObject>

@optional
- (void)queryQRCodeSucceed:(CourtesyQRCodeModel *)qrcode;
@optional
- (void)queryQRCodeFailed:(CourtesyQRCodeModel *)qrcode
             errorMessage:(NSString *)message;

@end

@interface CourtesyQRCodeModel : JSONModel
@property (nonatomic, copy) NSString *unique_id;
@property (nonatomic, assign) BOOL is_recorded;
@property (nonatomic, assign) NSUInteger scan_count;
@property (nonatomic, assign) NSNumber<Optional> *created_at;
@property (nonatomic, assign) NSUInteger channel;
@property (nonatomic, assign) NSNumber<Optional> *recorded_at;
@property (nonatomic, copy) NSString<Optional> *card_token;
@property (nonatomic, weak) id<Ignore, CourtesyQRCodeQueryDelegate> delegate;

- (instancetype)initWithDelegate:(id)delegate uid:(NSString *)unique_id;
- (void)sendRequestQuery;

@end

@interface CourtesyQRCodeQueryModel : CourtesyCommonRequestModel
@property (nonatomic, copy) NSString *qr_id;

@end
