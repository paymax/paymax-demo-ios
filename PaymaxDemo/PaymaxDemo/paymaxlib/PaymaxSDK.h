//
//  PaymaxSDK.h
//  PaymaxSDK
//
//  Created by William on 16/8/11.
//  Copyright © 2016年 SWWX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PaymaxCallback.h"

typedef void(^PMCompletionBlock)(PaymaxCallback *paymaxCallback);

@interface PaymaxSDK : NSObject

@property (strong, nonatomic) PaymaxCallback *paymaxCallback;

/**
 *  支付接口
 *
 *  @param essential        支付要素
 *  @param schemeStr        调用支付的app注册在info.plist中的scheme
 *  @param viewController   当前的viewController
 *  @param complethionBlock 支付结果回调Block
 */
+ (void)pay:(NSDictionary *)charge appScheme:(NSString *)schemeStr viewController:(UIViewController *)viewController completion:
(PMCompletionBlock)completionBlock;


/**
 *  处理支付渠道通过URL启动App时传递的数据
 *
 *  @param url             支付渠道再启动第三方应用时传递过来的URL
 *  @param completionBlock 保证跳转钱包支付过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果
 *
 *  @return                成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)url withCompletion:(PMCompletionBlock)completionBlock;

/**
 *  SDK当前版本号
 *
 *  @return SDK当前版本号
 */
- (NSString *)currentSDKVersion;

@end
