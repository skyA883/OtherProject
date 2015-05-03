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
        _sharedInstance = [self manager];
    });
    
    return _sharedInstance;
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
    self.requestSerializer.timeoutInterval = 30;
    
    //设置代理
    //[self setProxy];
    
    //添加header头信息
    [self addRequstHeader];
    
    return self;
}


- (void)addRequstHeader
{
    
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
                                       success:(void (^)(id object))success
                                       failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure
{
    void (^_success)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        id object = JSON;
        
        if(success)
            success(object);
    };
    void (^_failure)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if(failure)
            failure(response, error);
    };
    /*
    AFHTTPRequestOperation *operation = nil;
    operation = [AFHTTPRequestOperation JSONRequestOperationWithRequest:urlRequest
                                                                success:_success
                                                                failure:_failure];
    [self enqueueHTTPRequestOperation:operation];
     */
    
}

- (void)requestWithCmd:(IDPAFHttpCmd *)cmd
               success:(void (^)(id object))success
               failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure
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
    /*
    if ([method isEqualToString:@"POST"])
        self.parameterEncoding = AFFormURLParameterEncoding;
    else
        self.parameterEncoding = AFJSONParameterEncoding;
    
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    
    return request;
     */
    return nil;
}

- (BOOL)processCommand:(IDPAFHttpCmd *)cmd
{
    if(!cmd)
        return NO;
    
    [self enqueueCmd:cmd];
    
    [self requestWithCmd:cmd success:^(id object) {
        [cmd didSuccess:object];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        [cmd performSelectorOnMainThread:@selector(didFailed:) withObject:response waitUntilDone:YES];
        
        [self performSelectorOnMainThread:@selector(dequeueCmd:) withObject:cmd waitUntilDone:NO];
    }];
    
    return YES;
}


@end
