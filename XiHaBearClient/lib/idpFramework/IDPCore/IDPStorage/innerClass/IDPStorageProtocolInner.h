//
//  IDPStorageProtocol.h
//  IDP
//
//  Created by douj on 17-3-12.
//
//

#import <Foundation/Foundation.h>

@protocol IDPStorageProtocolInner <NSObject>

-(BOOL)existObjectForKey:(NSString*)key;
//同步方法
-(NSData*)loadObjectForKey:(NSString*)key error:(NSError**)error;
-(BOOL)saveObject:(NSData*)obj forKey:(NSString*)key error:(NSError**)error;
-(BOOL)removeObjectForKey:(NSString*)key error:(NSError **)error;

//清空整个命名空间
+(BOOL)cleanNameSpace:(NSString*)nameSpace error:(NSError **)error;


@end