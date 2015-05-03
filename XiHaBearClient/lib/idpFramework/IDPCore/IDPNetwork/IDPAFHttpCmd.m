//
//  IDPAFHttpCmd.m
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/3.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "IDPAFHttpCmd.h"

@implementation IDPAFHttpCmd


+ (id)cmd
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

-(NSString *)method
{
    return @"GET";
}

-(NSString *)path
{
    return @"index";
}

- (NSDictionary *)headers
{
    return nil;
}

- (NSDictionary *)queries
{
    return nil;
}

- (NSData *)data
{
    return nil;
}

- (void)didSuccess:(id)object
{
    if( _success)
    {
        _success(object);
    }
}

- (void)didFailed:(AFHTTPRequestOperation *)response
{
    if( _fail)
    {
        _fail(response);
    }
}


@end
