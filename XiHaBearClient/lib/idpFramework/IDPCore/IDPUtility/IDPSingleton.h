//
//  IDPSingleton.h
//  iPadClient
//
//  Created by zhong on 12-12-22.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#pragma mark -

#undef	DEC_SINGLETON
#define DEC_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
        + (__class *)sharedInstance \
        { \
            static dispatch_once_t once; \
            static __class * __singleton__; \
            dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
            return __singleton__; \
        }