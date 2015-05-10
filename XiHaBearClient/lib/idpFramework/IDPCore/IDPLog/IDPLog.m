//
//  IDPLog.m
//  IDP
//
//  Created by zhangdongjin on 13-3-5.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDPLog.h"

/*
    Debug编译模式下的WF处理
    warning、fatal 下抛异常
 */
void __IDPLogHandleWF_Debug(__IDPLogLevel log_level,
                            const char *file_full_name,
                            int line,
                            const char *method_full_name,
                            int error_no,
                            NSString *user_msg)
{
    // TODO: 可配置是否抛异常
    BOOL raise_exception_on_fatal = YES;
    BOOL raise_exception_on_warning = NO;

    if ((log_level == __IDP_LOG_LEVEL_FATAL && raise_exception_on_fatal) ||
        (log_level == __IDP_LOG_LEVEL_WARNING && raise_exception_on_warning)) {
        NSDictionary *user_info = @{
                                    @"file": [NSString stringWithUTF8String:file_full_name],
                                    @"line": [NSNumber numberWithInt:line],
                                    @"method":[NSString stringWithUTF8String:method_full_name],
                                    @"error_no": [NSNumber numberWithInt:error_no],
                                    @"user_msg": user_msg
                                    };
        NSException* exception = [NSException
                                  exceptionWithName:@"IDP_WF"
                                  reason:user_msg
                                  userInfo:user_info];
        [exception raise];
    }
}


/*
    Release编译模式下的WF处理
 */
void __IDPLogHandleWF_Release(__IDPLogLevel log_level,
                              const char *file_full_name,
                              int line,
                              const char *method_full_name,
                              int error_no,
                              NSString *user_msg)
{
    // TODO: WARNING自动回传消息和堆栈、FATAL抛异常并自动回传消息和堆栈
}
