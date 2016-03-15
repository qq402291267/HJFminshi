//
//  DeviceManage.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "DeviceManage.h"
#import "DeviceMethod.h"
#import "ProtocolData.h"
#import "IndexManager.h"
#import "TcpUdpService.h"
static DeviceManage * singleInstance = nil;

@implementation DeviceManage

+ (DeviceManage *)shareAllDevice
{
    if (singleInstance == nil) {
        singleInstance = [[DeviceManage alloc] init];
    }
    return singleInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _device_array = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceAllStatusNotification:) name:GetDeviceStatus_Notification object:nil];
    }
    return self;
}

- (DevicePreF*)getDevicePreFWithmac:(NSData *)mac
{

    DevicePreF * deviceInfo = nil;
    for (DevicePreF * currentdevice in _device_array)
    {
        
        if ([currentdevice.macdata isEqualToData:mac]) {
            deviceInfo = currentdevice;
            break;
        }
    }
    return deviceInfo;
}
//
//- (BOOL)IsExistsWithmac:(NSData *)mac
//{
//    BOOL isExists = NO;
//    for (DevicePreF * currentdevice in _device_array) {
//        if ([currentdevice.macdata isEqualToData:mac]) {
//            isExists = YES;
//            break;
//        }
//    }
//    return isExists;
//}
//
- (BOOL)IsExistsWithmacstr:(NSString *)macstr
{
    BOOL isExists = NO;
    for (DevicePreF * currentdevice in _device_array) {
        if ([currentdevice.macAddress isEqualToString:macstr]) {
            isExists = YES;
            break;
        }
    }
    return isExists;
}

//转化数据
- (void)convertDeviceinfo:(DevicePreF *)deviceinfo
{
    //    NSData * macdata = [response subdataWithRange:NSMakeRange(21, 6)];
    //    NSString * macstring = [Util convertDataTomacstring:macdata];
    //    //测试数据转换是否正确
    //    NSData * testmacdata = [Util convertmacstringToData:macstring];
    //    NSLog(@"macdata = %@,macstring = %@,testmacdata = %@",macdata,macstring,testmacdata);
    //macdata
    if (deviceinfo == nil) {
        return;
    }
    if (deviceinfo.macdata == nil) {
        deviceinfo.macdata = [ comMethod convertmacstringToData:deviceinfo.macAddress];
    }
    //companyCodevalue
    NSData * companyCodevaluedata = [comMethod convertmacstringToData:deviceinfo.companyCode];
    deviceinfo.companyCodevalue = ((UInt8 *)[companyCodevaluedata bytes])[0];
    //deviceTypevalue
    NSData * deviceTypevaluedata = [comMethod convertmacstringToData:deviceinfo.deviceType];
    deviceinfo.deviceTypevalue = ((UInt8 *)[deviceTypevaluedata bytes])[0];
    //authCodedata
    deviceinfo.authCodedata = [comMethod  convertmacstringToData:deviceinfo.authCode];
}

//处理设备IO状态
- (void)DealWithIOStatus:(DevicePreF *)deviceinfo controlType:(UInt8)controlType IOOpen:(BOOL)IOOpen
{
    if (controlType == 0x00) {
        deviceinfo.mainIsOpen = IOOpen;
    } else if (controlType == 0x01) {
        deviceinfo.ledIsOpen = IOOpen;
    } else {
        deviceinfo.atomizationIsOpen = IOOpen;
    }
}

//处理LED RGB值
- (void)DealWithLedRGB:(DevicePreF *)deviceinfo Rvalue:(UInt8)Rvalue Gvalue:(UInt8)Gvalue Bvalue:(UInt8)Bvalue
{
    deviceinfo.Rfloatvalue = Rvalue/255.0;
    deviceinfo.Gfloatvalue = Gvalue/255.0;
    deviceinfo.Bfloatvalue = Bvalue/255.0;
    //将颜色值转化为HSV 值
    float h,s,v;
    [comMethod RGBtoHSVr:deviceinfo.Rfloatvalue g:deviceinfo.Gfloatvalue b:deviceinfo.Bfloatvalue h:&h s:&s v:&v];
    deviceinfo.Hfloatvalue = h;
    deviceinfo.Sfloatvalue = s;
    deviceinfo.Vfloatvalue = v;
    deviceinfo.OldVfloatvalue = v;
    NSString * value = [NSString stringWithFormat:@"v = %f",deviceinfo.Vfloatvalue];
    NSLog(@">>>>>>>>>>>setledLight:%@",value);
}

//处理LED 模式
- (void)DealWithLedModel:(DevicePreF *)deviceinfo modelvalue:(UInt8)modelvalue
{
    deviceinfo.ledModelvalue = modelvalue;
}

//处理雾化度
- (void)DealWithatomization:(DevicePreF *)deviceinfo atomizationvalue:(UInt8)atomizationvalue
{
    deviceinfo.atomizationvalue = atomizationvalue;
}

//倒计时
- (void)DealWithcloseTimer:(DevicePreF *)deviceinfo closeTimervalue:(long)closeTimervalue
{
    deviceinfo.closeTimervalue = closeTimervalue;
//    [deviceinfo firststartcloseTimer];
}

//处理设备上报数据
- (void)DealWithDeviceUploadData:(DevicePreF *)deviceinfo Event_Type:(UInt8)Event_Type Event_Status:(UInt8)Event_Status
{
    //Event_Type：1 - Byte，0x00表示主设备，0x01表示LED灯，0x02表示雾化。
    //Event_Status：1 - Byte，0x00表示关，0xFF表示开
    if (Event_Type == 0x00) {
        //0x00表示主设备
        deviceinfo.mainIsOpen = ((Event_Status & 0xff) == 0xff);
        
    } else if (Event_Type == 0x01) {
        //0x01表示LED灯
        deviceinfo.ledIsOpen = ((Event_Status & 0xff) == 0xff);
        
    } else if (Event_Type == 0x02) {
        //0x02表示雾化
        deviceinfo.atomizationIsOpen = ((Event_Status & 0xff) == 0xff);
        
    } else if (Event_Type == 0x03) {
        //0x03
        if (Event_Status == 0x00) {
            //缺水报警
            //跳转到主线程中发送通知
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceWater_Notification object:@{Mac_Key_data:deviceinfo.macdata}];
            });
        }
    }
}

//---------------------------Notification--------------------------------------
- (void)getDeviceAllStatusNotification:(NSNotification *)notification
{
    NSDictionary * dict = [notification object];
    NSData * macdata = [dict objectForKey:Mac_Key_data];
    DevicePreF * deviceinfo = [self getDevicePreFWithmac:macdata];
    NSLog(@"macdata = %@,deviceinfo = %@",macdata,deviceinfo);
    [self getDeviceAllStatusWithdeviceinfo:deviceinfo];
}

/**
 *  查询设备所有状态信息
 */
- (void)getDeviceAllStatusWithdeviceinfo:(DevicePreF *)deviceinfo
{
    NSLog(@"查询设备信息");
    if (deviceinfo == nil) {
        NSLog(@"查询设备信息,设备不存在");
        return;
    }
    //1.cmd = 0x00,查询主设备状态
    NSLog(@"localIsOnline = %d,remoteIsOnline = %d",deviceinfo.localIsOnline,deviceinfo.remoteIsOnline);
    NSData * senddata = [ProtocolData getDeviceIOStatus:[IndexManagerInstance newIndex] controlType:0x00 deviceinfo:deviceinfo isremote:!deviceinfo.localIsOnline];
    [TcpUdpServiceInstance sendData:senddata deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
        [self refreshUImac:deviceinfo.macdata];
    }];
    //2.cmd = 0x01,查询LED灯状态
    senddata = [ProtocolData getDeviceIOStatus:[IndexManagerInstance newIndex] controlType:0x01 deviceinfo:deviceinfo isremote:!deviceinfo.localIsOnline];
    [TcpUdpServiceInstance sendData:senddata deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
        [self refreshUImac:deviceinfo.macdata];
    }];
    //3.cmd = 0x02,查询设备雾化状态
    senddata = [ProtocolData getDeviceIOStatus:[IndexManagerInstance newIndex] controlType:0x02 deviceinfo:deviceinfo isremote:!deviceinfo.localIsOnline];
    [TcpUdpServiceInstance sendData:senddata deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
        [self refreshUImac:deviceinfo.macdata];
    }];
    //获取LED灯RGB
    senddata = [ProtocolData commonDeviceInfoWithType:getDeviceInfoType_ledRGB index:[IndexManagerInstance newIndex] deviceinfo:deviceinfo isremote:!deviceinfo.localIsOnline];
    [TcpUdpServiceInstance sendData:senddata deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
        [self refreshUImac:deviceinfo.macdata];
    }];
    //获取LED工作模式
    senddata = [ProtocolData commonDeviceInfoWithType:getDeviceInfoType_ledModel index:[IndexManagerInstance newIndex] deviceinfo:deviceinfo isremote:!deviceinfo.localIsOnline];
    [TcpUdpServiceInstance sendData:senddata deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
        [self refreshUImac:deviceinfo.macdata];
    }];
    //获取雾化度
    senddata = [ProtocolData commonDeviceInfoWithType:getDeviceInfoType_antomization index:[IndexManagerInstance newIndex] deviceinfo:deviceinfo isremote:!deviceinfo.localIsOnline];
    [TcpUdpServiceInstance sendData:senddata deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
        [self refreshUImac:deviceinfo.macdata];
    }];
    //查询倒计时
    senddata = [ProtocolData commonDeviceInfoWithType:getDeviceInfoType_offtime index:[IndexManagerInstance newIndex] deviceinfo:deviceinfo isremote:!deviceinfo.localIsOnline];
    [TcpUdpServiceInstance sendData:senddata deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
        [self refreshUImac:deviceinfo.macdata];
    }];
    //其他信息初始化
}

//发送通知更新UI
- (void)refreshUImac:(NSData *)macdata
{
    //发送通知更新设备状态
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateStatus_Notification object:@{Mac_Key_data:macdata}];
}


@end
