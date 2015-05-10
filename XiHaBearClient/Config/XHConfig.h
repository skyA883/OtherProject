//
//  XHConfig.h
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/1.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#ifndef XiHaBearClient_XHConfig_h
#define XiHaBearClient_XHConfig_h


#define XH_SERVER_HOST                  @"http://123.57.213.11:8080/api/v1/"
typedef void (^XHModelBlock)(BOOL isSuccess);




//数组越界检处理
#define OBJECT_OF_ATINDEX(_ARRAY_,_INDEX_) ((_ARRAY_)&&[_ARRAY_ isKindOfClass:[NSArray class]]&&([_ARRAY_ count]>0)&&((_INDEX_) < [_ARRAY_ count])&&((_INDEX_) >= 0)?([_ARRAY_ objectAtIndex:(_INDEX_)]):(nil))//有返回值


/**
 * define UUID:
 */
#define IPHONE5_UUID @""
#define IPADMINI_UUID @""
#define IPHONE4S_UUID @""

#define FEE0 @"FEE0"
#define FEEO_FF01 @"FF01"
#define FEEO_FF02 @"FF02"
#define FEEO_FF03 @"FF03"
#define FEEO_FF04 @"FF04"
#define FEEO_FF05 @"FF05"
#define FEEO_FF06 @"FF06"
#define FEEO_FF07 @"FF07"
#define FEEO_FF08 @"FF08"
#define FEEO_FF09 @"FF09"
#define FEEO_FF0A @"FF0A"
#define FEEO_FF0B @"FF0B"
#define FEEO_FF0C @"FF0C"
#define FEEO_FF0D @"FF0D"
#define FEEO_FF0E @"FF0E"
#define FEEO_FF0F @"FF0F"

#define FEE1 @"FEE1"
#define FEE7 @"FEE7"
#define F1802 @"1802"

/**
 * define notification：
 */
#define APPEnterBackgroundNotification @"APPEnterBackgroundNotification"
#define APPEnterForegroundNotification @"APPEnterForegroundNotification"


#endif
