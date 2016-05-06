# 礼记
礼记之谊，记礼之情。

## 简介
- 一个优雅的项目。
- 一个优雅的应用。
- 一个优雅的礼物二维码卡片分发平台。

## 描述
礼记是一个基于阿里公有云的腾讯互联轻应用。

## 关于长文本卡片编辑方案
Demo 版目前采用的是 YYText，暂时不支持局部渲染。
正式版上架会尝试采用锤子便签、WeicoNote 所采用的 TableView 长文本编辑方案。

## iOS 客户端环境部署
- 从 Mac App Store 安装 OS X with Xcode 7.3 (iOS SDK 9.0+)
- 安装 Cocoapods (https://cocoapods.org/)
```shell
$ sudo gem install cocoapods --pre
$ cd Courtesy-iOS
$ pod install --verbose
```
- 打开 Courtesy.xcworkspace 进行编译。

## Django 后端部署
- Python 2.7
- Django 1.9.2
- Nginx + Mysql
