//
//  CourtesyTarget.h
//  Courtesy
//
//  Created by Zheng on 3/9/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#ifndef CourtesyTarget_h
#define CourtesyTarget_h

// 常用常量
#define APP_NAME_EN @"Courtesy"
#define APP_NAME_CN @"礼记"
#define VERSION_STRING [[UIApplication sharedApplication] appVersion]
#define VERSION_BUILD [[UIApplication sharedApplication] appBuildVersion]
#define SERVICE_EMAIL @"jct@82flex.com"
#define SERVICE_INDEX @"https://82flex.com"

#define UMENG_APP_KEY @""
#define TENCENT_APP_ID @""
#define TENCENT_APP_KEY @""
#define WEIBO_APP_ID @""
#define WEIBO_APP_KEY @""
#define AUTONAVI_APP_KEY @""
#define WEIXIN_APP_ID @""
#define WEIXIN_APP_SECRET @""

#define APP_DOWNLOAD_URL @"https://courtesy.82flex.com/download"
#define WEIBO_SHARE_CONTENT @"%@ 邀您使用「礼记」，一款优雅的卡片社交应用：%@ （#礼记# 礼记之谊，记礼之情。\n来自 @礼记APP）"
#define WEIBO_CARD_SHARE_CONTENT @"%@ 分享给你一张卡片：%@ （#礼记# 礼记之谊，记礼之情。\n来自 @礼记APP）"
#define WEIBO_DAILY_SHARE_CONTENT @"%@ （#礼记# 礼记之谊，记礼之情。\n来自 @礼记APP）"

#define UMShareToSystemAlbum @"UMShareToSystemAlbum"
#define UMShareToSystemPasteBoard @"UMShareToSystemPasteBoard"

#define UMENG_SHARE_CARD_PLATFORMS \
  @[UMShareToQQ, \
    UMShareToQzone, \
    UMShareToWechatSession, \
    UMShareToWechatTimeline, \
    UMShareToSina, \
    UMShareToEmail, \
    UMShareToSystemPasteBoard, \
    UMShareToSystemAlbum, \
    ]

#define UMENG_SHARE_PLATFORMS \
  @[UMShareToQQ, \
    UMShareToQzone, \
    UMShareToWechatSession, \
    UMShareToWechatTimeline, \
    UMShareToSina, \
    UMShareToEmail, \
    ]

#define UmengSetShareType(shareUrl, shareImage) \
if (shareUrl) { \
    [UMSocialData defaultData].extConfig.qqData.url = \
    [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl; \
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault; \
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = \
    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeNone; \
} else { \
    [UMSocialData defaultData].extConfig.qqData.url = \
    [UMSocialData defaultData].extConfig.qzoneData.url = APP_DOWNLOAD_URL; \
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage; \
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = \
    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeImage; \
} \
if (shareImage) { \
    [UMSocialData defaultData].extConfig.qqData.shareImage = \
    [UMSocialData defaultData].extConfig.qzoneData.shareImage = \
    [UMSocialData defaultData].extConfig.wechatSessionData.shareImage = \
    [UMSocialData defaultData].extConfig.wechatTimelineData.shareImage = \
    shareImage; \
}

#endif /* CourtesyTarget_h */
