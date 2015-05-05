//
//  IDPAFRequestManager.m
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/3.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "IDPAFRequestManager.h"

@implementation IDPAFRequestManager


NSString * const kHCBaseURLString = @"http://www.baidu.com";  // 服务器base url

+ (IDPAFRequestManager *)sharedInstance
{
    static IDPAFRequestManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [self init];
    });
    
    return _sharedInstance;
}



- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.cmds = [NSMutableArray array];
    //申明返回的结果是JSON类型
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //如果报接受类型不一致请替换一致text/html
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //清求时间设置
    self.requestSerializer.timeoutInterval = 10;
    
    //设置代理
    //[self setProxy];
    
    //添加header头信息
    [self addRequstHeader];
    
    return self;
}


-(id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:kHCBaseURLString]];
    if (!self)
    {
        return nil;
    }
    
    self.cmds = [NSMutableArray array];
    //申明返回的结果是JSON类型
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //如果报接受类型不一致请替换一致text/html
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //清求时间设置
    self.requestSerializer.timeoutInterval = 15;
    
    //设置代理
    //[self setProxy];
    
    //添加header头信息
    [self addRequstHeader];
    
    return self;
}


- (void)addRequstHeader
{
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"enctype"];
}

- (void)enqueueCmd:(IDPAFHttpCmd *)cmd
{
    [self.cmds addObject:cmd];
}

- (void)dequeueCmd:(IDPAFHttpCmd *)cmd
{
    [self performSelector:@selector(delayDequeue:) withObject:cmd afterDelay:1];
}

- (void)delayDequeue:(IDPAFHttpCmd *)cmd
{
    
    [self.cmds removeObject:cmd];
}

- (void)enqueueHTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                           cmd:(IDPAFHttpCmd*)cmd
                                          view:(UIView *)view
                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:urlRequest success:success failure:failure];
    [self.operationQueue addOperation:operation];
}

- (void)requestWithCmd:(IDPAFHttpCmd *)cmd
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:cmd.method path:cmd.path parameters:cmd.queries];
    
    if(cmd.headers)
    {
        NSArray *keys = cmd.headers.allKeys;
        for(NSString *key in keys)
        {
            [request addValue:[cmd.headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSData *data = cmd.data;
    [request setHTTPBody:data];
    
    [self enqueueHTTPRequestOperationWithRequest:request cmd:cmd view:nil success:success failure:failure];
}


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    if (!path) {
        path = @"";
    }
    path =[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
    NSURLRequestCachePolicy cachePolicy = NSURLRequestUseProtocolCachePolicy;
    //    if (urlModule == LTURLModule_Get_TimeStamp) {
    cachePolicy = NSURLRequestReloadIgnoringCacheData;
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:url cachePolicy:cachePolicy timeoutInterval:self.requestSerializer.timeoutInterval];
    [request setHTTPMethod:method];
    [request setAllHTTPHeaderFields:self.requestSerializer.HTTPRequestHeaders];
    return request;
}

- (BOOL)processCommand:(IDPAFHttpCmd *)cmd
{
    if(!cmd)
        return NO;
    
    [self enqueueCmd:cmd];
    
    [self requestWithCmd:cmd success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [cmd didSuccess:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [cmd performSelectorOnMainThread:@selector(didFailed:) withObject:operation.responseObject waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(dequeueCmd:) withObject:cmd waitUntilDone:NO];
    }];
    
    return YES;
}





- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        timeOut:(float)time
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    request.timeoutInterval = time;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         timeOut:(float)time
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    request.timeoutInterval = time;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
            tag:(NSInteger)tag
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    //    NSLog(@"=== %@", request.URL.absoluteString);
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
//    operation.tag = tag;
    [self.operationQueue addOperation:operation];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
             tag:(NSInteger)tag
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
//    operation.tag = tag;
    [self.operationQueue addOperation:operation];
}




@end
