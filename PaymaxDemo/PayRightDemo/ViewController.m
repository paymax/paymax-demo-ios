//
//  ViewController.m
//  PayRightSDK
//
//  Created by zhulebei on 16/3/2.
//  Copyright © 2016年 shunweiwuxian. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>
#import <UIKit/UIKit.h>
#import "PayRightSDK.h"
#define kappScheme @"wx5269eef08886e3d5"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *rootTableView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) UITextField *amountTextfield;
@property (assign, nonatomic) NSInteger selectrow;
@property (copy, nonatomic) NSString *channel;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bgActivity;
@property (copy, nonatomic) NSString *_url;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PayRightDemo";
    self.bgView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.2];
    self.rootTableView.tableFooterView = self.footerView;
    self.channel = @"alipay_app";
    self._url = @"";
    self.statusLabel.text = @"当前是开发环境";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return 1;
            break;
        default:
            return 2;
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
                    _label.text = @"支付宝支付";
                    break;
                case 1:
                    _imageView.image = [UIImage imageNamed:@"weixin"];
                    _label.text = @"微信支付";
                    break;
                default:
                    _imageView.image = [UIImage imageNamed:@"apple"];
                    _label.text = @"Apple Pay";
                    CGRect frame = _imageView.frame;
                    frame.size.width = 1;
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
            self.channel = @"applepay";
            break;
    }
    [tableView reloadData];
    
}
- (IBAction)testAction:(id)sender {
    
    self._url = @"";
    self.statusLabel.text = @"当前是测试环境";
}
- (IBAction)developerAction:(id)sender {
   
    self._url = @"";
    self.statusLabel.text = @"当前是开发环境";
}

- (IBAction)payAction:(UIButton *)sender {
    
    self.bgView.hidden = NO;
    [self.bgActivity startAnimating];
    
    NSDictionary* dict = @{
                           @"channel"     : self.channel,
                           @"totalPrice"  : self.amountTextfield.text,
                           @"title"       : @"subject",
                           @"body"        : @"test"
                           };
    //网络请求，可根据本身情况更换，比如AFNetworking
    NSURLSession *_session = [NSURLSession sharedSession];
    NSURL *_url = [NSURL URLWithString:self._url];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:_url];
    _request.HTTPMethod = @"POST";
    [_request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSData* _data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *_bodyData = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    [_request setHTTPBody:[NSData dataWithBytes:[_bodyData UTF8String] length:strlen([_bodyData UTF8String])]];
    __block NSURLSessionDataTask *_dataTask = nil;
    _dataTask = [_session dataTaskWithRequest:_request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *responseObject;
        
        if (data != nil) {
           
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        }else {
            
            responseObject = nil;
        }
      
        if (error) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                self.bgView.hidden = YES;
                [self.bgActivity stopAnimating];
                [self showAlertMessage:[NSString stringWithFormat:@"%@",error.localizedDescription]];
            });
            
        }else{
            
            NSLog(@"responseObject-------%@",responseObject);
            dispatch_sync(dispatch_get_main_queue(), ^(){
                
                if (responseObject == nil) {
                    [self showAlertMessage:[NSString stringWithFormat:@"%@",response]];
                }
                
                self.bgView.hidden = YES;
                [self.bgActivity stopAnimating];
                [PayRightSDK pay:responseObject
                       appScheme:kappScheme
                      completion:^(PayRightBack *payRightBack) {
                          
                          switch (payRightBack.explain) {
                              case PayRight_CODE_SUCCESS:
                                  [self showAlertMessage:@"成功"];
                                  break;
                              case PayRight_CODE_FAIL_CANCEL:
                                  [self showAlertMessage:@"用户取消支付"];
                                  break;
                              case PayRight_CODE_ERROR_DEAL:
                                  [self showAlertMessage:@"处理中"];
                                  break;
                              case PayRight_CODE_Failure:
                                  [self showAlertMessage:@"支付失败"];
                                  break;
                              case PayRight_CODE_ERROR_CONNECT:
                                  [self showAlertMessage:@"网络错误"];
                                  break;
                              case PayRight_CODE_ChannelWrong:
                                  [self showAlertMessage:@"渠道信息错误"];
                                  break;
                              case PayRight_CODE_ERROR_CHARGE_PARAMETER:
                                  [self showAlertMessage:@"参数信息错误"];
                                  break;
                              case PayRight_CODE_ERROR_WX_NOT_INSTALL:
                                  [self showAlertMessage:@"未安装微信"];
                                  break;
                              case PayRight_CODE_ERROR_WX_NOT_SUPPORT_PAY:
                                  [self showAlertMessage:@"微信不支持"];
                                  break;
                              case PayRight_CODE_ERROR_WX_UNKNOW:
                                  [self showAlertMessage:@"微信未知错误"];
                                  break;
                          }
                          
                          NSLog(@"payRightBack.channelBackCode=%@\npayRightBack.channel=%@\npayRightBack.backDescription=%@\npayRightBack.prCode=%ld",payRightBack.channelBackCode,payRightBack.channel,payRightBack.backDescription,(long)payRightBack.prCode);
                }];
                
            });
        
        }
    }];
    
    [_dataTask resume];
}

- (void)showAlertMessage:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
