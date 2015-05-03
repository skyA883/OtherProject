//
//  XHBLEManager.m
//  XiHaBearClient
//
//  Created by liuxuan on 15-5-3.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "XHBLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface XHBLEManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property(strong,nonatomic)NSMutableArray * devicesArray;
@end

@implementation XHBLEManager

+(XHBLEManager * )shareXHBLEManager
{
    static XHBLEManager * bleManager = nil;
    
    @synchronized(self){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bleManager = [[XHBLEManager alloc]init];
        [bleManager creatCBCentralManager];
    });
    }
    return bleManager;
}

//创建center
-(void)creatCBCentralManager
{
    /* 创建center：
     * options:
     * CBCentralManagerOptionShowPowerAlertKey:蓝牙关闭提示
     * CBCentralManagerOptionRestoreIdentifierKey:初始时指定唯一标示的uid
     */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cbCenterManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    });
}


//开始搜索设备
-(void)startScanPeripheralsWithServices
{
    /* 开始扫描：
     * CBCentralManagerScanOptionAllowDuplicatesKey:
     * CBCentralManagerScanOptionSolicitedServiceUUIDsKey:
     */
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.cbCenterManager scanForPeripheralsWithServices:nil options:options];
    
}

//停止搜索设备
-(void)stopScanPeripheralsWithServices
{
    [self.cbCenterManager stopScan];
}

//和某个外设断开链接
-(void)cancelConnectForPeripheral:(CBPeripheral*)peripheral
{
    [self.cbCenterManager cancelPeripheralConnection:peripheral];
}


#pragma mark -- 中心服务管理者 delegate method

//@required

//状态更新
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:{
            NSLog(@"蓝牙关闭");
        }
            break;
        case CBCentralManagerStatePoweredOn:{
            NSLog(@"蓝牙打开");
        }
            break;
        case CBCentralManagerStateResetting:{
            NSLog(@"蓝牙重置");
        }
            break;
        case CBCentralManagerStateUnsupported:{
            NSLog(@"蓝牙不支持");
        }
            break;
        case CBCentralManagerStateUnauthorized:{
            NSLog(@"蓝牙未授权");
        }
            break;
            
        default:{
            NSLog(@"蓝牙未知状态");
        }
            break;
    }
}

//@optional

//恢复状态
-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    
}

//检索到的已经链接的外设列表
-(void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog(@"检索到的已经链接设备=%@",peripherals);
}

//检索到的外设列表
-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"检索到的外设=%@",peripherals);
}

//发现外设
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"发现外设 name= %@,serivice=%@",peripheral.name,peripheral.services);
    if (![self.devicesArray containsObject:peripheral]) {
        [self.devicesArray  addObject:peripheral];
//        [self.currentTable reloadData];
    }
    //    [peripheral.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        CBService * service = (CBService*)obj;
    //        NSLog(@"UUID = %@",service.UUID.UUIDString);
    //        if ([service.UUID.UUIDString isEqualToString:IPADMINI_UUID]) {
    
    NSLog(@"找到ipadmini %@ 发起连接",peripheral.name);
    
    /* 连接可选设置：
     * CBConnectPeripheralOptionNotifyOnConnectionKey：app挂起时链接成功通知
     * CBConnectPeripheralOptionNotifyOnDisconnectionKey：app挂起时断开链接通知
     * CBConnectPeripheralOptionNotifyOnNotificationKey：app挂起时所有外设状态都通知
     */
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true],CBConnectPeripheralOptionNotifyOnNotificationKey, nil];
    [self.cbCenterManager connectPeripheral:peripheral options:options];
    //        }
    //    }];
}

//已经链接成功
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    NSLog(@"链接成功1111！！=%@",peripheral.services);
    [peripheral.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CBService * service = (CBService*)obj;
        //        if ([service.UUID.UUIDString isEqualToString:IPADMINI_UUID]) {
        NSLog(@"查询%@服务包含的特征,UUID=%@",peripheral.name,service.UUID.UUIDString);
        //查询服务包含的特征
        [peripheral discoverCharacteristics:nil forService:service];
        //        }
        
    }];
    
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
    NSLog(@"链接成功2222！!=%@",peripheral.services);
    [peripheral.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CBService * service = (CBService*)obj;
        //        if ([service.UUID.UUIDString isEqualToString:IPADMINI_UUID]) {
        NSLog(@"查询%@服务包含的特征,%@",peripheral.name,service.UUID.UUIDString);
        //查询服务包含的特征
        [peripheral discoverCharacteristics:nil forService:service];
        //        }
        
    }];
    
}

//链接失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"链接失败！！");
    
}


#pragma mark -- 外设的代理方法 delegate method

//发现服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"发现服务！！");
    [peripheral.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CBService * service = (CBService*)obj;
        //        if ([service.UUID.UUIDString isEqualToString:IPADMINI_UUID]) {
        NSLog(@"查询%@服务包含的特征,%@",peripheral.name,service.UUID.UUIDString);
        //查询服务包含的特征
        [peripheral discoverCharacteristics:nil forService:service];
        //        }
        
    }];
}

//发现了含有某个服务的特征的外设(可以做写入操作)
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"发现了某个服务的特征的外设");
    [service.characteristics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CBCharacteristic * characteristic = (CBCharacteristic*)obj;
        //        if ([characteristic.UUID.UUIDString isEqualToString:IPADMINI_UUID]) {
        NSLog(@"给ipad mini的特征写入数据");
        NSData * data = [@"1234" dataUsingEncoding:NSUTF8StringEncoding];
        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        //        }
    }];
}

//写入某个特征的数据成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"写入数据成功！！");
}

//外设通知app，某个特征的值改变了（可以在这做读操作）
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [peripheral readValueForCharacteristic:characteristic];
    
    NSLog(@"读入数据成功！！");
    
    //    characteristic.value;
}


-(void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}



//发现了含有某个特征的描述的外设
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

//按符号描述写入成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}


//发现了包含某个服务的外设
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    
}


-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}


-(void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    
}

@end
