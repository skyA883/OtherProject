//
//  IDPAFHttpCmd.h
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/3.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HCHttpCmdSuccess)(id object);
typedef void (^HCHttpCmdFailed)(AFHTTPRequestOperation *response);

@interface IDPAFHttpCmd : NSObject

@property (nonatomic,copy) HCHttpCmdSuccess success;
@property (nonatomic,copy) HCHttpCmdFailed fail;
+ (id)cmd;
- (NSString *)method; // 请求方式，"GET" or "POST"
- (NSString *)path;   // 请求对应接口的文件在服务器上的位置，如"www.baidu.com/index"中的"index"
- (NSDictionary *)headers; // 请求的header
- (NSDictionary *)queries; // "GET"请求的参数，如"www.baidu.com/index？var=123"中的var=123
- (NSData *)data;
- (void)didSuccess:(id)object;  // 请求成功的回调
- (void)didFailed:(AFHTTPRequestOperation *)response;// 请求失败的回调


@end
