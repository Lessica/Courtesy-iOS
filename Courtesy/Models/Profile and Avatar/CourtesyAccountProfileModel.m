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
    BOOL isRequestingEditProfile;
    BOOL isRequestingUploadAvatar;
}

- (instancetype)initWithDelegate:(id)delegate {
    if (self = [super init]) {
        isRequestingEditProfile = NO;
        _delegate = delegate;
    }
    return self;
}

#pragma mark - 获取请求状态

- (BOOL)isRequestingEditProfile {
    return isRequestingEditProfile;
}

- (BOOL)isRequestingUploadAvatar {
    return isRequestingUploadAvatar;
}

#pragma mark - Send Message to CourtesyEditProfileDelegate

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

#pragma mark - Send Message to CourtesyUploadAvatarDelegate

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

#pragma mark - 构造请求

- (BOOL)makeRequest {
    fetchDict = [CourtesyEditProfileRequestModel new];
    fetchDict.action = @"user_edit_profile";
    fetchDict.profile = kProfile;
    CYLog(@"%@", [fetchDict toJSONString]);
    return YES;
}

#pragma mark - 发送请求

- (void)sendRequestEditProfile {
    if (isRequestingEditProfile || ![self makeRequest]) {
        return;
    }
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
                [sharedSettings setHasLogin:NO];
            }
            [self callbackDelegateWithErrorMessage:exception.reason];
            return;
        }
        @finally {
            isRequestingEditProfile = NO;
        }
    };
    isRequestingEditProfile = YES;
    [JSONHTTPClient postJSONFromURLWithString:API_URL
                                   bodyString:[fetchDict toJSONString]
                                   completion:handler];
}

#pragma mark - 上传头像

- (void)sendRequestUploadAvatar:(UIImage *)avatar {
    if (isRequestingUploadAvatar) {
        return;
    }
    NSError *error = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:API_UPLOAD_AVATAR parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImagePNGRepresentation(avatar) name:@"avatar" fileName:@"fake.png" mimeType:@"image/png"];
    } error:&error];
    if (error) {
        [self callbackDelegateWithErrorMessage:@"图片格式转换失败"];
    }
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    isRequestingUploadAvatar = YES;
    NSURLSessionUploadTask *uploadTask;
    __weak typeof(self) weakSelf = self;
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
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable err) {
                      __strong typeof(self) strongSelf = weakSelf;
                      CYLog(@"%@", responseObject);
                      @try {
                          if (err) {
                              @throw NSException(kCourtesyInvalidHttpResponse, [err localizedDescription]);
                          }
                          if (!responseObject ||
                              ![responseObject isKindOfClass:[NSDictionary class]] ||
                              ![responseObject hasKey:@"error"] ||
                              ![responseObject hasKey:@"id"]) {
                              @throw NSException(kCourtesyInvalidHttpResponse, @"服务器错误");
                          }
                          NSInteger errorCode = [[responseObject objectForKey:@"error"] integerValue];
                          if (errorCode == 0) {
                              NSString *recv = [responseObject objectForKey:@"id"];
                              strongSelf.avatar = recv;
                              [strongSelf callbackAvatarDelegateSucceed];
                              return;
                          } else if (errorCode == 403) {
                              @throw NSException(kCourtesyForbidden, @"请重新登录");
                          } else if (errorCode == 422) {
                              @throw NSException(kCourtesyUnexceptedStatus, [NSString stringWithFormat:@"图片尺寸不正确"]);
                          } else {
                              @throw NSException(kCourtesyUnexceptedStatus, ([NSString stringWithFormat:@"未知错误 (%ld)", (long)errorCode]));
                          }
                      }
                      @catch (NSException *exception) {
                          if ([exception.name isEqualToString:kCourtesyForbidden]) {
                              [sharedSettings setHasLogin:NO];
                          }
                          [strongSelf callbackAvatarDelegateWithErrorMessage:exception.reason];
                          return;
                      }
                      @finally {
                          isRequestingUploadAvatar = NO;
                      }
                  }];
    [uploadTask resume];
}

#pragma mark - 组合远程头像地址

- (NSString *)avatar {
#warning Replace unnecessary fix
    return [_avatar stringByReplacingOccurrencesOfString:kAvatarSizeLarge withString:@""];
}

- (NSURL *)avatar_url_small {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_AVATAR, [self.avatar stringByAppendingString:kAvatarSizeSmall]]];
}

- (NSURL *)avatar_url_medium {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_AVATAR, [self.avatar stringByAppendingString:kAvatarSizeMiddle]]];
}

- (NSURL *)avatar_url_large {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_AVATAR, [self.avatar stringByAppendingString:kAvatarSizeLarge]]];
}

- (NSURL *)avatar_url_original {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_DOWNLOAD_AVATAR, [self.avatar stringByAppendingString:kAvatarSizeOriginal]]];
}

- (void)dealloc {
    CYLog(@"");
}

@end
