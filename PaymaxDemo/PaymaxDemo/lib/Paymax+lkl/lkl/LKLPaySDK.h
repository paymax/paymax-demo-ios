//
//  paySDK.h
//  Demo_1
//
//  Created by Jany on 14-11-22.
//  Copyright (c) 2014年 itazk. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^payResultBlock)(id result);

@interface LKLPaySDK : NSObject
@property(nonatomic,copy) payResultBlock payResultBlock;
@property(nonatomic,copy) UIViewController *myController;

+(void)sendPayMessageOfApp:(NSDictionary*)messageDic andTarget:(UIViewController*)target withPayResultBlock:(payResultBlock)payResultBlock;
@end
