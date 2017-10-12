#iOS SDK 接入指南

##安装
####手动导入
1.在Paymax官网下载iOS SDK开发包，将lib目录下的文件添加到你的项目

2.依赖 Frameworks：
>必需：

>CFNetwork.framework

>SystemConfiguration.framework

>Security.framework

>libc++.dylib

>libz.dylib

>libsqlite3.0.dylib

> CoreTelephony.framework

3.添加 URL Schemes：在 Xcode 中，选择你的工程设置项，选中 TARGETS 一栏，在 Info 标签栏的 URL Types 添加 URL Schemes，如果使用微信，填入微信平台上注册的应用程序 id（为 wx 开头的字符串），如果不使用微信，则自定义，建议起名稍复杂一些，尽量避免与其他程序冲突。允许英文字母和数字，首字母必须是英文字母，不允许特殊字符。
![](https://pay.weixin.qq.com/wiki/doc/api/img/chapter8_5_1.png)

##调用支付
######客户端从服务器端拿到支付要素后，调用下面的方法
```/**
/**
 *  支付接口
 *
 *  @param charge           支付要素
 *  @param schemeStr        调用支付的app注册在info.plist中的scheme
 *  @param viewController   当前的viewController
 *  @param completionBlock  支付结果回调Block(拉卡拉支付和支付宝网页支付回调结果在这里处理，跳转APP支付在handleOpenURL方法里处理)
 */[PaymaxSDK pay:_charge appScheme:@"wx5269eef08886e3d5" viewController:self completion:^(PaymaxResult *result) {
	
			[self showAlertMessage:result.backStr];
	}];  
```
##接收并处理交易结果
######渠道为微信、支付宝且安装了支付宝钱包，请在AppDelegate.m里实现下面的方法

```
// iOS 8及以下 请用这个
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PaymaxSDK handleOpenURL:url withCompletion:^(PaymaxResult *result) {
        NSLog(@"支付结果：%@",result.backStr);
    }];
}

// iOS 9 以上请用这个
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    return [PaymaxSDK handleOpenURL:url withCompletion:^(PaymaxResult *result) {
        NSLog(@"支付结果：%@",result.backStr);
    }];
}

```
######错误返回
```
typedef NS_ENUM(NSUInteger, PaymaxBackType) {
    
    PAYMAX_CODE_SUCCESS = 2000,                      /**< 成功*/
    PAYMAX_CODE_FAIL_CANCEL = 4004,                  /**< 用户取消支付*/
    PAYMAX_CODE_ERROR_DEAL = 4201,                   /**< 处理中*/
    PAYMAX_CODE_FAILURE = 4005,                      /**< 失败*/
    PAYMAX_CODE_ERROR_CONNECT = 4202,                /**< 网络错误*/
    PAYMAX_CODE_CHANNEL_WRONG = 4003,                /**< 渠道信息错误*/
    PAYMAX_CODE_ERROR_CHARGE_PARAMETER = 4002,       /**< 参数信息错误*/
    PAYMAX_CODE_ERROR_WX_NOT_INSTALL = 4101,         /**< 未安装微信*/
    PAYMAX_CODE_ERROR_WX_NOT_SUPPORT_PAY = 4102,     /**< 微信不支持*/
    PAYMAX_CODE_ERROR_WX_UNKNOW = 4103               /**< 微信未知错误*/
};

```




##注意事项

1.
针对使用 Xcode 7 编译失败，遇到错误信息为：
XXXXXXX does not contain bitcode. You must rebuild it with bitcode enabled (Xcode setting ENABLE_BITCODE), obtain an updated library from the vendor, or disable bitcode for this target.

请到 Xcode 项目的 Build Settings 标签页搜索 bitcode，将 Enable Bitcode 设置为 NO 即可。


2.
针对 iOS 9 限制 http 协议的访问，如果 App 需要访问 http://， 则需要在 Info.plist 添加如下代码：

```
在Info.plist中添加NSAppTransportSecurity类型Dictionary。
在NSAppTransportSecurity下添加NSAllowsArbitraryLoads类型Boolean,值设为YES
```
3.
如果微信支付完成后无法跳回到自己的APP可能是获取到的APPID与URL Types里添加 的URL Schemes不同

4.
在plist里添加微信和支付宝的白名单![](http://ww4.sinaimg.cn/mw690/b3bb7013jw1f41ppynsfvj20gb022aa7.jpg)

5.
在Build Settings->Other Linker Flags 中添加 -ObjC 关键字

6.
如果使用拉卡拉支付需要导入lklimages文件夹


