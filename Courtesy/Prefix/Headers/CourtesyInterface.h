
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

#define API_DOMAIN @"115.28.214.126"
#define API_TIMEOUT 20.0
#define API_URL @"http://115.28.214.126:8000/api/courtesy"
#define API_UPLOAD_AVATAR @"http://115.28.214.126:8000/upload/avatar"
#define API_DOWNLOAD_AVATAR @"http://115.28.214.126:8000/static/avatar"
#define API_FORGET_PASSWORD @"http://115.28.214.126:8000/courtesy/reset"
#define API_DOWNLOAD_FONT @"http://115.28.214.126:8000/static/fonts"
#define API_QRCODE_PATH @"/qrcode"

#define API_RSYNC_HOST @"115.28.214.126"
#define API_RSYNC_PROTOCOL 30
#define API_RSYNC_PORT 873
#define API_RSYNC_USERNAME @"ursync"
#define API_RSYNC_PASSWORD @"rsync"
#define API_RSYNC_MODULE @"test"

#define API_USE_LOCAL_THUMBNAIL 1

#else

#define API_DOMAIN @"10.0.1.222"
#define API_TIMEOUT 20.0
#define API_URL @"http://10.0.1.222/api/courtesy"
#define API_UPLOAD_AVATAR @"http://10.0.1.222/upload/avatar"
#define API_DOWNLOAD_AVATAR @"http://10.0.1.222/static/avatar"
#define API_FORGET_PASSWORD @"http://10.0.1.222/courtesy/reset"
#define API_DOWNLOAD_FONT @"http://10.0.1.222/static/fonts"
#define API_QRCODE_PATH @"/qrcode"

#define API_RSYNC_HOST @"10.0.1.2"
#define API_RSYNC_PROTOCOL 29
#define API_RSYNC_PORT 873
#define API_RSYNC_USERNAME @""
#define API_RSYNC_PASSWORD @""
#define API_RSYNC_MODULE @"test"

#define API_USE_LOCAL_THUMBNAIL 1

#endif

// 头像尺寸相关
#define kAvatarSizeSmall @"_60.png"
#define kAvatarSizeMiddle @"_150.png"
#define kAvatarSizeLarge @"_300.png"
#define kAvatarSizeOriginal @".png"

#endif /* CourtesyInterface_h */
