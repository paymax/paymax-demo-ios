//
//  ViewController.m
//  PaymaxDemo
//
//  Created by William on 16/5/17.
//  Copyright © 2016年 顺维无限. All rights reserved.
//

#import "ViewController.h"
#import "PaymaxSDK.h"
#import <PassKit/PassKit.h>

#define K_APPP_SCHEME @"wx5269eef08886e3d5"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *rootTableView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *tableFooterView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *backgroundActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *urlStatusLabel;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (copy, nonatomic) NSString *urlString;
@property (copy, nonatomic) NSString *channel;
@property (assign, nonatomic) NSInteger selectrow;
@property (strong, nonatomic) UITextField *amountTextfield;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setData];
}

- (void)setData {
    
    self.title = @"PaymaxDemo";
    self.backgroundView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.2];
    self.rootTableView.tableFooterView = self.tableFooterView;
    self.channel = @"alipay_app";
    self.urlString = @"";
    self.userIDTextField.delegate= self;
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
- (IBAction)payClick:(UIButton *)sender {
    
    
    [self.backgroundView setHidden:NO];
    [self.backgroundActivityIndicatorView startAnimating];
    NSString *userId = self.userIDTextField.text !=nil ? self.userIDTextField.text : @"99999999";
    NSDictionary* dict = @{
                           @"channel"     : self.channel,
                           @"totalPrice"  : self.amountTextfield.text,
                           @"title"       : @"subject",
                           @"body"        : @"test",
                           @"extra"       : @{@"user_id":userId}
                           };
    
    //网络请求，可根据本身情况更换，比如AFNetworking
    NSURLSession *_session = [NSURLSession sharedSession];
    NSURL *_url = [NSURL URLWithString:self.self.urlString];
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] initWithURL:_url];
    [_request setHTTPMethod:@"POST"];
    [_request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSData* _data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *_bodyData = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    [_request setHTTPBody:[NSData dataWithBytes:[_bodyData UTF8String] length:strlen([_bodyData UTF8String])]];
    __block NSURLSessionDataTask *_dataTask = nil;
    _dataTask = [_session dataTaskWithRequest:_request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *responseObject;
        
        if (data != nil)
        {
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
        }else
        {
            responseObject = nil;
        }
        
        if (error)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.backgroundView setHidden:YES];
                [self.backgroundActivityIndicatorView stopAnimating];
                [self showAlertMessage:[NSString stringWithFormat:@"%@",error.localizedDescription]];
            });
            
        }else
        {
            NSLog(@"responseObject-------%@",responseObject);
            dispatch_sync(dispatch_get_main_queue(), ^(){
                
                if (responseObject == nil) {
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
                      completion:^(PaymaxBack *paymaxBack) {
                         
                          switch (paymaxBack.explain) {
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
                                  [self showAlertMessage:@"渠道信息错误"];
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
                          NSLog(@"paymaxBack.channelBackCode=%@\npaymaxBack.channel=%@\npaymaxBack.backDescription=%@\npaymaxBack.prCode=%ld",paymaxBack.channelBackCode,paymaxBack.channel,paymaxBack.backDescription,(long)paymaxBack.prCode);
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
