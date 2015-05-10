//
//  UIAlertView+NoDelegate.m
//  IDP
//
//  Created by zhangdongjin on 13-2-26.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import "UIAlertView+IDPDelegateFree.h"

/*
 * 仅供内部使用，取代UIAlertView并作为自身的Delegate
 */
@interface  __AlertViewNoDelegate: UIAlertView <UIAlertViewDelegate>
@property (nonatomic, copy) IDPUIAlertViewOnDismiss onDismiss;
@end

@implementation __AlertViewNoDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.onDismiss) {
        self.onDismiss(alertView, buttonIndex);
    }
}

- (void)dealloc
{
    self.onDismiss = nil;
    [super dealloc];
}

@end


@implementation UIAlertView (IDPDelegateFree)

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
            onDismiss:(void(^)())onDismiss
{
    [UIAlertView showWithTitle:title
                       message:message
           buttonsAndOnDismiss:@"确定", ^(UIAlertView *alertView, NSInteger index){
               if (onDismiss) {
                   onDismiss();
               }
           }];
}


+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
                delay:(float)delayInSeconds
            onDismiss:(void(^)())onDismiss
{
    // 0.0代表默认延时，即2s
    if (delayInSeconds <= 0.0) {
        delayInSeconds = 2.0;
    }

    // 展示一个无按钮的消息框
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [alert show];

    // 延时关闭消息框，并执行用户自定义操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*delayInSeconds), dispatch_get_main_queue(),
                   ^{
                       // 自动被block retain
                       [alert dismissWithClickedButtonIndex:0 animated:YES];
                       // 允许为nil
                       if (onDismiss) {
                           onDismiss();
                       }
                   });

    [alert release];
}


+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
  buttonsAndOnDismiss:(NSString *)cancelButtonTitle, ...
{
    va_list args;
    id arg = nil;
    IDPUIAlertViewOnDismiss onDismiss = nil;

    __AlertViewNoDelegate *alert = [[__AlertViewNoDelegate alloc] initWithTitle:title
                                                                        message:message
                                                                       delegate:nil
                                                              cancelButtonTitle:cancelButtonTitle
                                                              otherButtonTitles:nil];

    // 扫描参数列表
    va_start(args, cancelButtonTitle);
    while ((arg = va_arg(args, id))) {
        if ([arg isKindOfClass:[NSString class]]) {
            [alert addButtonWithTitle:arg];
        }
        else {
            // block 结尾
            onDismiss = arg;
            break;
        }
    }
    va_end(args);

    // 设置回调
    if (onDismiss) {
        // copy
        alert.onDismiss = onDismiss;
        // 弱引用
        alert.delegate = alert;
    }

    [alert show];
    [alert release];
}

/* 已淘汰 */
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
         button1Title:(NSString *)button1Title
         button2Title:(NSString *)button2Title
            onDismiss:(IDPUIAlertViewOnDismiss)onDismiss
{
    __AlertViewNoDelegate *alert = [[__AlertViewNoDelegate alloc] initWithTitle:title
                                                              message:message
                                                             delegate:nil
                                                    cancelButtonTitle:cancelButtonTitle
                                                    otherButtonTitles:button1Title,button2Title, nil];
    if (onDismiss) {
        alert.onDismiss = onDismiss;
        // 弱引用
        alert.delegate = alert;
    }

    [alert show];
    [alert release];
}

@end
