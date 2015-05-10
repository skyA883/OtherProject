//
//  TBCServerAPI.h
//  贴吧客户端API底层类
//
//  Created by zhangdongjin on 13-3-18.
//
//

/* 以访问吧名推荐接口为例
 TBCServerAPI *banameapi = [[TBCServerAPI alloc] initWithServer:@"c.tieba.baidu.com" timeout:0];
 [banameapi accessAPI:@"/c/f/forum/sug" WithParams:@{@"q":@"A"} files:nil
    completionBlock:(IDPServerAPICompletionBlock)^(TBCServerAPI *a){
    // 先判断state，再看parsedData或者error
 }];
 */
#import "IDPServerAPI.h"

@interface TBCServerAPI : IDPServerAPI
// 公开的属性和方法参见父类-----^
@end
