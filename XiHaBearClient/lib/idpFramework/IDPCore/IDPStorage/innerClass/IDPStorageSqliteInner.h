//
//  IDPStorageSqliteInner.h
//  IDP
//
//  Created by ZhangHe on 13-3-21.
//
//

#import <Foundation/Foundation.h>
#import "IDPStorageProtocolInner.h"

@interface IDPStorageSqliteInner : NSObject <IDPStorageProtocolInner>

-(id)initWithNameSpace:(NSString*)nameSpace;

@end
