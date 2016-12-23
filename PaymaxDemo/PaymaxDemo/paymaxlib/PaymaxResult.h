//
//  PaymaxSDK
//
//  Created by William on 16/8/11.
//  Copyright © 2016年 SWWX. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  返回值详解
 */
typedef NS_ENUM(NSUInteger, PaymaxBackExplain) {
    
    Paymax_CODE_SUCCESS = 2000,                      /**< 成功*/
    Paymax_CODE_FAIL_CANCEL = 4004,                  /**< 用户取消支付*/
    Paymax_CODE_ERROR_DEAL = 4201,                   /**< 处理中*/
    Paymax_CODE_Failure = 4005,                      /**< 失败*/
    Paymax_CODE_ERROR_CONNECT = 4202,                /**< 网络错误*/
    Paymax_CODE_ChannelWrong = 4003,                 /**< 渠道信息错误*/
    Paymax_CODE_ERROR_CHARGE_PARAMETER = 4002,       /**< 参数信息错误*/
    Paymax_CODE_ERROR_WX_NOT_INSTALL = 4101,         /**< 未安装微信*/
    Paymax_CODE_ERROR_WX_NOT_SUPPORT_PAY = 4102,     /**< 微信不支持*/
    Paymax_CODE_ERROR_WX_UNKNOW = 4103               /**< 微信未知错误*/
};

@interface PaymaxResult :NSObject

/**
 *  枚举详解
 */
@property (assign, nonatomic) PaymaxBackExplain explain;
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
 *  Paymax返回的错误码
 */
@property (assign, nonatomic) NSInteger prCode;

@end

