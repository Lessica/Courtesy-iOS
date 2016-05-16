
//
//  CourtesyInterface.h
//  Courtesy
//
//  Created by Zheng on 3/9/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#ifndef CourtesyInterface_h
#define CourtesyInterface_h

// 接口常量
#ifdef WWW_API

#define API_DOMAIN @"courtesy.82flex.com"
#define API_TIMEOUT 20.0
#define API_URL @"https://courtesy.82flex.com/api/courtesy"
#define API_UPLOAD_AVATAR @"https://courtesy.82flex.com/upload/avatar"
#define API_DOWNLOAD_AVATAR @"https://courtesy.82flex.com/static/avatar"
#define API_FORGET_PASSWORD @"https://courtesy.82flex.com/courtesy/reset"
#define API_TOS @"https://courtesy.82flex.com/tos.html"
#define API_DOWNLOAD_FONT @"https://courtesy.82flex.com/static/fonts"
#define API_QRCODE_PATH @"/qrcode"

#define API_STATIC_NEWS_RESOURCES @"https://courtesy.82flex.com/static/news/%@/%@.%@"
#define API_STATIC_RESOURCES @"https://courtesy.82flex.com/static/card"

#define API_CARD_SHARE @"https://courtesy.82flex.com/share/card/%@"
#define API_DAILY_SHARE @"https://courtesy.82flex.com/share/daily/%@"

#define API_RSYNC_HOST @"courtesy.82flex.com"
#define API_RSYNC_PROTOCOL 30
#define API_RSYNC_PORT 873
#define API_RSYNC_USERNAME @"ursync"
#define API_RSYNC_PASSWORD @"rsync"
#define API_RSYNC_MODULE @"test"

#define API_USE_LOCAL_THUMBNAIL 1

#else

#define API_DOMAIN @"115.28.214.126"
#define API_TIMEOUT 20.0
#define API_URL @"http://115.28.214.126:8000/api/courtesy"
#define API_UPLOAD_AVATAR @"http://115.28.214.126:8000/upload/avatar"
#define API_DOWNLOAD_AVATAR @"http://115.28.214.126:8000/static/avatar"
#define API_FORGET_PASSWORD @"http://115.28.214.126:8000/courtesy/reset"
#define API_TOS @"https://82flex.com/html/courtesy/tos.html"
#define API_DOWNLOAD_FONT @"http://115.28.214.126:8000/static/fonts"
#define API_QRCODE_PATH @"/qrcode"

#define API_STATIC_NEWS_RESOURCES @"http://115.28.214.126:8000/static/news/%@/%@.%@"
#define API_STATIC_RESOURCES @"http://115.28.214.126:8000/static/card"

#define API_CARD_SHARE @"http://115.28.214.126:8000/share/card/%@"
#define API_DAILY_SHARE @"http://115.28.214.126:8000/share/daily/%@"

#define API_RSYNC_HOST @"115.28.214.126"
#define API_RSYNC_PROTOCOL 30
#define API_RSYNC_PORT 873
#define API_RSYNC_USERNAME @"ursync"
#define API_RSYNC_PASSWORD @"rsync"
#define API_RSYNC_MODULE @"test"

#define API_USE_LOCAL_THUMBNAIL 1

#endif

// 头像尺寸相关
#define kAvatarSizeSmall @"_60.png"
#define kAvatarSizeMiddle @"_150.png"
#define kAvatarSizeLarge @"_300.png"
#define kAvatarSizeOriginal @".png"

#endif /* CourtesyInterface_h */
