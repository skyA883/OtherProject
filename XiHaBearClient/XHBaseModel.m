//
//  XHBaseModel.m
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/2.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "XHBaseModel.h"
#import <objc/runtime.h>

@implementation XHBaseModel


- (id)init
{
    if (self = [super init])
    {
        self.serverApi = [[TBCServerAPI alloc] initWithServer:XH_SERVER_HOST timeout:-1];
        //缓存命名空间为类的命名空间
        self.idpCache = [[IDPCache alloc] initWithNameSpace:[NSString stringWithUTF8String:class_getName([self class])]  storagePolicy:IDPCacheStorageDisk];
    }
    return self;
}

- (void)dealloc
{
    //先停止网络请求
    [self cancel];
    self.completionBlock = nil;
    self.serverApi = nil;
    self.params = nil;
    self.address = nil;
    self.idpCache = nil;
}


//设置到缓存
-(void)setCacheItems:(XHBaseItem*)item key:(NSString*)key
{
    [self.idpCache setObj:item forKey:key];
}

//从缓存读取
-(XHBaseItem*)getItemsFromCache:(NSString*)key
{
    return  [self.idpCache objectForKey:key];
}

- (BOOL)isLoading
{
    return self.serverApi.state == IDP_PROC_STAT_LOADING;
}

//***实现者调用 加载网络请求
- (void)loadInner
{
    if (!self.address) {
        IDPLogWarning(0, @"address is nil");
        return;
    }
    if (!self.params)
    {
        IDPLogWarning(0, @"params is nil");
        return;
    }
    __block XHBaseModel* blockSelf = self;
    IDPLogDebug(@"serverApi is %@",self.serverApi);
    [self.serverApi  accessAPI:self.address WithParams:self.params files:nil completionBlock:^(IDPServerAPI * api)
     {
         [blockSelf handleIdpBlcok:api];
     }];
}


- (void)loadGetInner {
    if (!self.address) {
        IDPLogWarning(0, @"address is nil");
        return;
    }
    if (!self.params)
    {
        IDPLogWarning(0, @"params is nil");
        return;
    }
    __block XHBaseModel* blockSelf = self;
    IDPLogDebug(@"serverApi is %@",self.serverApi);
    [self.serverApi getAPI:self.address WithParams:self.params completionBlock:^(IDPServerAPI * api)
     {
         [blockSelf handleIdpBlcok:api];
     }];
}

-(void)handleIdpBlcok:(IDPServerAPI*) api
{
    
    self.error = api.error;
    self.procState = api.state;
    IDPLogDebug(@"error is %@ state is %d",api.error,api.state);
    //成功
    if (api.state == IDP_PROC_STAT_SUCCEED && !api.error)
    {
        IDPLogDebug(@"parseDataClassType  is %@",self.parseDataClassType);
        if (self.parseDataClassType) {
            if (![self.parseDataClassType isSubclassOfClass:[XHBaseItem class]])
            {
                IDPLogWarning(0, @"parseDataType is not TBCBaseItem class");
                return;
            }
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //异步解析数据
                __block XHBaseItem* item = [(XHBaseItem*)[self.parseDataClassType alloc] initWithDictionary:api.parsedData error:nil];
                //同步通知到主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleParsedData:item];
                    if ( self.completionBlock) {
                        self.completionBlock(self);
                    }
                    
                });
                
            });
        }
        else
        {
            [self handleUnParsedData:api.parsedData];
            if ( self.completionBlock) {
                self.completionBlock(self);
            }
        }
    }
    //失败
    else
    {
//        [TBCStatusHUD dismiss];
        //        [ProgressHUD showError:@"网络请求失败，请稍后再试！" Interacton:NO];
        [self onNetError];
        if ( self.completionBlock) {
            self.completionBlock(self);
        }
    }
    
}
//***实现者重载处理数据的逻辑
-(void)handleParsedData:(XHBaseItem*)parsedData
{
    
}
//***重载者实现处理未做parse的data
-(void)handleUnParsedData:(id)data
{
    
}
//***重载者实现网络请求失败时候的处理逻辑
-(void)onNetError
{
}
// 停止加载
- (void)cancel
{
    //不知道为什么两个 全调用了
    self.completionBlock = nil;
    [self.serverApi cancel];
    [self.serverApi  cancelRequests];
}



@end
