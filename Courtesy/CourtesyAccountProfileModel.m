//
//  CourtesyAccountProfileModel.m
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "JSONHTTPClient.h"
#import "AFNetworking.h"
#import "CourtesyAccountProfileModel.h"

@implementation CourtesyEditProfileRequestModel

@end

@implementation CourtesyAccountProfileModel {
    CourtesyEditProfileRequestModel *fetchDict;
    BOOL isEditing;
}

- (instancetype)init {
    if (self = [super init]) {
        isEditing = NO;
    }
    return self;
}

- (instancetype)initWithDelegate:(id)delegate {
    if ([self init]) {
        _delegate = delegate;
    }
    return self;
}

- (BOOL)isEditing {
    return isEditing;
}

#pragma mark - 构造请求

- (void)makeRequest {
    fetchDict = [CourtesyEditProfileRequestModel new];
    fetchDict.action = @"user_edit_profile";
    fetchDict.profile = kProfile;
    CYLog(@"%@", [fetchDict toJSONString]);
}

#pragma mark - 发送委托方法

- (void)callbackDelegateWithErrorMessage:(NSString *)message {
    if (!_delegate || ![_delegate respondsToSelector:@selector(editProfileFailed:errorMessage:)]) {
        return;
    }
    [_delegate editProfileFailed:self errorMessage:message];
}

- (void)callbackDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(editProfileSucceed:)]) {
        return;
    }
    [_delegate editProfileSucceed:self];
}

- (void)callbackAvatarDelegateWithErrorMessage:(NSString *)message {
    if (!_delegate || ![_delegate respondsToSelector:@selector(uploadAvatarFailed:errorMessage:)]) {
        return;
    }
    [_delegate uploadAvatarFailed:self errorMessage:message];
}

- (void)callbackAvatarDelegateSucceed {
    if (!_delegate || ![_delegate respondsToSelector:@selector(uploadAvatarSucceed:)]) {
        return;
    }
    [_delegate uploadAvatarSucceed:self];
}

#pragma mark - 发送请求

- (void)editProfile {
    [self makeRequest];
    JSONObjectBlock handler = ^(id json, JSONModelError *err) {
        CYLog(@"%@", json);
        @try {
            if (err) {
                @throw NSException(kCourtesyInvalidHttpResponse, [err localizedDescription]);
            }
            if (!json ||
                ![json isKindOfClass:[NSDictionary class]]) {
                @throw NSException(kCourtesyInvalidHttpResponse, @"服务器错误");
            }
            NSDictionary *dict = (NSDictionary *)json;
            if (![dict hasKey:@"error"]) {
                @throw NSException(kCourtesyUnexceptedObject, @"服务器错误");
            }
            NSInteger errorCode = [[dict objectForKey:@"error"] integerValue];
            if (errorCode == 403) {
                @throw NSException(kCourtesyForbidden, @"请重新登录");
            } else if (errorCode == 0) {
                [self callbackDelegateSucceed];
                return;
            }
            @throw NSException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
        }
        @catch (NSException *exception) {
            if ([exception.name isEqualToString:kCourtesyForbidden]) {
                [[GlobalSettings sharedInstance] setHasLogin:NO];
            }
            [self callbackDelegateWithErrorMessage:exception.reason];
            return;
        }
        @finally {
            isEditing = NO;
        }
    };
    isEditing = YES;
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:[fetchDict toJSONString]
                                   completion:handler];
}

#pragma mark - 上传头像

- (void)uploadAvatar:(UIImage *)avatar {
    NSError *error = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:API_UPLOAD_AVATAR parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImagePNGRepresentation(avatar) name:@"avatar" fileName:@"fake.png" mimeType:@"image/png"];
    } error:&error];
    if (error) {
        [self callbackDelegateWithErrorMessage:@"图片格式转换失败"];
    }
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          [JDStatusBarNotification showProgress:uploadProgress.fractionCompleted];
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          [self callbackAvatarDelegateWithErrorMessage:[error localizedDescription]];
                          CYLog(@"Error: %@", error);
                      } else {
                          CYLog(@"Response: %@\nObject: %@", response, responseObject);
                          if (!responseObject ||
                              ![responseObject isKindOfClass:[NSDictionary class]] ||
                              ![responseObject hasKey:@"error"] ||
                              ![responseObject hasKey:@"id"]) {
                              [self callbackAvatarDelegateWithErrorMessage:@"服务器错误"];
                          }
                          NSInteger errorCode = [[responseObject objectForKey:@"error"] integerValue];
                          if (errorCode == 0) {
                              NSString *recv = [responseObject objectForKey:@"id"];
                              self.avatar = [recv stringByAppendingString:@"_300.png"];
                              [self callbackAvatarDelegateSucceed];
                          } else if (errorCode == 422) {
                              [self callbackAvatarDelegateWithErrorMessage:[NSString stringWithFormat:@"图片尺寸不正确"]];
                          } else {
                              [self callbackAvatarDelegateWithErrorMessage:[NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]];
                          }
                      }
                  }];
    
    [uploadTask resume];
}

#pragma mark - 组合远程头像地址

- (NSURL *)avatar_url {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_AVATAR, self.avatar]];
}

@end
