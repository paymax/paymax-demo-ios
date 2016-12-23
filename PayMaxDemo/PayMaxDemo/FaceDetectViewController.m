//
//  FaceDetectViewController.m
//  PaymaxDemo
//
//  Created by William on 16/8/12.
//  Copyright © 2016年 顺维无限. All rights reserved.
//

#import "FaceDetectViewController.h"
#import "FaceRecoSDK.h"
#import "PaymaxSDK.h"
@interface FaceDetectViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *idCardTextField;

@end

@implementation FaceDetectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)faceDetectAction:(UIButton *)sender {
    [self.view resignFirstResponder];
    if (_nameTextField.text.length==0 &&_idCardTextField.text.length==0) {
        [self showAlertMessage:@"请填写姓名和身份证"];
        return;
    }

    
    [FaceRecoSDK startFaceRecoWithViewController:self Name:self.nameTextField.text IdCardNo:self.idCardTextField.text UserId:self.userid SecretKey:@"e61489f3135f4bb09cbb54eeac70cc52" resultBlock:^(DetectResult result) {
        
        switch (result) {
            case DetectResult_LiveCancel:
                [self showAlertMessage:@"活体检测取消"];
                break;
            case DetectResult_LiveFail:
                [self showAlertMessage:@"活体检测失败"];
                break;
            case DetectResult_ACCORDANCE:
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification
                                                                        notificationWithName:@"PlaceOrder"
                                                                        object:nil userInfo:nil]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
