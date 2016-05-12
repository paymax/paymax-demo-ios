//
//  PayRightSDK.h
//  PayRightSDK
//
//  Created by William on 16/4/13.
//  Copyright © 2016年 顺维无限. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  返回值详解
 */
typedef NS_ENUM(NSUInteger, PayRightBackExplain) {
    
    PayRight_CODE_SUCCESS,                      /**< 成功*/
    PayRight_CODE_FAIL_CANCEL,                  /**< 用户取消支付*/
    PayRight_CODE_ERROR_DEAL,                   /**< 处理中*/
    PayRight_CODE_Failure,                      /**< 失败*/
    PayRight_CODE_ERROR_CONNECT,                /**< 网络错误*/
    PayRight_CODE_ChannelWrong,                 /**< 渠道信息错误*/
    PayRight_CODE_ERROR_CHARGE_PARAMETER,       /**< 参数信息错误*/
    PayRight_CODE_ERROR_WX_NOT_INSTALL,         /**< 未安装微信*/
    PayRight_CODE_ERROR_WX_NOT_SUPPORT_PAY,     /**< 微信不支持*/
    PayRight_CODE_ERROR_WX_UNKNOW               /**< 微信未知错误*/
};


@interface PayRightBack :NSObject

typedef void(^PRCompletionBlock)(PayRightBack *payRightBack);

/**
 *  枚举详解
 */
@property (assign, nonatomic) PayRightBackExplain explain;
/**
 *  支付渠道返回的错误码
 */
@property (copy, nonatomic) NSString *channelBackCode;
/**
 *  错误详解
 */
@property (copy, nonatomic) NSString *backDescription;
/**
 *  支付渠道
 */
@property (copy, nonatomic) NSString *channel;
/**
 *  PayRight返回的错误码
 */
@property (assign, nonatomic) NSInteger prCode;

@end

@interface PayRightSDK : NSObject

@property (retain, nonatomic) PayRightBack *payRightBack;

@property (strong, nonatomic) PRCompletionBlock prCompletionBlock;

/**
 *  支付接口
 *
 *  @param essential        支付要素
 *  @param schemeStr        调用支付的app注册在info.plist中的scheme
 *  @param complethionBlock 支付结果回调Block
 */
+ (void)pay:(NSDictionary *)charge
  appScheme:(NSString *)schemeStr
 completion:(PRCompletionBlock)complethionBlock;


/**
 *  处理支付渠道通过URL启动App时传递的数据
 *
 *  @param url             支付渠道再启动第三方应用时传递过来的URL
 *  @param completionBlock 保证跳转钱包支付过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果
 *
 *  @return                成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)url withCompletion:(PRCompletionBlock)completionBlock;

/**
 *  SDK当前版本号
 *
 *  @return SDK当前版本号
 */
- (NSString *)currentSDKVersion;


@end
