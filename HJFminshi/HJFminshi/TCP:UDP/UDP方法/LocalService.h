//
//  LocalService.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/9.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketOperator.h"
#define LocalServiceInstance [LocalService shareLocalService]

@protocol LocalServiceMethodDelegate <NSObject>
@required
//添加设备

//根据设备mac获取设备状态
- (void)getDeviceStatusWithDeviceInfo:(DevicePreF*)deviceinfo;
//找到设备，根据设备添加视图
- (void)AddViewToScrollViewWithDeviceInfo:(DevicePreF*)deviceinfo;
//根据设备查询设备是否在线
- (void)TcponlineDataWithDeviceInfo:(DevicePreF*)deviceinfo;
//根据设备设置在线订阅
- (void)TcpsubscribetoeventWithDeviceInfo:(DevicePreF*)deviceinfo;
//通过http上传设备数据给服务器
- (void)UploadDeviceinfoToHttpServerWithDeviceInfo:(DevicePreF*)deviceinfo;
//更新设备状态
- (void)UpdateStatusWithDeviceInfo:(DevicePreF*)deviceinfo;
@end

typedef enum
{
    NotBinded  = 0,
    Binding    = 1,
    Binded     = 2
} UdpBindStatus;

@interface LocalService : NSObject

@property (nonatomic,weak) id<LocalServiceMethodDelegate> MethodDelegate;


+ (LocalService *)shareLocalService;

//  绑定监听Udp socket
- (void)udpBindConnect;


//  断开udp绑定监听
- (void)CloseUdpBind;


//  发送命令到当前连接的udpsocket
- (void)sendToDeviceWithData:(NSData *)data deviceinfo:(DevicePreF *)deviceinfo complete:(Complete)delegate;


//  搜索所有未锁定设备
- (void)SearchAllUnlockDevice;


//  停止局域网搜索设备
- (void)StopSearchDevice;


//  发送搜索发现设备命令
- (void)SearchDeviceWithdeviceinfo:(DevicePreF *)deviceinfo;


//  发现所有设备,udp 在线判断
- (void)JugeAllDeviceudpOnline;


@end
