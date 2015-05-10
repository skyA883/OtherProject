//
//  TBCAPI.m
//  Pickers
//
//  Created by zhangdongjin on 13-3-13.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import "IDPServerAPI.h"
#import "IDPLog.h"
#import "NSData+IDPExtension.h"

@interface IDPServerAPI()

@property (nonatomic, assign) NSTimeInterval timeout_s;
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSDictionary *reqParams;
@property (nonatomic, retain) NSDictionary *files;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) CFTimeInterval netCost;
@property (nonatomic, assign) CFTimeInterval parseCost;
@property (nonatomic, assign) CFTimeInterval totalCost;

@end


@implementation IDPServerAPI

@synthesize rawString = _rawString;

- (id)initWithServer:(NSString *)server timeout:(NSTimeInterval)timeout_s {
    if (self = [super init]) {
        if (![server hasPrefix:@"http://"]) {
            server = [@"http://" stringByAppendingString:server];
        }
        if ([server hasSuffix:@"/"]) {
            server = [server substringToIndex:server.length - 1];
        }
        self.server = server;
        self.timeout_s = timeout_s > 0?timeout_s:IDP_API_DEFAULT_TIMEOUT_S;
    }
    return self;
}

- (BOOL)accessAPI:(NSString *)api
       WithParams:(NSDictionary *)params
            files:(NSDictionary *)files
  completionBlock:(IDPServerAPICompletionBlock)block
{
    IDPLogDebug(@"");
    self.startTime = CFAbsoluteTimeGetCurrent();
    self.netCost = 0;
    self.parseCost = 0;
    self.totalCost = 0;

    // 先中止当前请求
    if (self.httpClient) {
        [self cancel];
        self.httpClient.responder = nil;
        self.httpClient = nil;
    }
    if(api){
        if (![api hasPrefix:@"http://"]) {
            // 赋值
            if (![api hasPrefix:@"/"]) {
                self.api = [@"/" stringByAppendingString:api];
            } else {
                self.api = api;
            }
        }else {
            NSRange range = [api rangeOfString:@"http://"];
            NSString *subServer = [api substringFromIndex: range.location + range.length];
            NSRange range2 = [subServer rangeOfString:@"/"];
            self.server = [@"http://" stringByAppendingString:[subServer substringToIndex:range2.location]];
            self.api = [subServer substringFromIndex:range2.location];
        }
    }
    
    self.reqParams = params;
    self.files = files;
    self.userBlock = block;

    // 重置状态
    self.state = IDP_PROC_STAT_CREATED;
    self.error = nil;
    self.parsedData = nil;
    self.rawData = nil;
    self.rawString = nil;

    // 增加子类附加参数
    NSDictionary *allParams = [self addExtraParams];

    // 发起请求
    NSString *url = self.server;
    if(api){
        url = [self.server stringByAppendingString:self.api];
    }
    self.httpClient = [self POST:url files:files dict:allParams];
    IDPLogDebug(@"http request started: %@", url);
    return (self.httpClient != nil);
}

- (BOOL)accessAPIForGet:(NSString *)api
       WithParams:(NSDictionary *)params
            files:(NSDictionary *)files
  completionBlock:(IDPServerAPICompletionBlock)block
{
    IDPLogDebug(@"");
    self.startTime = CFAbsoluteTimeGetCurrent();
    self.netCost = 0;
    self.parseCost = 0;
    self.totalCost = 0;
    
    // 先中止当前请求
    if (self.httpClient) {
        [self cancel];
        self.httpClient.responder = nil;
        self.httpClient = nil;
    }
    
    if (![api hasPrefix:@"http://"]) {
        // 赋值
        if (![api hasPrefix:@"/"]) {
            self.api = [@"/" stringByAppendingString:api];
        } else {
            self.api = api;
        }
    }else {
        NSRange range = [api rangeOfString:@"http://"];
        NSString *subServer = [api substringFromIndex: range.location + range.length];
        NSRange range2 = [subServer rangeOfString:@"/"];
        self.server = [@"http://" stringByAppendingString:[subServer substringToIndex:range2.location]];
        self.api = [subServer substringFromIndex:range2.location];
    }
    
    self.reqParams = params;
    self.files = files;
    self.userBlock = block;
    
    // 重置状态
    self.state = IDP_PROC_STAT_CREATED;
    self.error = nil;
    self.parsedData = nil;
    self.rawData = nil;
    self.rawString = nil;
    
    // 增加子类附加参数
    NSDictionary *allParams = [self addExtraParams];
    
    // 发起请求
    NSString *url = [self.server stringByAppendingString:self.api];
    //构建get参数
    NSMutableString* getP = [[NSMutableString alloc] init];
    [getP appendFormat:@"%@?",url];
    NSArray* keyList = [allParams allKeys];
    int index = 0;
    for(NSString* key in keyList){
        [getP appendFormat:@"%@=%@", key, [allParams objectForKey:key]];
        if(index < keyList.count-1){
            [getP appendString:@"&"];
        }
        index++;
    }
    self.httpClient = [self GET:getP];
    IDPLogDebug(@"http GET request started: %@", getP);
    [getP release];
    return (self.httpClient != nil);
}




/**
 * params json数组 post网络请求
 * api   ----- 路径:/c/s?username=xxx&userpassword=xxx&..&..
 * json  ----- 网络请求json 数据 用dict形式给出。
 */
- (BOOL)accessAPI:(NSString *)api
         jsonDict:(NSArray *)json
  completionBlock:(IDPServerAPICompletionBlock)block {
    IDPLogDebug(@"");
    self.startTime = CFAbsoluteTimeGetCurrent();
    self.netCost = 0;
    self.parseCost = 0;
    self.totalCost = 0;
    
    // 先中止当前请求
    if (self.httpClient) {
        [self cancel];
        self.httpClient.responder = nil;
        self.httpClient = nil;
    }
    
    if (![api hasPrefix:@"http://"]) {
        // 赋值
        if (![api hasPrefix:@"/"]) {
            self.api = [@"/" stringByAppendingString:api];
        } else {
            self.api = api;
        }
    }else {
        NSRange range = [api rangeOfString:@"http://"];
        NSString *subServer = [api substringFromIndex: range.location + range.length];
        NSRange range2 = [subServer rangeOfString:@"/"];
        self.server = [@"http://" stringByAppendingString:[subServer substringToIndex:range2.location]];
        self.api = [subServer substringFromIndex:range2.location];
    }
    
    self.userBlock = block;
    
    // 重置状态
    self.state = IDP_PROC_STAT_CREATED;
    self.reqParams = nil;
    self.files = nil;
    self.error = nil;
    self.parsedData = nil;
    self.rawData = nil;
    self.rawString = nil;
    
    // 发起请求
    NSString *url = [self.server stringByAppendingString:self.api];
    self.httpClient = [self POST:url json:json];
    IDPLogDebug(@"http access json request  %@", url);
    return (self.httpClient != nil);
}



- (BOOL)getAPI:(NSString *)api
    WithParams:(NSDictionary *)params
completionBlock:(IDPServerAPICompletionBlock)block {
    IDPLogDebug(@"");
    self.startTime = CFAbsoluteTimeGetCurrent();
    self.netCost = 0;
    self.parseCost = 0;
    self.totalCost = 0;
    
    // 先中止当前请求
    if (self.httpClient) {
        [self cancel];
        self.httpClient.responder = nil;
        self.httpClient = nil;
    }
    
    // 赋值
    if (![api hasPrefix:@"/"]) {
        self.api = [@"/" stringByAppendingString:api];
    } else {
        self.api = api;
    }
    self.reqParams = params;
    self.files = nil;
    self.userBlock = block;
    
    // 重置状态
    self.state = IDP_PROC_STAT_CREATED;
    self.error = nil;
    self.parsedData = nil;
    self.rawData = nil;
    self.rawString = nil;
    
    // 增加子类附加参数
    NSDictionary *allParams = [self addExtraParams];
    //    IDPLogDebug(@"http request allParams: %@", allParams);
    //    NSString *paramUrl = @"?";
    //    for (NSString *key in [allParams allKeys]) {
    //        paramUrl = [paramUrl stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,[allParams objectAtPath:key]]];
    //    }
    // 发起请求
    NSString *url = [self.server stringByAppendingString:self.api];
    url = [url urlByAppendingDict:allParams];
    IDPLogDebug(@"http get request started: %@", url);
    //    url = [url stringByAppendingString:paramUrl];
    //    self.httpClient = [self POST:url files:files dict:allParams];
    self.httpClient = [self GET:url];
    return (self.httpClient != nil);
}


// 中止请求
- (void)cancel {
    if (!self.httpClient) {
        IDPLogDebug(@"httpclient is nil!");
        return;
    }

    if (self.httpClient.state == IDP_REQUEST_STATE_SENDING ||
        self.httpClient.state == IDP_REQUEST_STATE_RECVING) {
        [self.httpClient cancel];
    } else {
        IDPLogDebug(@"httpclient is not cancellable, state = %d", self.httpClient.state);
        return;
    }
}

// 刷新请求
- (BOOL)refresh {
    return [self accessAPI:self.api WithParams:self.reqParams files:self.files completionBlock:self.userBlock];
}

// 这是IDPHttpRequest要求的回调方法，由该类在主线程执行
- (void)handleRequest:(IDPHttpRequest *)request {

    IDPLogDebug(@"state=%d", request.state);
    // 忽略遗老遗少
    if (request != self.httpClient) {
        IDPLogDebug(@"got previous IDPHttpRequest, ignore!");
        return;
    }

    // 根据状态进行不同处理
    switch (request.state) {
        // 失败
        case IDP_REQUEST_STATE_FAILED:
            self.state = IDP_PROC_STAT_FAILED;
            self.error = [NSError errorWithDomain:IDPServerAPIErrorDomain
                                             code:IDP_E_NETWORK_ERROR
                                         userInfo:nil];
            IDPLogWarning(0, @"network error");
            break;

        // 中止
        case IDP_REQUEST_STATE_CANCELLED:
            self.state = IDP_PROC_STAT_CANCELLED;
            break;

        // 成功
        case IDP_REQUEST_STATE_SUCCEED:
            self.state = IDP_PROC_STAT_SUCCEED;
            break;

        // 其他情况不做任何处理
        default:
            return;
    }

    // 计算网络耗时
    self.netCost = CFAbsoluteTimeGetCurrent() - self.startTime;

    // 保存原始body
    self.rawData = self.httpClient.responseData;
    // self.rawString 延时加载，此处不需要处理

    // 解析出parsedData，直接调用子类的方法，这是子类的机会
    [self parseBody];

    // 计算总耗时和解析耗时
    self.totalCost = CFAbsoluteTimeGetCurrent() - self.startTime;
    self.parseCost = self.totalCost - self.netCost;

    // 调用用户回调
    if (self.userBlock) {
        self.userBlock(self);
    }

    // 失败则发送全局通知，供app统一处理一些特定错误
    if (self.state == IDP_PROC_STAT_FAILED) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IDPServerAPIFailedNotification object:self];
    }
}

// 解析 HTTP body，供子类定制
// 子类需要设置error，也可执行诸如隐含登录这样的额外操作
- (void)parseBody {
}

// 添加额外参数
- (NSDictionary *)addExtraParams {
    return self.reqParams;
}

// lazyloading
- (NSString *)rawString {
    if (self->_rawString) {
        return self->_rawString;
    }
    if (self.rawData) {
        self->_rawString = [[self.rawData UTF8String] copy];
    }
    return self->_rawString;
}

- (void)setRawString:(NSString *)rawString {
    if (self->_rawString == rawString) {
        return;
    }

    if (self->_rawString) {
        [self->_rawString release];
    }
    self->_rawString = [rawString copy];
}


- (NSString *)curRequestUrl
{
    // 增加子类附加参数
    NSDictionary *allParams = [self addExtraParams];
    
    // 发起请求
    NSString *url = self.server;
    if(self.api){
        url = [self.server stringByAppendingString:self.api];
    }
    NSString *rstUrl = [url urlByAppendingDict:allParams];
    return rstUrl;
}


- (void)dealloc {
    // 先中止当前请求
    if (self.httpClient) {
        [self cancel];
        self.httpClient.responder = nil;
        self.httpClient = nil;
    }
    self.api = nil;
    self.server = nil;
    self.reqParams = nil;
    self.files = nil;
    self.userBlock = nil;
    self.error = nil;
    self.parsedData = nil;
    self.rawData = nil;
    self.rawString = nil;
    [super dealloc];
}

@end
