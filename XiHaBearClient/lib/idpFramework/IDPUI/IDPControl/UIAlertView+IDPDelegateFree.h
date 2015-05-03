//
//  UIAlertView+NoDelegate.h
//  IDP
//
//  Created by zhangdongjin on 13-2-26.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

// 用户传入的回调，处理消息框关闭事件
typedef void (^IDPUIAlertViewOnDismiss)(UIAlertView *alertView, NSInteger index);

@interface UIAlertView (IDPDelegateFree)

/*
 * 展示一个消息框，只有“确定”按钮，并执行回调
 *
 * @prama onDismiss: 回调block，可以为nil
 */
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
            onDismiss:(void(^)())onDismiss;


/*
 * 展示一个无按钮消息框，自动延时关闭，并执行回调
 *
 * @prama delay: 秒计的延时，0或负时表示默认延时2s
 * @prama onDismiss: 回调block，可以为nil
 */
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
                delay:(float)delayInSeconds
            onDismiss:(void(^)())onDismiss;
    

/*
 * 展示一个消息框，关闭时执行回调
 *
 * @prama ...: 变长参数，0~N个字符串加一个结束符（nil或block），block类型为UIAlertViewOnDismiss
 */
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
  buttonsAndOnDismiss:(NSString *)cancelButtonTitle, ...;

/*
 * 展示一个消息框，关闭时执行回调
 *
 * @prama ...: 三个参数
 */
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
         button1Title:(NSString *)button1Title
         button2Title:(NSString *)button2Title
            onDismiss:(IDPUIAlertViewOnDismiss)onDismiss;

@end
