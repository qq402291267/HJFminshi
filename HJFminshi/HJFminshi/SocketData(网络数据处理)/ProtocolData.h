//
//  ProtocolData.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    getDeviceInfoType_ledRGB = 1,
    getDeviceInfoType_ledModel,
    getDeviceInfoType_antomization,
    getDeviceInfoType_offtime,
    deleteDeviceType_offtime
} getDeviceInfoType;

@interface ProtocolData : NSObject


#pragma mark - tcp

/**
 *  获取工作服务器
 *
 *  @param index    通信序号
 *
 *  @return NSData
 */
+ (NSData *)workingServer:(UInt16)index;

/**
 *  请求接入Tcp服务器0x82
 *
 *  @param index    通信序号
 *  @param username 用户名
 *  @param password 密码
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)requestTcp:(UInt16)index username:(NSString *)username password:(NSString *)password;

/**
 *  订阅/取消订阅事件0x83
 *
 *  @param deviceinfo 设备信息
 *  @param index      通信序号
 *  @param issub      订阅或取消订阅
 *  @param cmd        订阅事件
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)subscribetoeventsWithdeviceinfo:(DevicePreF *)deviceinfo index:(UInt16)index issub:(BOOL)issub cmd:(UInt8)cmd;

/**
 *  查询设备是否在线0x84
 *
 *  @param deviceinfo 需查询的设备
 *  @param index      通信序号
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)getonlinestatusWithdeviceinfo:(DevicePreF *)deviceinfo index:(UInt16)index;

/**
 *  获取设备最新固件版本信息0x86
 *
 *  @param deviceinfo 需查询的设备
 *  @param index      通信序号
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)getnewversionWithdeviceinfo:(DevicePreF *)deviceinfo index:(UInt16)index;

/**
 *  发送心跳包到服务器
 *
 *  @param index    通信序号
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)heartBeatserver:(UInt16)index;

#pragma mark - udp
/**
 *  udp发现设备0x23
 *
 *  @param index      通信序号
 *  @param deviceinfo 设备信息
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)discorverdevice:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo;

/**
 *  udp锁定解锁设备0x24
 *
 *  @param index      通信序号
 *  @param islock     是否锁定
 *  @param deviceinfo 设备信息
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)lockunlockdevice:(UInt16)index lock:(BOOL)islock deviceinfo:(DevicePreF *)deviceinfo;

/**
 *  udp发送心跳包0x61
 *
 *  @param index      通信序号
 *  @param deviceinfo 设备信息
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)heartBeatLocal:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo;

#pragma mark - tcp/udp
/**
 *  0x62查询模块信息
 *
 *  @param index      通信序号
 *  @param deviceinfo 设备信息
 *  @param isremote   是否是远程访问
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)getcurrentdeviceVersion:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x63设置模块别名
 *
 *  @param index      通信序号
 *  @param alisalen   别名长度
 *  @param alisadata  别名信息
 *  @param deviceinfo 设备信息
 *  @param isremote   是否是远程访问
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)setdevicealisa:(UInt16)index alisalen:(UInt8)alisalen alisadata:(NSData *)alisadata deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x65模块固件升级
 *
 *  @param index      通信序号
 *  @param urllen     url长度
 *  @param urldata    url数据
 *  @param deviceinfo 设备信息
 *  @param isremote   是否是远程访问
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)updatedevice:(UInt16)index urllen:(UInt8)urllen urldata:(NSData *)urldata deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

#pragma mark - 产品专用命令
/**
 *  组包设备共有信息(仅有第一个命令字节)
 *
 *  @param index      通信序号
 *  @param deviceinfo    设备信息
 *  @param isremote      是否是远程访问
 *
 *  @return
 */
+ (NSData *)commonDeviceInfoWithType:(getDeviceInfoType)Type index:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x01控制设备状态
 *
 *  @param index         通信序号
 *  @param controlType   controlType
 *  @param controlStatus controlStatus
 *  @param deviceinfo    设备信息
 *  @param isremote      是否是远程访问
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)setDeviceIOStatus:(UInt16)index controlType:(UInt8)controlType controlStatus:(UInt8)controlStatus deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x02查询设备状态
 *
 *  @param index         通信序号
 *  @param controlType   controlType
 *  @param deviceinfo    设备信息
 *  @param isremote      是否是远程访问
 *
 *  @return
 */
+ (NSData *)getDeviceIOStatus:(UInt16)index controlType:(UInt8)controlType deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x03设置LED灯颜色/亮度
 *
 *  @param index      通信序号
 *  @param Rvalue     R
 *  @param Gvalue     G
 *  @param Bvalue     B
 *  @param deviceinfo    设备信息
 *  @param isremote      是否是远程访问
 *
 *  @return
 */
+ (NSData *)setDeviceledRGB:(UInt16)index Rvalue:(UInt8)Rvalue Gvalue:(UInt8)Gvalue Bvalue:(UInt8)Bvalue deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x05 设置LED工作模式
 *
 *  @param index      通信序号
 *  @param model      工作模式
 *  @param deviceinfo    设备信息
 *  @param isremote      是否是远程访问
 *
 *  @return
 */
+ (NSData *)setLedModel:(UInt16)index model:(UInt8)model deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x07 设置雾化度
 *
 *  @param index      通信序号
 *  @param atomization      雾化度(0-100)
 *  @param deviceinfo    设备信息
 *  @param isremote      是否是远程访问
 *
 *  @return
 */
+ (NSData *)setatomization:(UInt16)index atomization:(UInt8)atomization deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x09 设置倒计时
 *
 *  @param index      通信序号
 *  @param time       倒计时
 *  @param deviceinfo    设备信息
 *  @param isremote      是否是远程访问
 *
 *  @return
 */
+ (NSData *)setofftime:(UInt16)index time:(long)time deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x0C设置预约
 *
 *  @param index  通信序号
 *  @param num    预约任务序号，取值范围为 1~10。响应包返回时，成功则返回相应序号，失败返回0
 *  @param flag   预约任务标志。Bit7 为预约任务状态（1~开启/0~关闭） ，若单次预约事件触发，则将对应预约任务的 Bit7 清零。Bit6~0 分别对应周日到周一（Bit6 对应星期天，Bit5 对应星期六，以此类推，Bit0 对应星期一），Bit6~0 的相应位被置位，则表示该预约为重复定时，预约事件触发后 Bit7 不清零，直到用户手动清零 Bit7，否则一直重复
 *  @param hour   小时，取值范围 0 ~ 23
 *  @param min    分钟，取值范围 0 ~ 59
 *  @param isOpen 0x00表示关，0xFF表示开
 *  @param deviceinfo    设备信息
 *  @param isremote      是否是远程访问
 *
 *  @return
 */
+ (NSData *)setBookWithindx:(UInt16)index Num:(UInt8)num Flag:(UInt8)flag Hour:(UInt8)hour Min:(UInt8)min isOpen:(BOOL)isOpen deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x0d查询预约
 *
 *  @param index      通信序号
 *  @param numData    要查询的预约序号data
 *  @param deviceinfo 设备信息
 *  @param isremote   是否是远程访问
 *
 *  @return
 */
+ (NSData *)getBookDataWithindex:(UInt16)index Numdata:(NSData *)numData deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;

/**
 *  0x0e删除预约
 *
 *  @param index      通信序号
 *  @param num        需要删除的预约序号
 *  @param deviceinfo 设备信息
 *  @param isremote   是否是远程访问
 *
 *  @return
 */
+ (NSData *)deleteBookWithindex:(UInt16)index Num:(UInt8)num deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote;


@end
