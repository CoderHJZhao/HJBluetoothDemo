//
//  HJCenterBLEViewController.m
//  BLEDemo
//
//  Created by ZhaoHanjun on 16/4/3.
//  Copyright © 2016年 https://github.com/CoderHJZhao. All rights reserved.
//

#import "HJCenterBLEViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface HJCenterBLEViewController () <CBCentralManagerDelegate,CBPeripheralDelegate>

/** 中心管理者 */
@property (nonatomic, strong) CBCentralManager *centerMgr;

/** 连接到的外设 */
@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation HJCenterBLEViewController

#pragma mark - 懒加载

- (CBCentralManager *)centerMgr
{
    if (!_centerMgr) {
        _centerMgr = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:nil];
        
    }
    return _centerMgr;
}


#pragma mark - 视图生命周期以及内存警告

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CoreBluetoothDemo";
    self.view.backgroundColor = [UIColor whiteColor];
    //先实例化管理者
    [self centerMgr];
#warning can only accept commands while in the powered on state不能在state非ON的情况下对我们的中心管理者进行操作

    // Do any additional setup after loading the view.
}


// 通常断开连接的操作在此处肯定要进行一次
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //此处断开链接
    [self zhj_dismissConentedWithPeripheral:self.peripheral];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CBCentralManagerDelegate

//必须会调用和实现的方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
#warning 枚举尽量用typedef NS_ENUM，因为可以用 ==来判断
    /**
     typedef NS_ENUM(NSInteger, CBCentralManagerState) {
     CBCentralManagerStateUnknown = 0,
     CBCentralManagerStateResetting,
     CBCentralManagerStateUnsupported,
     CBCentralManagerStateUnauthorized,
     CBCentralManagerStatePoweredOff,
     CBCentralManagerStatePoweredOn,
     };
     */
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
             NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
             NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
             NSLog(@"CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
             NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
             NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");
            //传入nil表示扫描所有
            [self.centerMgr scanForPeripheralsWithServices:nil options:nil];
            
        }
            break;
            
        default:
            break;
    }
    
    
}


/** 发现外设后调用的方法*/
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    if ([peripheral.name hasPrefix:@"hha"] && (ABS(RSSI.integerValue)) > 35) {
        //保存这个外设，让他的生命周期 = VC
        self.peripheral = peripheral;
        //筛选到符合条件的设备后进行链接
        [self.centerMgr connectPeripheral:peripheral options:nil];
        NSLog(@"发现合适的设备：%@",peripheral.name);
    }
}

/** 中心管理者链接外设成功*/
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"line = %d, %@=连接成功", __LINE__, peripheral.name);
    //链接成功后，进行服务和特征的发现
    self.peripheral.delegate = self;
    //外设发现服务，传nil代表不过滤
    [self.peripheral discoverServices:nil];
    
}

/** 外设链接失败*/
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"line = %d, %@=连接失败", __LINE__, peripheral.name);
}

/** 链接丢失*/
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"line = %d, %@=连接丢失", __LINE__, peripheral.name);
}

#pragma mark - 外设代理

/** 发现外设的服务后调用的方法*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //首先判断是否失败
    if (error) {
        NSLog(@"发现服务失败=====%@",error.localizedDescription);
        return;
    }
    
    NSLog(@"line = %d, %@=发现服务", __LINE__, peripheral.name);
    //便利发现的所有服务
    for (CBService *service in peripheral.services) {
        //传nil代表不过滤
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/** 发现外设服务里的特征的时候调用的代理方法*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    //首先判断是否失败
    if (error) {
        NSLog(@"发现服务特征失败=====%@",error.localizedDescription);
        return;
    }

    NSLog(@"line = %d, %@=发现服务特征", __LINE__, peripheral.name);
    for (CBCharacteristic *cha in service.characteristics) {
         // 获取特征对应的描述 didUpdateValueForDescriptor
        [peripheral discoverDescriptorsForCharacteristic:cha];
        // 获取特征的值 didUpdateValueForCharacteristic

        [peripheral readValueForCharacteristic:cha];
    }
}

/**更新特征的value的时候会调用 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //首先判断是否失败
    if (error) {
        NSLog(@"更新服务特征失败=====%@",error.localizedDescription);
        return;
    }
    
    NSLog(@"line = %d, %@=更新特征", __LINE__, peripheral.name);
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        [peripheral readValueForDescriptor:descriptor];
    }

}

/**更新特征描述的value的时候会调用 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //首先判断是否失败
    if (error) {
        NSLog(@"更新服务特征描述失败=====%@",error.localizedDescription);
        return;
    }
    // 这里当描述的值更新的时候,直接调用此方法即可
    [peripheral readValueForDescriptor:descriptor];
}

/** 发现外设的特征的描述数组*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //首先判断是否失败
    if (error) {
        NSLog(@"更新服务特征描述失败=====%@",error.localizedDescription);
        return;
    }
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        [peripheral readValueForDescriptor:descriptor];
    }
}

#pragma  mark - 自定义方法

/** 需要注意的是特征的属性是否支持写数据*/

- (void)zhj_peripheral:(CBPeripheral *)peripheral didWriteData:(NSData *)data forCharacteristic:(nonnull CBCharacteristic *)characteristic
{
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast												= 0x01,
     CBCharacteristicPropertyRead													= 0x02,
     CBCharacteristicPropertyWriteWithoutResponse									= 0x04,
     CBCharacteristicPropertyWrite													= 0x08,
     CBCharacteristicPropertyNotify													= 0x10,
     CBCharacteristicPropertyIndicate												= 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites								= 0x40,
     CBCharacteristicPropertyExtendedProperties										= 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)		= 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x200
     };
     
     打印出特征的权限(characteristic.properties),可以看到有很多种,这是一个NS_OPTIONS的枚举,可以是多个值
     常见的又read,write,noitfy,indicate.知道这几个基本够用了,前俩是读写权限,后俩都是通知,俩不同的通知方式
     */
    NSLog(@"%s, line = %d, char.pro = %d", __FUNCTION__, __LINE__, characteristic.properties);
    // 此时由于枚举属性是NS_OPTIONS,所以一个枚举可能对应多个类型,所以判断不能用 = ,而应该用包含&
    //判断是否可写
    if (characteristic.properties & CBCharacteristicPropertyWrite) {
        /*
         typedef NS_ENUM(NSInteger, CBCharacteristicWriteType) {
         CBCharacteristicWriteWithResponse = 0,
         CBCharacteristicWriteWithoutResponse,
         };
         **/

        [peripheral writeValue:data          // 写入的数据
             forCharacteristic:characteristic// 写给哪个特征
                          type:CBCharacteristicWriteWithResponse];// 通过此响应记录是否成功写入
    
    }

}


/** 通知的订阅和取消订阅*/
// 实际核心代码是一个方法
// 一般这两个方法要根据产品需求来确定写在何处
- (void)zhj_peripheral:(CBPeripheral *)peripheral regNotifyWithCharacteristic:(nonnull CBCharacteristic *)characteristic
{
    // 外设为特征订阅通知 数据会进入 peripheral:didUpdateValueForCharacteristic:error:方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}
- (void)zhj_peripheral:(CBPeripheral *)peripheral CancleRegNotifyWithCharacteristic:(nonnull CBCharacteristic *)characteristic
{
    // 外设取消订阅通知 数据会进入 peripheral:didUpdateValueForCharacteristic:error:方法
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

// 7.断开连接
- (void)zhj_dismissConentedWithPeripheral:(CBPeripheral *)peripheral
{
    // 停止扫描
    [self.centerMgr stopScan];
    // 断开连接
    [self.centerMgr cancelPeripheralConnection:peripheral];
    self.peripheral = nil;
}





@end
