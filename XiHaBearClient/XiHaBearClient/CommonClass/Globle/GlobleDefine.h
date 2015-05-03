//
//  GlobleConstDefine.h
//  TestBLE
//
//  Created by liuxuan on 15-4-26.
//  Copyright (c) 2015年 letv. All rights reserved.
//

#ifndef TestBLE_GlobleConstDefine_h
#define TestBLE_GlobleConstDefine_h


//数组越界检处理
#define OBJECT_OF_ATINDEX(_ARRAY_,_INDEX_) ((_ARRAY_)&&[_ARRAY_ isKindOfClass:[NSArray class]]&&([_ARRAY_ count]>0)&&((_INDEX_) < [_ARRAY_ count])&&((_INDEX_) >= 0)?([_ARRAY_ objectAtIndex:(_INDEX_)]):(nil))//有返回值


#define IPHONE5_UUID @""
#define IPADMINI_UUID @""
#define IPHONE4S_UUID @""


/************通知定义***********/

#define APPEnterBackgroundNotification @"APPEnterBackgroundNotification"
#define APPEnterForegroundNotification @"APPEnterForegroundNotification"

#endif
