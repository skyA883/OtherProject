//
//  IDPStorageMemoryInner.h
//  IDP
//
//  Created by douj on 17-3-12.
//
//

#import <Foundation/Foundation.h>
#import "IDPStorageProtocolInner.h"
@interface IDPStorageMemoryInner : NSObject

@property (nonatomic,assign) NSUInteger  memoryCapacity;
@property (nonatomic,assign) NSUInteger timeoutInterval;
+(void)cleanAllMemory;

-(id)initWithNameSpace:(NSString*)nameSpace;
-(id)loadObjectForKey:(NSString*)key;
-(BOOL)existObjectForKey:(NSString*)key;
-(void)removeObjectForKey:(NSString*)key;
-(void)saveObject:(id)obj forKey:(NSString*)key;
-(void)saveObject:(id)obj forKey:(NSString *)key cost:(NSUInteger)g;
-(void)saveObject:(id)obj forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
-(void)removeAll;
@end
