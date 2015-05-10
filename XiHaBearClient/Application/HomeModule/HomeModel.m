//
//  HomeModel.m
//  XiHaBearClient
//
//  Created by lcfapril on 15/5/7.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "HomeModel.h"


@interface HomeModel ()
@property (nonatomic, strong) XHModelBlock block;
@end

@implementation HomeModel

- (id)initWithBlock:(XHModelBlock)block
{
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}



- (void)getHomeData
{
    self.address = @"/theme/index";
    self.params = @{@"otoken": @"232322"};
    self.parseDataClassType = [XHHomeItem class];
    [super loadInner];
    
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *parameters = @{@"otoken": @"232322"};
//    NSString *url = [NSString stringWithFormat:@"%@%@",XH_SERVER_HOST,@"theme/index"];
//    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
//    [[[IDPAFRequestManager alloc] initWithBaseURL:[NSURL URLWithString:XH_SERVER_HOST]] postPath:@"theme/index" parameters:@{@"otoken": @"232322"} timeOut:15 success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success .............");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error .............");
//    }];
    
}


//***实现者重载处理数据的逻辑
-(void)handleParsedData:(XHBaseItem*)parsedData
{
    XHHomeItem *item =  [self.idpCache objectForKey:[self.serverApi curRequestUrl]];
    
    
}
//***重载者实现处理未做parse的data
-(void)handleUnParsedData:(id)data
{
    IDPLogDebug(@"back  parseData is  %@",data);
    NSDictionary *result = [NSString getDicValue:[data objectAtPath:@"data/result"]];
    if(result){
        self.homeData = [[XHHomeItem alloc] initWithDictionary:result error:nil];
    }
    
    
}
//***重载者实现网络请求失败时候的处理逻辑
-(void)onNetError
{
    IDPLogDebug(@"error!!!");
}


@end
