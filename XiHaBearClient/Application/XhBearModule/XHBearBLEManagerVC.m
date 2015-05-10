//
//  XHBearBLEManagerVC.m
//  XiHaBearClient
//
//  Created by liuxuan on 15-4-26.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "XHBearBLEManagerVC.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface XHBearBLEManagerVC ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDataSource,UITableViewDelegate>

@property(strong,nonatomic)CBCentralManager * cbCenterManager;
@property(strong,nonatomic)UITextView * switchInfoLabel;
@property(strong,nonatomic)UISwitch * switchControl;
@property(strong,nonatomic)UITableView * currentTable;
@property(strong,nonatomic)NSMutableArray * devicesArray;
@property(strong,nonatomic)NSTimer * timer;
@property(strong,nonatomic)CBPeripheral * connectedPeripheral;
@end

@implementation XHBearBLEManagerVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appEnterBackgroundNotification:) name:APPEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appEnterForegroundNotification:) name:APPEnterForegroundNotification object:nil];
    
    self.devicesArray = [[NSMutableArray alloc]init];
    
    [self createUIView];
    [self createCBCentralManager];

}

-(void)appEnterBackgroundNotification:(NSNotification*)not
{
    //    [self.devicesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        CBPeripheral * per = (CBPeripheral*)obj;
    //        [per.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //            CBService * sev = (CBService*)obj;
    //            [sev.characteristics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //                CBCharacteristic * ch = (CBCharacteristic*)obj;
    //                [per setNotifyValue:NO forCharacteristic:ch];
    //            }];
    //        }];
    //    }];
    //    [self stopScanPeripheralsWithServices];
}

-(void)appEnterForegroundNotification:(NSNotification*)not
{
    //    [self.devicesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        CBPeripheral * per = (CBPeripheral*)obj;
    //        [per.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //            CBService * sev = (CBService*)obj;
    //            [sev.characteristics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //                CBCharacteristic * ch = (CBCharacteristic*)obj;
    //                [per setNotifyValue:YES forCharacteristic:ch];
    //            }];
    //        }];
    //    }];
    
    //    [self startScanPeripheralsWithServices];
}

-(void)viewWillAppear:(BOOL)animated
{
}

-(void)createUIView
{
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 100)];
    backView.backgroundColor = [UIColor greenColor];
    
    self.switchInfoLabel = [[UITextView alloc]initWithFrame:CGRectMake(0, 30, 200, 60)];
    self.switchInfoLabel.backgroundColor = [UIColor redColor];
    [backView addSubview:self.switchInfoLabel];
    
    self.switchControl = [[UISwitch alloc]initWithFrame:CGRectMake(CGRectGetWidth(backView.frame)-60, 40, 40, 30)];
    [self.switchControl addTarget:self action:@selector(switchScan:) forControlEvents:UIControlEventValueChanged];
    [backView addSubview:self.switchControl];
    
    [self.view addSubview:backView];
    
    self.currentTable = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(backView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetHeight(backView.frame)) style:UITableViewStylePlain];
    self.currentTable.dataSource = self;
    self.currentTable.delegate =self;
    [self.currentTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.currentTable];
}

//创建center并且开始搜索服务
-(void)createCBCentralManager
{
    /* 创建center：
     * options:
     * CBCentralManagerOptionShowPowerAlertKey:蓝牙关闭提示
     * CBCentralManagerOptionRestoreIdentifierKey:初始时指定唯一标示的uid
     */
    self.cbCenterManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

-(void)switchScan:(UISwitch*)switchControl
{
    if ([switchControl isOn]) {
        [self startScanPeripheralsWithServices];
    }else{
        [self stopScanPeripheralsWithServices];
    }
}

//开始搜索设备
-(void)startScanPeripheralsWithServices
{
    /* 开始扫描：
     * CBCentralManagerScanOptionAllowDuplicatesKey:
     * CBCentralManagerScanOptionSolicitedServiceUUIDsKey:
     */
    [self stopScanPeripheralsWithServices];
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.cbCenterManager scanForPeripheralsWithServices:[NSArray arrayWithObjects:[CBUUID UUIDWithString:FEE0], nil] options:options];
    
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

//连接某个设备
-(void)startConnectPeripheral:(CBPeripheral*)peripheral
{
    /* 连接可选设置：
     * CBConnectPeripheralOptionNotifyOnConnectionKey：app挂起时链接成功通知
     * CBConnectPeripheralOptionNotifyOnDisconnectionKey：app挂起时断开链接通知
     * CBConnectPeripheralOptionNotifyOnNotificationKey：app挂起时所有外设状态都通知
     */
    
    //发起连接
    if (peripheral.state == CBPeripheralStateDisconnected) {
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true],CBConnectPeripheralOptionNotifyOnNotificationKey, nil];
        [self.cbCenterManager connectPeripheral:peripheral options:options];
    }
    
}

-(void)startTimerForReadRSSI
{
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(readRSSI) userInfo:nil repeats:YES];
}


-(void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)readRSSI
{
    [self.connectedPeripheral readRSSI];
}

#pragma mark -- 中心服务管理者 delegate method

//@required

//状态更新
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString * str = @"";
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:{
            str = @"蓝牙关闭";
            //蓝牙打开再次开始搜索
            if ([self.switchControl isOn]) {
                [self startScanPeripheralsWithServices];
            }
        }
            break;
        case CBCentralManagerStatePoweredOn:{
            str = @"蓝牙打开";
        }
            break;
        case CBCentralManagerStateResetting:{
            str = @"蓝牙重置";
        }
            break;
        case CBCentralManagerStateUnsupported:{
            str = @"蓝牙不支持";
        }
            break;
        case CBCentralManagerStateUnauthorized:{
            str = @"蓝牙未授权";
        }
            break;
            
        default:{
            str = @"蓝牙位置状态";
        }
            break;
    }
    self.switchInfoLabel.text = [NSString stringWithFormat:@"%@/**/\n",str];
    NSLog(@"%@",str);
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
    NSString * str = [NSString stringWithFormat:@"发现设备%@",peripheral.name];
    NSLog(@"%@",str);
    self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
    
    //停止搜索设备
    [self stopScanPeripheralsWithServices];
    
    //发起连接
    [self startConnectPeripheral:peripheral];
    
    if (![self.devicesArray containsObject:peripheral]) {
        [self.devicesArray  addObject:peripheral];
        [self.currentTable reloadData];
    }
    
}

//已经断开链接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self stopTimer];
    /**
     *TODO:自动重试？
     */
    [peripheral.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CBService * service = (CBService*)obj;
        NSString * str = [NSString stringWithFormat:@"断开了设备%@的服务%@",peripheral.name,service.UUID.UUIDString];
        self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
    }];
    
}

//已经链接成功
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSString * str = [NSString stringWithFormat:@"连接设备%@成功！！",peripheral.name];
    NSLog(@"%@",str);
    self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
    
    //查询发现的设备的服务
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
    self.connectedPeripheral = peripheral;
    //信号强度监测
    [self startTimerForReadRSSI];
    
}

//链接失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSString * str = @"连接失败！！";
    NSLog(@"%@",str);
    self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
    
    //从新发起连接
    [self startConnectPeripheral:peripheral];
}


#pragma mark -- 外设的代理方法 delegate method

//发现服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //在这，才会有服务，然后根据服务UUID去判断
    NSString * str = @"发现服务！！";
    NSLog(@"%@",str);
    self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
    
    [peripheral.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CBService * service = (CBService*)obj;
        if ([service.UUID.UUIDString isEqualToString:FEE0]) {
            NSString * str = [NSString stringWithFormat:@"查询到了想匹配的设备%@的%@服务！",peripheral.name,service.UUID.UUIDString];
            NSLog(@"%@",str);
            self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
            
            
            //查询服务包含的特征
            [peripheral discoverCharacteristics:nil forService:service];
            
        }
        
    }];
    
}

//发现了含有某个服务的特征的外设(可以做写入操作)
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSString * str = @"发现了某个服务的特征！";
    NSLog(@"%@",str);
    self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
    
    [service.characteristics enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CBCharacteristic * characteristic = (CBCharacteristic*)obj;
        if ([characteristic.UUID.UUIDString isEqualToString:FEEO_FF01]) {
            NSString * str = [NSString stringWithFormat:@"查询到了想匹配的设备%@的服务%@包含的特征%@",peripheral.name,service.UUID.UUIDString,characteristic.UUID.UUIDString];
            NSLog(@"%@",str);
            self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
            
            //写入数据
            NSData * data = [@"1234" dataUsingEncoding:NSUTF8StringEncoding];
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            
        }
    }];
}

//写入某个特征的数据成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString * str = @"写入数据成功！！";
    NSLog(@"%@",str);
    self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
    
    [peripheral readRSSI];
}

//外设通知app，某个特征的值改变了（可以在这做读操作）
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [peripheral readValueForCharacteristic:characteristic];
    NSString * str = @"读入数据成功！！";
    NSLog(@"%@",str);
    self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
    
    //    characteristic.value;
}


-(void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSString * str = [NSString stringWithFormat:@"%@",RSSI];
    NSLog(@"%@",str);
    self.switchInfoLabel.text = [NSString stringWithFormat:@"%@%@/**/\n",self.switchInfoLabel.text,str];
    
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

#pragma mark -- table 数据代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    for(CBPeripheral * per in self.devicesArray){
        NSLog(@"table=%@",per.name);
    }
    return self.devicesArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * indentififer = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:indentififer];
    CBPeripheral * peripheral = OBJECT_OF_ATINDEX(self.devicesArray, indexPath.row);;
    cell.textLabel.text = peripheral.name;
    NSLog(@"name = %@",peripheral.name);
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
