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

#FaceRecoSDK 接入指南
#### <font color=red>不使用人脸识别：</font>直接删除FaceRecoSDK文件夹即可

1.发起支付前，请先通过后台接口判断是否需要调起人脸识别。商户后台通过调用`Paymax Server SDK` 向paymax服务器发起请求，获得结果码的方式进行判断（已经识别过的用户可不用再次识别验证），详细步骤请参考Demo

2.如果需要调用，请参考如下内容：
 ```    
 
     /**
 		*  活体检测接口
 		*
 		*  @param controller  需要弹出活体检测控制器，如果是当前控制器则为self
 		*  @param name        姓名
 		*  @param idCardNo    身份证号
 		*  @param secretKey   商户secretKey
 		*  @param resultBlock 活体检测和人脸识别接口
 		*  /
		+(void)startFaceRecoWithViewController:(UIViewController *)controller	
								              Name:(NSString *)name
                                     IdCardNo:(NSString *)idCardNo
                       					  UserId:(NSString *)userId
                     				  SecretKey:(NSString *)secretKey
                 				  	resultBlock:(void(^)(DetectResult result))resultBlock;
                          
                          
```
     
根据人脸识别结果进行相应处理，识别成功后发送通知到下单页面进行下单，如下为Demo处理情况，仅供参考：


```

 [FaceRecoSDK startFaceRecoWithViewController:self Name:self.nameTextField.text IdCardNo:self.idCardTextField.text UserId:self.userid SecretKey:@"55970fdbbf10459f966a8e276afa86fa" resultBlock:^(DetectResult result) {
        
        switch (result) {
            case DetectResult_LiveCancel:
                [self showAlertMessage:@"活体检测取消"];
                break;
            case DetectResult_LiveFail:
                [self showAlertMessage:@"活体检测失败"];
                break;
            case DetectResult_ACCORDANCE:
                [self.navigationController popViewControllerAnimated:YES];
				   [self showAlertMessage:@"活体检测成功"];
                break;
            case DetectResult_INCONFORMITY:
                [self showAlertMessage:@"人脸识别不一致"];
                break;
            case DetectResult_REQUEST_TIMESTAMP_EXPIRE:
                [self showAlertMessage:@"时间戳过期或超前"];
                break;
            case DetectResult_VERIFY_FAILED:
                [self showAlertMessage:@"签名校验失败"];
                break;
            case DetectResult_ILLEGAL_REQUEST_BODY:
                [self showAlertMessage:@"请求参数不合法"];
                break;
            case DetectResult_ILLEGAL_ARGUMENT:
                [self showAlertMessage:@"非法参数"];
                break;
            case DetectResult_ILLEGAL_DATA:
                [self showAlertMessage:@"请求数据非法"];
                break;
            case DetectResult_IDCARDNO_ERROR:
                [self showAlertMessage:@"身份证号码不正确"];
                break;
            case DetectResult_REALNME_IDCARD_NOT_SAME:
                [self showAlertMessage:@"姓名身份证不匹配"];
                break;
            case DetectResult_NetworkError:
                [self showAlertMessage:@"网络请求错误"];
                
                break;
            default:
                break;
        }
        
    }];

####注意事项

1.工程中需要添加libc++.tbd依赖库

2.人脸识别SDK中通过标准宏TARGET_IPHONE_SIMULATOR判断是模拟器的话就不编译我们的代码，所以当项目中使用人脸识别sdk时，该项目不可以在模拟器环境下编译运行。


