//
//  XHBaseModel.h
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/2.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "IDPBaseModel.h"
#import "TBCServerAPI.h"
#import "XHBaseItem.h"

@interface XHBaseModel : IDPBaseModel


//网络请求
@property (nonatomic,strong) TBCServerAPI*              serverApi;
//网络请求参数
@property (nonatomic,strong) NSDictionary*              params;
//请求地址 需要在子类init中初始化
@property (nonatomic,copy)   NSString*                  address;
//自动解析的数据类型 可能在不同线程访问  因此设置为 atomic
@property (assign,atomic) Class                      parseDataClassType;
//model缓存
@property (strong,nonatomic) IDPCache*                  idpCache;

//从缓存读数据
-(XHBaseItem*)getItemsFromCache:(NSString*)key;
//将数据设置到缓存
-(void)setCacheItems:(XHBaseItem*)item key:(NSString*)key;

-(void)handleParsedData:(XHBaseItem*)parsedData;

-(BOOL)isLoading;

- (void)loadInner;

- (void)loadGetInner;

@end
