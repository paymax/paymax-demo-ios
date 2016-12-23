//
//  FaceDecoSDK.h
//  FaceDetect
//
//  Created by shunweiwuxian on 16/8/4.
//  Copyright © 2016年 shunweiwuxian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceRecoSDK : NSObject
typedef NS_ENUM(NSInteger, DetectResult) {
    DetectResult_LiveCancel,// 默认从0开始, 取消活体检测
    DetectResult_LiveFail,   // 活体检测失败
    DetectResult_ACCORDANCE, // 人脸识别一致
    DetectResult_INCONFORMITY, // 人脸识别不一致
    DetectResult_VERIFY_FAILED, // 签名校验失败
    DetectResult_REQUEST_TIMESTAMP_EXPIRE,// 时间戳过期或超前
    DetectResult_ILLEGAL_REQUEST_BODY, // 请求参数不合法
    DetectResult_ILLEGAL_ARGUMENT, // 非法参数
    DetectResult_ILLEGAL_DATA, // 请求数据非法
    DetectResult_IDCARDNO_ERROR, // 身份证号码不正确
    DetectResult_REALNME_IDCARD_NOT_SAME, // 姓名身份证不匹配
    DetectResult_NetworkError // 网络请求错误
};
/**
 *  活体检测接口
 *
 *  @param controller  需要弹出活体检测控制器，如果是当前控制器则为self
 *  @param name        姓名
 *  @param idCardNo    身份证号
 *  @param secretKey   商户secretKey
 *  @param resultBlock 活体检测和人脸识别接口
 */
+(void)startFaceRecoWithViewController:(UIViewController *) controller
                          Name:(NSString *)name
                          IdCardNo:(NSString *)idCardNo
                          UserId:(NSString *)userId
                          SecretKey:(NSString *)secretKey
                          resultBlock:(void(^)(DetectResult result))resultBlock;
@end
