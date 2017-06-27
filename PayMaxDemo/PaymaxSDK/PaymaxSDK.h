//
//  PaymaxSDK.h
//  PaymaxSDK
//
//  Created by William on 16/8/11.
//  Copyright © 2016年 SWWX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  返回值详解
 */
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

@interface PaymaxResult :NSObject

/**
 *  返回码
 */
@property (assign, nonatomic) PaymaxBackType type;
/**
 *  支付渠道返回的错误码
 */
@property (copy, nonatomic) NSString *channelBackCode;
/**
 *  返回提示字符串
 */
@property (copy, nonatomic) NSString *backStr;
/**
 *  支付渠道
 */
@property (copy, nonatomic) NSString *channel;

@end


///////////////////////////////////////////////////// PaymaxSDK ///////////////////////////////////////////////////////////////////

@interface PaymaxSDK : NSObject {
    @package
    PaymaxResult *_result;
}

/**
 *  支付接口
 *
 *  @param charge           支付要素
 *  @param schemeStr        调用支付的app注册在info.plist中的scheme
 *  @param viewController   当前的viewController
 *  @param completionBlock  支付结果回调Block
 */
+ (void)pay:(NSDictionary *)charge appScheme:(NSString *)schemeStr viewController:(UIViewController *)viewController completion:(void(^)(PaymaxResult *result))completionBlock;

/**
 *  处理支付渠道通过URL启动App时传递的数据
 *
 *  @param url             支付渠道再启动第三方应用时传递过来的URL
 *  @param completionBlock 保证跳转钱包支付过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果
 *
 *  @return                成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)url withCompletion:(void(^)(PaymaxResult *result))completionBlock;

/**
 *  SDK当前版本号
 *
 *  @return SDK当前版本号
 */
+ (NSString *)currentSDKVersion;
@end
