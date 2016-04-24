//
//  CourtesyLoginRegisterModel.h
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCommonRequestModel.h"

typedef enum : NSUInteger {
    CourtesyOpenApiTypeNone     = 0,
    CourtesyOpenApiTypeQQ       = 1,
    CourtesyOpenApiTypeWeibo    = 2,
    CourtesyOpenApiTypeWeixin   = 3
} CourtesyOpenApiType;

// 构建请求包的虚拟类声明
@interface CourtesyLoginRegisterAccountRequestModel : JSONModel
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *pwd;
@end

@interface CourtesyLoginRegisterRequestModel : CourtesyCommonRequestModel
@property (strong, nonatomic) CourtesyLoginRegisterAccountRequestModel *account;
@end

// 类前置声明
@class CourtesyLoginRegisterModel;

// 声明登录注册委托协议
@protocol CourtesyLoginRegisterDelegate <NSObject>

@optional
- (void)loginRegisterSucceed:(CourtesyLoginRegisterModel *)sender
                     isLogin:(BOOL)login;
@optional
- (void)loginRegisterFailed:(CourtesyLoginRegisterModel *)sender
               errorMessage:(NSString *)message
                    isLogin:(BOOL)login;

@end

// 声明登录注册类
@interface CourtesyLoginRegisterModel : NSObject

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password_enc;
@property (nonatomic, assign) CourtesyOpenApiType openAPI;
@property (nonatomic, weak) id <CourtesyLoginRegisterDelegate> delegate;

- (instancetype)initWithAccount:(NSString *)email
                       password:(NSString *)password
                       delegate:(id)delegate;
- (void)sendRequestLogin;
- (void)sendRequestRegister;

@end
