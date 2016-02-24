# 礼记
礼记之谊，记礼之情。

## 简介
- 一个优雅的项目。
- 一个优雅的应用。
- 一个优雅的礼物二维码卡片分发平台。

## 描述
礼记是一个基于阿里公有云的腾讯互联轻应用。

## TODOs
- 不支持 iPad 横屏显示 (LBXScan)

## 协议 Protocol

### 通用 Common
POST /api/courtesy

- 通用成功 Common Succeed
```json
{
    "error": 0,
    "timestamp": 1456283003
}
```

- 错误的请求 Bad Request (e.g. Not POST)
```json
{
    "error": 400,
    "timestamp": 1456283003
}
```

- 无效的字段或格式 Invalid Field & Invalid Format (e.g. over-length)
```json
{
    "error": 401,
    "field": "email",
    "timestamp": 1456283003
}
```

- 缺少字段 Missing Field
```json
{
    "error": 402,
    "field": "account",
    "timestamp": 1456283003
}
```

- 无权限 Forbidden (e.g. not login)
```json
{
    "error": 403,
    "timestamp": 1456283003
}
```

- 未找到 Not Found (e.g. action not found)
```json
{
    "error": 404,
    "timestamp": 1456283003
}
```

- 服务器错误 Service Error (e.g. MYSQL error)
```json
{
    "error": 503,
    "timestamp": 1456283003
}
```

### 注册 Register
```json
{
    "action": "user_register",
    "account": {
        "email": "i.82@qq.com",
        "pwd": "5f4dcc3b5aa765d61d8327deb882cf99"
    },
    "version": 2
}
```

- 账户冲突 Conflict
```json
{
    "error": 405,
    "field": "email",
    "timestamp": 1456283003
}
```

### 登录 Login
```json
{
    "action": "user_login",
    "account": {
        "email": "i.82@me.com",
        "pwd": "5f4dcc3b5aa765d61d8327deb882cf99"
    },
    "version": 2
}
```

- 认证失败 Account Not Found & Wrong Password
```json
{
    "error": 406,
    "timestamp": 1456283003
}
```

- 账户被禁用 Account Banned
```json
{
    "error": 407,
    "timestamp": 1456283003
}
```

- 登录成功 Login Succeed (SESSION in Cookie)

### 获取用户信息 Get User Info
```json
{
    "action": "user_info",
    "version": 2
}
```

- 获取成功 Succeed
```json
{
    "error": 0,
    "account_info": {
        "user_id": 1,
        "email": "i.82@me.com",
        "registered_at": 1456283003,
        "last_login_at": 1456283003,
        "card_count": 2,
        "profile": {
            "nick": "\u6211\u53eb i_82",
            "avatar": "aaca0f5eb4d2d98a6ce6dffa99f8254b",
            "mobile": "13270593207",
            "birthday": "1996-06-18",
            "gender": 1,
            "province": "\u6c5f\u82cf",
            "city": "\u5357\u4eac",
            "constellation": "\u53cc\u5b50\u5ea7"
        }
    },
    "timestamp": 1456283003
}
```

### 修改用户信息 Edit Profile
```json
{
    "action": "user_edit_profile",
    "version": 2,
    "profile": {
        "nick": "\u6211\u53eb i_82",
        "avatar": "aaca0f5eb4d2d98a6ce6dffa99f8254b",
        "mobile": "13270593207",
        "birthday": "1996-06-18",
        "gender": 1,
        "province": "\u6c5f\u82cf",
        "city": "\u5357\u4eac",
        "constellation": "\u53cc\u5b50\u5ea7"
    }
}
```
