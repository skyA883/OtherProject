//
//  IDPStorageFileInner.h
//  IDP
//
//  Created by douj on 17-3-12.
//
//

#import <Foundation/Foundation.h>
#import "IDPStorageProtocolInner.h"
@interface IDPStorageFileInner : NSObject <IDPStorageProtocolInner>

-(id)initWithNameSpace:(NSString*)nameSpace;
+(void)cleanExpiredFiles:(NSString *)nameSpace expire:(NSNumber *)expireNumber;
+(long long)getNameSpaceSize:(NSString*)nameSpace;
+ (long long) fileSizeAtPath:(NSString*) filePath;

@end
