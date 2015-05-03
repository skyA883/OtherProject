//
//  XHBLEManager.h
//  XiHaBearClient
//
//  Created by liuxuan on 15-5-3.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBCentralManager,CBPeripheral;
@interface XHBLEManager : NSObject

@property(readonly,nonatomic)CBCentralManager * cbCenterManager;

+(XHBLEManager * )shareXHBLEManager;
//开始搜索设备
-(void)startScanPeripheralsWithServices;
//停止搜索设备
-(void)stopScanPeripheralsWithServices;
//和某个外设断开链接
-(void)cancelConnectForPeripheral:(CBPeripheral*)peripheral;
@end
