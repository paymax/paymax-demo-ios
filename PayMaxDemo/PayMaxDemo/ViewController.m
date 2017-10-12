//
//  ViewController.m
//  PaymaxDemo
//
//  Created by William on 16/5/17.
//  Copyright © 2016年 顺维无限. All rights reserved.
//


#import "PaymaxSDK.h"
#import "ViewController.h"
#import "WXApi.h"

@interface ViewController ()<UIAlertViewDelegate> {
    
    NSString *_channel;
}
@property (nonatomic, copy)   NSString *userIdStr;
@property (nonatomic, assign) NSInteger selectrow;
@property (nonatomic, strong) UITextField *amountTextfield;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [PaymaxSDK currentSDKVersion];
}

- (IBAction)alipayAction:(id)sender {
    _channel = @"alipay_app";
    [self doPaymax];
}

- (IBAction)wxpayAction:(id)sender {
    _channel = @"wechat_app";
    [self doPaymax];
}

- (IBAction)lklpayAction:(id)sender {
    _channel = @"lakala_app";
    [self doPaymax];
}

- (void)doPaymax {
    static NSString *_urlString = @"http://172.30.21.23:8899/v1/chargeOrders/test";
    //根据业务需求更换参数值
    NSDictionary *_parameterDic = @{@"channel"     : _channel,
                                    @"totalPrice"  : @"0.01",
                                    @"title"       : @"subject",
                                    @"body"        : @"test",
                                    @"extra"       : @{@"user_id":@"888888122918"},
                                    @"time_expire" : [self time_expire]};
    //获取订单数据
    NSData *_response = [self dataTaskWithURLStr:_urlString HTTPMethod:@"POST" parameterDic:_parameterDic];
    if (_response != nil) {
        NSDictionary *_charge = nil;
        //使用系统自带json解析方法解析出订单数据
        _charge = [NSJSONSerialization JSONObjectWithData:_response options:kNilOptions error:NULL];
        if (_charge != nil) {
            NSLog(@"_charge -- %@",_charge);
            /**
             使用解析后的订单数据调取PaymaxSDK
             */
            [PaymaxSDK pay:_charge appScheme:@"wx5269eef08886e3d5" viewController:self completion:^(PaymaxResult *result) {
                if (result.backStr == nil) {
                    [self showAlertMessage:[NSString stringWithFormat:@"%lu",(unsigned long)result.type]];
                }else {
                    [self showAlertMessage:result.backStr];
                }
            }];
        }else {
            NSLog(@"服务器返回json数据失败");
        }
    }else {
        NSLog(@"服务器错误");
    }
}

//获取订单支付时效，3600代表3600秒后订单失效，可以根据业务需求自行更改。
- (NSNumber *)time_expire {
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970] * 1000;
    long long expireTime = [[NSNumber numberWithDouble:nowtime] longLongValue] + 3600 * 1000;
    NSNumber *theTime = [NSNumber numberWithLongLong:expireTime];
    return theTime;
}

- (NSData *)dataTaskWithURLStr:(NSString *)urlStr
                    HTTPMethod:(NSString *)HTTPMethod
                  parameterDic:(NSDictionary *)parameterDic{
    NSMutableURLRequest *_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [_request setHTTPMethod:HTTPMethod];
    [_request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    if (parameterDic != nil) {
        NSData* _data = [NSJSONSerialization dataWithJSONObject:parameterDic options:kNilOptions error:nil];
        NSString *_bodyData = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        [_request setHTTPBody:[NSData dataWithBytes:[_bodyData UTF8String] length:strlen([_bodyData UTF8String])]];
    }
    NSData *_response = [NSURLConnection sendSynchronousRequest:_request returningResponse:nil error:nil];
    
    return _response;
}

- (void)showAlertMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
