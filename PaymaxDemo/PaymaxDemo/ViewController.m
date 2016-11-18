//
//  ViewController.m
//  PaymaxDemo
//
//  Created by William on 16/5/17.
//  Copyright © 2016年 顺维无限. All rights reserved.
//


#define QUERY_FACE_URL  @"https://www.paymax.cc/mock_merchant_server/v1/face/auth/%@/product"

#define PLACE_ORDER_URL @"https://www.paymax.cc/mock_merchant_server/v1/chargeOrders/product"

#define PM_TRUE 1
#define PM_FALSE 0


#import "ViewController.h"
#import "PaymaxSDK.h"
#import <PassKit/PassKit.h>
#import "FaceRecoSDK.h"
#import "FaceDetectViewController.h"
#define K_APPP_SCHEME @"wx5269eef08886e3d5"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *rootTableView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *tableFooterView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *backgroundActivityIndicatorView;
@property (copy, nonatomic) NSString *urlString;
@property (copy, nonatomic) NSString *channel;
@property (assign, nonatomic) NSInteger selectrow;
@property (strong, nonatomic) UITextField *amountTextfield;
@property (copy, nonatomic) NSString *userIdStr;
@property (assign, nonatomic) long long time_expire;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PaymaxSDK *_paymax = [[PaymaxSDK alloc] init];
    NSLog(@"%@",[_paymax currentSDKVersion]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlaceOrder) name:@"PlaceOrder" object:nil];
    [self setData];
}

- (void)setData {
    
    self.title = @"PaymaxDemo";
    self.backgroundView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.2];
    self.rootTableView.tableFooterView = self.tableFooterView;
    self.channel = @"alipay_app";
    self.urlString = PLACE_ORDER_URL;
    self.time_expire = 3600;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收起键盘" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemAction)];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        default:
            return 3;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    NSString *identifier = @"";
    switch (indexPath.section) {
        case 0:
            identifier = @"cellIdentifier";
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            self.amountTextfield = (UITextField *)[cell.contentView viewWithTag:331];
            break;
        default:
            identifier = @"paycell";
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            UIImageView *_imageView = [cell.contentView viewWithTag:405];
            UILabel *_label = [cell.contentView viewWithTag:437];
            UIImageView *_selectImageView = [cell.contentView viewWithTag:502];
            switch (indexPath.row) {
                case 0:
                    _imageView.image = [UIImage imageNamed:@"zhifubao"];
                    _label.text = @"支付宝";
                    break;
                case 1:
                    _imageView.image = [UIImage imageNamed:@"weixin"];
                    _label.text = @"微信支付";
                    break;
                default:
                    _imageView.image = [UIImage imageNamed:@"lkl"];
                    _label.text = @"拉卡拉";
                    break;
            }
            if (indexPath.row == self.selectrow) {
                _selectImageView.image = [UIImage imageNamed:@"quan_select"];
            }else {
                _selectImageView.image = [UIImage imageNamed:@"quan_noselect"];
            }
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectrow = indexPath.row;
    switch (indexPath.row) {
        case 0:
            self.channel = @"alipay_app";
            break;
        case 1:
            self.channel = @"wechat_app";
            break;
        case 2:
            self.channel = @"lakala_app";
            break;
    }
    [tableView reloadData];
    
}

#pragma mark -- UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (buttonIndex == 1) {
        
        [self.backgroundView setHidden:NO];
        
        [self.backgroundActivityIndicatorView startAnimating];
        
        UITextField *_idTextField = [alertView textFieldAtIndex:0];
        UITextField *_timeTextField = [alertView textFieldAtIndex:1];
        if ([_idTextField.text isEqualToString:@""]) {
            
            self.userIdStr = @"123";
        }else {
            
            self.userIdStr = _idTextField.text;
        }
        if ([_timeTextField.text isEqualToString:@""]) {
            
            self.time_expire = 3600;
        }else {
            
            self.time_expire = [_timeTextField.text doubleValue];
        }
        NSString *_urlStr = [NSString stringWithFormat:QUERY_FACE_URL,self.userIdStr];
        
        [self netWorkWithURL:_urlStr withHTTPMethod:@"GET" withParameter:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self.backgroundView setHidden:YES];
                [self.backgroundActivityIndicatorView stopAnimating];
            });
            
            if (data == nil) {
                dispatch_sync(dispatch_get_main_queue(), ^(){
                    [self showAlertMessage:@"获取数据失败"];
                    return ;
                });
            }else {
                
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:NSJSONReadingAllowFragments
                                                                                 error:nil];
                if (responseObject != nil) {
                    
                    NSLog(@"检测是否活体检测过数据 === %@",responseObject);
                    NSNumber *authValid = responseObject[@"authValid"];
                    NSNumber *reqSuccessFlag = responseObject[@"reqSuccessFlag"];
                    
                    if ([reqSuccessFlag integerValue] == PM_TRUE) {
                        
                        if ([authValid integerValue] == PM_TRUE) {
                            
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                
                                [self PlaceOrder];
                            });
                        }else if ([authValid integerValue] == PM_FALSE){
                            
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                
                                FaceDetectViewController *_faceDetectVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
                                                                           instantiateViewControllerWithIdentifier:@"facereco"];
                                _faceDetectVc.userid = self.userIdStr;
                                [self.navigationController pushViewController:_faceDetectVc animated:YES];
                            });
                        }
                        
                    }else if ([reqSuccessFlag integerValue] == PM_FALSE) {
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            
                            [self showAlertMessage:@"人脸检测请求失败：reqSuccessFlag = 0"];
                        });
                    }
                    
                }else {
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        [self showAlertMessage:@"获取数据失败"];
                    });
                }
            }
            
        }];
    }
}

- (IBAction)payClick:(UIButton *)sender {
    
    if ([self.channel isEqual:@"lakala_app"]) {
        [self faceDetect];
        
    }else {
        [self PlaceOrder];
        
    }
}

- (void)faceDetect {
    
    UIAlertView *_idcardAlertView = [[UIAlertView alloc] initWithTitle:@"请输入UserID和过期时间" message:@"" delegate:self cancelButtonTitle:@"取消"   otherButtonTitles:@"确定", nil];
    _idcardAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    UITextField *_idTextField = [_idcardAlertView textFieldAtIndex:0];
    UITextField *_timeTextField = [_idcardAlertView textFieldAtIndex:1];
    _idTextField.placeholder = @"请输入UserID";
    _timeTextField.placeholder = @"请输入过期时间(秒，默认3600秒)";
    _timeTextField.secureTextEntry = NO;
    [_idcardAlertView show];
}
#pragma mark - 下单
- (void)PlaceOrder {
    
    [self.backgroundView setHidden:NO];
    [self.backgroundActivityIndicatorView startAnimating];
    if (self.userIdStr == nil) {
        self.userIdStr = @"123";
    }
    
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970] * 1000;
    long long newTime = [[NSNumber numberWithDouble:nowtime] longLongValue] + self.time_expire * 1000;
    NSNumber *theTime = [NSNumber numberWithLongLong:newTime];
    
    NSDictionary* _parameter = @{
                                 @"channel"     : self.channel,
                                 @"totalPrice"  : self.amountTextfield.text,
                                 @"title"       : @"subject",
                                 @"body"        : @"test",
                                 @"extra"       : @{@"user_id":self.userIdStr},
                                 @"time_expire" : theTime
                                 };
    
    [self netWorkWithURL:self.urlString withHTTPMethod:@"POST" withParameter:_parameter completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *responseObject;
        
        if (data != nil){
            
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        }else{
            
            responseObject = nil;
        }
        if (error){
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.backgroundView setHidden:YES];
                [self.backgroundActivityIndicatorView stopAnimating];
                [self showAlertMessage:[NSString stringWithFormat:@"%@",error.localizedDescription]];
            });
            
        }else{
            
            NSLog(@"responseObject-------%@",responseObject);
            dispatch_sync(dispatch_get_main_queue(), ^(){
                
                if (responseObject == nil){
                    
                    [self showAlertMessage:@"未获取支付信息"];
                    [self.backgroundView setHidden:YES];
                    [self.backgroundActivityIndicatorView stopAnimating];
                    return ;
                }
                [self.backgroundView setHidden:YES];
                [self.backgroundActivityIndicatorView stopAnimating];
                [PaymaxSDK   pay:responseObject
                       appScheme:K_APPP_SCHEME
                  viewController:self
                      completion:^(PaymaxResult *paymaxCallback) {
                          
                          switch (paymaxCallback.explain) {
                              case Paymax_CODE_SUCCESS:
                                  [self showAlertMessage:@"成功"];
                                  break;
                              case Paymax_CODE_FAIL_CANCEL:
                                  [self showAlertMessage:@"用户取消支付"];
                                  break;
                              case Paymax_CODE_ERROR_DEAL:
                                  [self showAlertMessage:@"处理中"];
                                  break;
                              case Paymax_CODE_Failure:
                                  [self showAlertMessage:@"支付失败"];
                                  break;
                              case Paymax_CODE_ERROR_CONNECT:
                                  [self showAlertMessage:@"网络错误"];
                                  break;
                              case Paymax_CODE_ChannelWrong:
                                  [self showAlertMessage:[NSString stringWithFormat:@"%@",responseObject[@"failure_msg"]]];
                                  break;
                              case Paymax_CODE_ERROR_CHARGE_PARAMETER:
                                  [self showAlertMessage:@"参数信息错误"];
                                  break;
                              case Paymax_CODE_ERROR_WX_NOT_INSTALL:
                                  [self showAlertMessage:@"未安装微信"];
                                  break;
                              case Paymax_CODE_ERROR_WX_NOT_SUPPORT_PAY:
                                  [self showAlertMessage:@"微信不支持"];
                                  break;
                              case Paymax_CODE_ERROR_WX_UNKNOW:
                                  [self showAlertMessage:@"微信未知错误"];
                                  break;
                          }
                          NSLog(@"paymaxBack.channelBackCode=%@\npaymaxBack.channel=%@\npaymaxBack.backDescription=%@\npaymaxBack.prCode=%ld",paymaxCallback.channelBackCode,paymaxCallback.channel,paymaxCallback.backDescription,(long)paymaxCallback.prCode);
                      }];
            });
        }
    }];
}

- (void)netWorkWithURL:(NSString *)url withHTTPMethod:(NSString *)HTTPMethod withParameter:(NSDictionary *)parameter completionHandler:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler {
    
    NSURLSession *_session = [NSURLSession sharedSession];
    NSURL *_url = [NSURL URLWithString:url];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:_url];
    [_request setHTTPMethod:HTTPMethod];
    [_request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    if (parameter != nil) {
        
        NSData* _data = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:nil];
        NSString *_bodyData = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        [_request setHTTPBody:[NSData dataWithBytes:[_bodyData UTF8String] length:strlen([_bodyData UTF8String])]];
    }
    __block NSURLSessionDataTask *_dataTask = nil;
    _dataTask = [_session dataTaskWithRequest:_request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        completionHandler(data,response,error);
    }];
    
    [_dataTask resume];
}



- (void)showAlertMessage:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void) rightBarButtonItemAction {
    
    [self.amountTextfield resignFirstResponder];
    
}

#pragma mark -- textField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
