//
//  IDPServerAPI.h
//
//  描述服务器API的抽象类
//
//  Created by zhangdongjin on 13-3-13.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDPHttpRequest.h"

// 默认网络超时
#define IDP_API_DEFAULT_TIMEOUT_S       20.0f
// 调用失败时发送的全局通知
#define IDPServerAPIFailedNotification  @"IDPServerAPIFailedNotification"
// IDPServerAPI的error domain
#define IDPServerAPIErrorDomain         @"com.idp.serverapi"


// API访问的处理状态，IDPServerAPI.state
typedef enum {
    IDP_PROC_STAT_CREATED = 0,
    IDP_PROC_STAT_LOADING,
    IDP_PROC_STAT_SUCCEED,
    IDP_PROC_STAT_FAILED,
    IDP_PROC_STAT_CANCELLED
} IDPProcessStateEnum;

// API访问错误类型，IDPServerAPI.error.code
typedef enum {
    IDP_E_SUCCEED = 0,      // 成功
    IDP_E_NETWORK_ERROR,    // 网络异常
    IDP_E_DATA_FORMAT_ERROR,// 返回数据格式不对，如空数据、非法json等
    IDP_E_SERVER_ERROR,     // 服务器返回了异常信息
} IDPErrorEnum;

@class IDPServerAPI;

// 用于serverapi回调的block定义
typedef void(^IDPServerAPICompletionBlock)(IDPServerAPI*);


@interface IDPServerAPI : NSObject

// backend
@property (nonatomic, retain) IDPHttpRequest *httpClient;

// req
@property (nonatomic, readonly) NSString *server;
@property (nonatomic, copy) NSString *api;
@property (nonatomic, readonly) NSTimeInterval timeout_s;
@property (nonatomic, readonly) NSDictionary *reqParams;
@property (nonatomic, readonly) NSDictionary *files;
@property (nonatomic, copy) IDPServerAPICompletionBlock userBlock;

// res
@property (nonatomic, retain) NSError *error; // code为IDPErrorEnum类型，服务器返回存放在userInfo的errno和errmsg里
@property (nonatomic, retain) NSDictionary *parsedData; // 解析出的JSON
@property (nonatomic, retain) NSData *rawData;          // 原始data，用于二进制结果
@property (nonatomic, readonly) NSString *rawString;    // 原始字符串，用于文本结果，lazyloading

// state
@property (nonatomic, assign) IDPProcessStateEnum state;

// 性能信息
@property (nonatomic, readonly) CFTimeInterval startTime;   // 请求发起时间
@property (nonatomic, readonly) CFTimeInterval netCost;     // 网络耗时
@property (nonatomic, readonly) CFTimeInterval parseCost;   // 结果解析耗时
@property (nonatomic, readonly) CFTimeInterval totalCost;   // 总耗时，netCost+parseCost


// server 形如 www.address.of.api，可兼容前面带“http://”、以及后面带“/”的情况
- (id)initWithServer:(NSString *)server timeout:(NSTimeInterval)timeout_s;

// 访问API，子类不需要重载
// api 形如 /some/api/to/access，可兼容前面不带“/”的情况
// 本方法可重复调用，会自动中止当前请求（但并不调用用户回调）
// 回调调用时机：请求失败、请求被中止、请求成功
// 回调一般是根据state访问error或者parsedData，并关掉菊花
- (BOOL)accessAPI:(NSString *)api
       WithParams:(NSDictionary *)params
            files:(NSDictionary *)files
  completionBlock:(IDPServerAPICompletionBlock)block;
- (BOOL)accessAPIForGet:(NSString *)api
             WithParams:(NSDictionary *)params
                  files:(NSDictionary *)files
        completionBlock:(IDPServerAPICompletionBlock)block;

- (BOOL)getAPI:(NSString *)api
    WithParams:(NSDictionary *)params
completionBlock:(IDPServerAPICompletionBlock)block;

// 中止当前请求，子类不需要重载
- (void)cancel;

// 刷新上次请求，子类不需要重载
// 本方法可重复调用，会自动中止当前请求（但并不调用用户回调）
- (BOOL)refresh;

@end

// 子类需要重载的方法
// 不重载的话，父类只是个通用的HTTP-POST客户端
@interface IDPServerAPI (subclass)

// 作用：子类可在此增加附加请求参数、也可修改用户传入参数
// 注意：需要返回增加了附加参数后的全部参数
// 时机：父类在发起请求前调用
- (NSDictionary *)addExtraParams;

// 作用：子类可在此进行结果解析操作，也可进行性能统计等其他工作
// 时机：父类在执行用户回调前调用
- (void)parseBody;

@end
