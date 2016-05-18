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
#define SERVICE_EMAIL @"i.82@me.com"
#define SERVICE_INDEX @"https://82flex.com"

#define UMENG_APP_KEY @"56ca911667e58ec982000f95"
#define PREIM_APP_KEY @"44be09c7811bd4338b2a5ccc8691eda4"
#define TENCENT_APP_ID @"1105118171"
#define TENCENT_APP_KEY @"ohCJO8RCZqLJ273K"
#define WEIBO_APP_ID @"400586587"
#define WEIBO_APP_KEY @"686ce0bb875d2d4695305e31553e3a07"
#define AUTONAVI_APP_KEY @"8ecd95e906368ca61ae01db5b970f617"
#define WEIXIN_APP_ID @"wxd930ea5d5a258f4f"
#define WEIXIN_APP_SECRET @"db426a9829e4b49a0dcac7b4162da6b6"

#define APP_DOWNLOAD_URL @"https://courtesy.82flex.com/download"
#define WEIBO_SHARE_CONTENT @"#礼记# 礼记之谊，记礼之情。\n%@ 邀您使用「礼记」，一款优雅的卡片社交应用：%@ （来自 @礼记APP）"
#define WEIBO_CARD_SHARE_CONTENT @"#礼记# 礼记之谊，记礼之情。\n%@ 分享给你一张卡片：%@ （来自 @礼记APP）"
#define WEIBO_DAILY_SHARE_CONTENT @"#礼记# %@ （来自 @礼记APP）"

#define UMENG_SHARE_PLATFORMS \
  @[UMShareToQQ, \
    UMShareToQzone, \
    UMShareToWechatSession, \
    UMShareToWechatFavorite, \
    UMShareToWechatTimeline, \
    UMShareToSina, \
    UMShareToTencent, \
    UMShareToTwitter, \
    UMShareToDouban, \
    UMShareToRenren, \
    UMShareToEmail]

#define UmengSetShareType(shareUrl) \
if (shareUrl) { \
    [UMSocialData defaultData].extConfig.qqData.url = shareUrl; \
    [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl; \
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault; \
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeNone; \
    [UMSocialData defaultData].extConfig.wechatFavoriteData.wxMessageType = UMSocialWXMessageTypeNone; \
    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeNone; \
} else { \
    [UMSocialData defaultData].extConfig.qqData.url = APP_DOWNLOAD_URL; \
    [UMSocialData defaultData].extConfig.qzoneData.url = APP_DOWNLOAD_URL; \
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage; \
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeImage; \
    [UMSocialData defaultData].extConfig.wechatFavoriteData.wxMessageType = UMSocialWXMessageTypeImage; \
    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeImage; \
}

#endif /* CourtesyTarget_h */
