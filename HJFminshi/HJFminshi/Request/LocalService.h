//
//  LocalService.h
//  minshi
//
//  Created by iTC on 15/6/18.
//  Copyright (c) 2015年 ohbuy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LocalServiceInstance [LocalService shareLocalService]

typedef enum
{
    NotBinded  = 0,
    Binding    = 1,
    Binded     = 2
} UdpBindStatus;

@protocol LocalDelegate <NSObject>

@required
- (void)bindConnectSucceed:(BOOL)successed msg:(NSString *)msg;

- (void)udpmsg:(NSString *)msg;


@end

@class DeviceAllInfo;

@interface LocalService : NSObject

@property (nonatomic,weak) id<LocalDelegate> bindmsgdelegate;

+ (LocalService *)shareLocalService;

/**
 *  绑定监听Udp socket
 */
- (void)udpBindConnect;

/**
 *  断开udp绑定监听
 */
- (void)CloseUdpBind;

/**
 *  发送命令到当前连接的udpsocket
 *
 *  @param data       要发送的全部数据
 *  @param deviceinfo 设备信息,如果为nil,则发送到广播地址
 *  @param delegate   代理回调
 */
- (void)sendToDeviceWithData:(NSData *)data deviceinfo:(DeviceAllInfo *)deviceinfo complete:(Complete)delegate;

/**
 *  搜索所有未锁定设备
 */
- (void)SearchAllUnlockDevice;

/**
 *  停止局域网搜索设备
 */
- (void)StopSearchDevice;

/**
 *  发送搜索发现设备命令
 *
 *  @param deviceinfo 设备信息
 */
- (void)SearchDeviceWithdeviceinfo:(DeviceAllInfo *)deviceinfo;

/**
 *  发现所有设备,udp 在线判断
 */
- (void)JugeAllDeviceudpOnline;

@end
