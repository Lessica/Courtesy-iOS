# 礼记
礼记之谊，记礼之情。

## 简介
- 一个优雅的项目。
- 一个优雅的应用。
- 一个优雅的礼物二维码卡片分发平台。

## 描述
礼记是一个基于阿里公有云的腾讯互联轻应用。

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

### 注销 Logout
```json
{
    "action": "user_logout",
    "version": 2
}
```

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
        "has_profile": true,
        "profile": {
            "nick": "\u6211\u53eb i_82",
            "avatar": "\\static\\avatar\\aaca0f5eb4d2d98a6ce6dffa99f8254b_300.png",
            "mobile": "13270593207",
            "birthday": "1996-06-18",
            "gender": 1,
            "province": "\u6c5f\u82cf",
            "city": "\u5357\u4eac",
            "area": "\u9097\u6c5f\u533a",
            "introduction": ""
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
        "avatar": "\\static\\avatar\\aaca0f5eb4d2d98a6ce6dffa99f8254b_300.png",
        "mobile": "13270593207",
        "birthday": "1996-06-18",
        "gender": 1,
        "province": "\u6c5f\u82cf",
        "city": "\u5357\u4eac",
        "area": "\u9097\u6c5f\u533a",
        "introduction": ""
    }
}
```

### 上传用户头像 Upload Avatar
POST /upload/avatar (Field: file)

- 尺寸不合要求 Size Dismatch
```json
{
    "error": 422,
    "timestamp": 1456283003
}
```

- 上传成功 Upload Succeed
```json
{
    "error": 0,
    "id": "59d632f13aef67deace793df18174dc0",
    "time": 1456503286
}
```

## 二维码业务逻辑 QRCode Workflow

![flow](http://i11.tietuku.com/48d5269a16f36722.png "flow")

### 查询二维码状态 Query QRCode Status
```json
{
    "action":"qr_query",
    "qr_id":"xxxx",
}
```

- 二维码未录入数据 Not Recorded
```json
{
    "error": 0,
    "qr_info": {
        "is_recorded": false,
        "scan_count": 0,
        "created_at": 1456457567,
        "channel": 0,
        "recorded_at": null,
        "card_token": null,
        "unique_id": "3a0137fbecf5a7bfbc25af10c27c54b4"
    },
    "card_info": null,
    "timestamp": 1456283003
}
```

- 二维码已录入数据 Published Card
```json
{
    "error": 0,
    "qr_info": {
        "is_recorded": true,
        "scan_count": 0,
        "created_at": 1456457567,
        "channel": 0,
        "recorded_at": 1456457593,
        "card_token": "daffed346e29c5654f54133d1fc65ccb",
        "unique_id": "3a0137fbecf5a7bfbc25af10c27c54b4"
    },
    "timestamp": 1456283003
}
```

### 查询卡片状态 Query Card Status
```json
{
    "action": "card_query",
    "token": "00b3eed3b733afba6e45cdedf0036801"
}
```

- 成功 Succeed
```json
{
    "error": 0,
    "card_info": {
        "read_by": 1001,
        "is_editable": true,
        "is_public": true,
        "local_template": "you will do it :)",
        "view_count": 1,
        "author_id": 4,
        "author": "test004",
        "created_at": 1456547164,
        "modified_at": 1456547164,
        "first_read_at": null,
        "token": "00b3eed3b733afba6e45cdedf0036801",
        "edited_count": 0,
        "stars": 0
    },
    "timestamp": 1456283003
}
```

- 卡片被禁用 Banned Card
```json
{
    "error": 426,
    "timestamp": 1456283198
}
```

- 卡片未到查询时间 Card Not Visible (local_template = null)

### 修改卡片内容 Edit Card
```json
{
    "action": "card_edit",
    "token": "00b3eed3b733afba6e45cdedf0036801",
    "card_info": {
        "local_template": "you will do it :)",
        "is_editable": true,
        "is_public": true,
        "visible_at": "1999-02-02 00:00:00"
    }
}
```

- 成功 Succeed
```json
{
    "error": 0,
    "card_info": {
        "read_by": 1001,
        "is_editable": true,
        "is_public": true,
        "local_template": "you will do it :)",
        "view_count": 1,
        "author_id": 4,
        "author": "test004",
        "created_at": 1456547164,
        "modified_at": 1456548900,
        "first_read_at": null,
        "token": "00b3eed3b733afba6e45cdedf0036801",
        "edited_count": 1,
        "stars": 0
    },
    "timestamp": 1456283003
}
```

- 修改用户无权限 No Card Privilege
```json
{
    "error": 425,
    "timestamp": 1456283098
}
```

- 卡片被禁用 Banned Card (同上)

### 发布卡片 Publish New Card
```json
{
    "action": "card_create",
    "qr_id": "3a0137fbecf5a7bfbc25af10c27c54b4",
    "card_info": {
        "local_template": "you will do it :)",
        "is_editable": true,
        "is_public": true,
        "visible_at": "1999-02-02 00:00:00"
    }
}
```

- 成功 Succeed
```json
{
    "error": 0,
    "card_info": {
        "read_by": null,
        "is_editable": true,
        "is_public": true,
        "local_template": "you will do it :)",
        "view_count": 0,
        "author_id": 4,
        "author": "test004",
        "created_at": 1456628015,
        "modified_at": 1456628015,
        "first_read_at": null,
        "token": "080f651e3fcca17df3a47c2cecfcb880",
        "edited_count": 0,
        "stars": 0
    },
    "timestamp": 1456628016
}
```

- QRCode 已被自己使用 Recorded QRCode
```json
{
    "error": 424,
    "qr_info": {
        "is_recorded": true,
        "scan_count": 0,
        "created_at": 1456457567,
        "channel": 0,
        "recorded_at": 1456457593,
        "unique_id": "3a0137fbecf5a7bfbc25af10c27c54b4",
        "card_token": "daffed346e29c5654f54133d1fc65ccb"
    },
    "timestamp": 1456628034
}
```

### 检查卡片资源是否存在 Query Card Resources
```json
{
    "action": "res_query",
    "hash": "a9993e364706816aba3e25717850c26c9cd0d89d"
}
```

- 资源存在 File Exists
```json
{
    "time": 1456622272,
    "id": "6859b83bcb97c0a4690ccb950cf3c0da",
    "error": 0
}
```

- 资源不存在 File Not Exists (404)

### 上传卡片资源 Upload Card Resources
POST /upload/card_res (Field: res)

- 成功 Succeed
```json
{
    "time": 1456622272,
    "id": "6859b83bcb97c0a4690ccb950cf3c0da",
    "error": 0
}
```
