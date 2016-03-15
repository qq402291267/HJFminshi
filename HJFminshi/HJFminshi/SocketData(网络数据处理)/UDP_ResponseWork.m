//
//  UDP_ResponseWork.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/9.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "UDP_ResponseWork.h"

@implementation UDP_ResponseWork

////  局域网发现设备
//+ (NSDictionary *)getdiscroverdevcieInfo:(NSData *)response
//{
//    @try {
//        //解析得到设备信息,添加设备到本地数据库及服务器
//        NSLog(@"得到局域网需要添加的设备信息");
//        if (response.length <= 17) {
//            return nil;
//        }
//        //帧头mac地址
//        NSData * headMac = [response subdataWithRange:NSMakeRange(2, 6)];
//        NSLog(@"headMac = %@",headMac);
//        //得到搜索到的设备信息
//        NSData * dataip = [response subdataWithRange:NSMakeRange(17, 4)];
//        NSString * host = [comMethod convertDataToip:dataip];
//        NSLog(@"host = %@",host);
//        NSData * macdata = [response subdataWithRange:NSMakeRange(21, 6)];
//        NSString * macstring = [comMethod convertDataTomacstring:macdata];
//        //测试数据转换是否正确
//        NSData * testmacdata = [comMethod convertmacstringToData:macstring];
//        NSLog(@"macdata = %@,macstring = %@,testmacdata = %@",macdata,macstring,testmacdata);
//        //添加设备数据到设备单例/本地数据库/服务器
//        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
//        if (!deviceinfo) {
////            NSLog(@"搜索设备不存在,首先添加设备到单例");
////            deviceinfo = [DevicePreF AllInfo];
////            deviceinfo.lanIP = host;
////            deviceinfo.macdata = macdata;
////            deviceinfo.macAddress = macstring;
////            //设置默认设备信息,companyCode,deviceType,authCode,devicename,logo,orderNumber
////            deviceinfo.companyCode = @"F1";
////            deviceinfo.deviceType = @"D1";
////            deviceinfo.authCode = @"3412";
////            deviceinfo.imageName = @"0.png";
////            deviceinfo.deviceName = @"minshiRT";
////            //得到用户名
////            NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERNAME];
////            deviceinfo.username = username;
////            //转化数据为网络传输格式
////            [DeviceManageInstance convertDeviceinfo:deviceinfo];
////            //添加到单例
////            [DeviceManageInstance.device_array addObject:deviceinfo];
////            //添加到本地数据库
////            [DeviceDataManagerInstance insertIntoDataBase:deviceinfo];
////            //得到添加的设备的数据库id
////            int DB_id = [DeviceDataManagerInstance getDetailRowDB_idWithmac:macstring username:username];
////            deviceinfo.DB_id = DB_id;
//            //添加完设备
////            [self sendFirstAddDevicecmd:deviceinfo];
//            
//        } else {
//            NSLog(@"搜索设备存在");
//            [self sendDeviceExistsOnlinecmd:deviceinfo lanIP:host];
//        }
//        return @{@"headMac":[NSString stringWithFormat:@"%@",headMac],
//                 @"host":[NSString stringWithFormat:@"%@",host],
//                 @"macdata":[NSString stringWithFormat:@"%@",macdata],
//                 @"macstring":[NSString stringWithFormat:@"%@",macstring]};
//        
//    } @catch (NSException *exception) {
//        //
//        NSLog(@"getdiscroverdevcieInfo>>>exception = %@",exception);
//        return nil;
//    }
//}
//
//
////局域网发现设备,设备存在,设备从离线到在线
//+ (void)sendDeviceExistsOnlinecmd:(DevicePreF *)deviceinfo lanIP:(NSString *)lanIP
//{
//    //判断设备局域网是否在线
//    if (!deviceinfo.localIsOnline) {
//        //设备局域网不在线
//        //修改局域网在线标志位
//        deviceinfo.localIsOnline = YES;
//        deviceinfo.lanIP = lanIP;
//        //发送局域网udp首次心跳通知
//        [self sendfirstheartbeatDataWithdeviceInfo:deviceinfo];
//        //获取设备所有状态信息
////        [self sendgetDeviceStatusWithdeviceInfo:deviceinfo];
//    }
//    //设备局域网在线,不处理
//}
//
////发送初次心跳通知(LocalService中实现)
//+ (void)sendfirstheartbeatDataWithdeviceInfo:(DevicePreF *)deviceinfo
//{
//    UInt16 interval = 10;
//    //得到操作设备的mac,找到对应的设备
//    NSData * macdata = deviceinfo.macdata;
//    deviceinfo.udpinterval = interval;
//    //跳转到主线程中发送通知
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //发送udp心跳回复通知
//        [[NSNotificationCenter defaultCenter] postNotificationName:FirstUdpInterval_Notification object:@{Mac_Key_data:macdata}];
//    });
//}


@end
