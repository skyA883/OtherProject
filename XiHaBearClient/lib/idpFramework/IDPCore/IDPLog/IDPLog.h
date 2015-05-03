//
//  IDPLog.h
//  IDP
//
//  Created by zhangdongjin on 13-3-5.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <string.h>
#import <libgen.h>
#import <Foundation/Foundation.h>

// 4个宏，分别打印四种级别的日志
#ifdef DEBUG

// DEBUG级别日志
#define IDPLogDebug(fmt...) \
__IDPLog(__IDP_LOG_LEVEL_DEBUG, __FILE__, __LINE__, __func__, 0, [NSString stringWithFormat:fmt])

// TRACE级别日志
#define IDPLogTrace(fmt...) \
__IDPLog(__IDP_LOG_LEVEL_TRACE, __FILE__, __LINE__, __func__, 0, [NSString stringWithFormat:fmt])

#else

// release模式下关闭DEBUG和TRACE
#define IDPLogDebug(fmt...) do{}while(0)
#define IDPLogTrace(fmt...) do{}while(0)

#endif

// WARNING级别日志，错误码留作后用
#define IDPLogWarning(error_no, fmt...) \
__IDPLog(__IDP_LOG_LEVEL_WARNING, __FILE__, __LINE__, __func__, error_no, [NSString stringWithFormat:fmt])

// FATAL级别日志，错误码留作后用
#define IDPLogFatal(error_no, fmt...) \
__IDPLog(__IDP_LOG_LEVEL_FATAL, __FILE__, __LINE__, __func__, error_no, [NSString stringWithFormat:fmt])


////////////////// 以下仅供内部使用 //////////////////

typedef enum {
    __IDP_LOG_LEVEL_DEBUG = 0,
    __IDP_LOG_LEVEL_TRACE,
    __IDP_LOG_LEVEL_WARNING,
    __IDP_LOG_LEVEL_FATAL,
} __IDPLogLevel;

void __IDPLogHandleWF_Debug(__IDPLogLevel log_level,
                            const char *file_full_name,
                            int line,
                            const char *method_full_name,
                            int error_no,
                            NSString *user_msg);

void __IDPLogHandleWF_Release(__IDPLogLevel log_level,
                              const char *file_full_name,
                              int line,
                              const char *method_full_name,
                              int error_no,
                              NSString *user_msg);


// 不应直接调用，放这里只是为了性能
static inline void __IDPLog(__IDPLogLevel log_level,
                            const char *file_full_name,
                            int line,
                            const char *method_full_name,
                            int error_no,
                            NSString *user_msg)
{
    static const char * IDPLogLevelString[] = {
        "DEBUG",
        "TRACE",
        "WARNI",
        "FATAL",
    };

    // basename不可重入，且性能不好
    const char *file_name;
    if((file_name = strrchr(file_full_name, '/'))) {
        ++file_name;
    } else {
        file_name = file_full_name;
    }

    if (log_level < __IDP_LOG_LEVEL_WARNING) {
        NSLog(@"%s [%s:%d %s] %@",
              IDPLogLevelString[log_level], file_name, line, method_full_name, user_msg);
    } else {
        NSLog(@"%s [%s:%d %s] [err:%d] %@",
              IDPLogLevelString[log_level], file_name, line, method_full_name, error_no, user_msg);
    }

    /*
    // 判断是否objc方法
    if (method_full_name[0] == '-' && method_full_name[1] == '[') {
        NSLog(@"%s [%s:%d] %s %@",
              IDPLogLevelString[log_level], file_name, line, method_full_name+1, user_msg);
    } else {
        NSLog(@"%s [%s:%d] [%s] %@",
              IDPLogLevelString[log_level], file_name, line, method_full_name, user_msg);
    }
     */
    
    // 处理warning和fatal
    if (log_level >= __IDP_LOG_LEVEL_WARNING) {
#ifdef DEBUG
        __IDPLogHandleWF_Debug(log_level, file_full_name, line, method_full_name, error_no, user_msg);
#else
        __IDPLogHandleWF_Release(log_level, file_full_name, line, method_full_name, error_no, user_msg);
#endif
    }
}




#if 0
const char *class_name = NULL;
const char *method_name = NULL;
char method_buff[255];

// 解析出类名和方法名
// objc方法：解析出类名和方法名
if (method_full_name[0] == '-' && method_full_name[1] == '[') {
    strncpy(method_buff, method_full_name+2, sizeof(method_buff));
    class_name = method_buff;
    method_name = strchr(method_buff, ' ');
    *(char*)method_name = 0;
    ++method_name;
    ((char*)method_name)[strlen(method_name) - 1] = 0;
} else {
    // c函数或block：只有函数名
    method_name = method_full_name;
}

if (class_name) {
    NSLog(@"%s: [%s:%d] [%s::%s] %@",
          IDPLogLevelString[log_level], file_name, line, class_name, method_name, user_msg);
} else {
    NSLog(@"%s: [%s:%d] [%s] %@",
          IDPLogLevelString[log_level], file_name, line, method_name, user_msg);
}
#endif
