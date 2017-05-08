#Demo 使用指引
## 1. pod install

- 打开控制台CD到 Demo 的根目录下，使用 pod install 命令下载 SDK
- 打开 DroiPushDemo.xcworkspace 开启 Demo

## 2. 替换 AppId

在  Demo 的 `info.plist`文件中将`DROI_APP_ID`替换成从 DroiBaaS 后台中新申请的 AppId 可以参照[快速入门](http://www.droibaas.com/Index/docFile/mark_id/24137.html)

**注意**  
Xcode 8.1 版本的 iOS 10模拟器存在官方的BUG会造成 CSDK 不能正常使用，Apple 已于 Xcode 8.2版本修复了该问题。
