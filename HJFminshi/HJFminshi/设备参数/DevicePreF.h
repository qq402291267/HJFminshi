//
//  DevicePreF.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "HJFDeviceView.h"
@interface DevicePreF : NSObject

// macAddress,companyCode deviceType authCode devicename imageName orderNumber

//    设备对应视图
//@property (nonatomic ,weak) HJFDeviceView *DeviceView;

// 设备数据库id
@property (nonatomic,assign) int DB_id;

// 授权码
@property (nonatomic,copy) NSString * authCode;

// 授权码对应字节值
@property (nonatomic,strong) NSData * authCodedata;

// 厂家代码
@property (nonatomic,copy) NSString * companyCode;

// 厂家代码对应字节值
@property (nonatomic,assign) UInt8 companyCodevalue;

// 设备名称
@property (nonatomic,copy) NSString * deviceName;

// 设备类型
@property (nonatomic,copy) NSString * deviceType;

// 设备类型对应字节值
@property (nonatomic,assign) UInt8 deviceTypevalue;

// 结束时间 nil
@property (nonatomic,copy) NSString *  endHour;

// 结束时间 nil
@property (nonatomic,copy) NSString *  endMin;

// 图片名称
@property (nonatomic,copy) NSString * imageName;

// 最后更新时间
@property (nonatomic,copy) NSString * lastOperation;

// mac地址
@property (nonatomic,copy) NSString * macAddress;

//  设备MAC地址NSData
@property (nonatomic,copy) NSData * macdata;

// 排序号
@property (nonatomic,assign) int orderNumber;

// 安全警报
@property (nonatomic,copy) NSString * securityAlarm;

// 结束时间
@property (nonatomic,copy) NSString * startHour;

// 结束时间
@property (nonatomic,copy) NSString * startMin;

//  用户名
@property (nonatomic,copy) NSString * username;

//  设备外网是否在线

@property (nonatomic,assign) BOOL remoteIsOnline;

//  设备局域网是否在线
@property (nonatomic,assign) BOOL localIsOnline;

//  局域网心跳时间间隔
@property (nonatomic,strong) NSTimer * heartbeatTimer;

@property (nonatomic,strong) NSTimer * stopheartTimer;

@property (nonatomic,assign) UInt16 udpinterval;

// 设备局域网IP
@property (nonatomic,copy) NSString * lanIP;



#pragma mark - serverversion data 服务器最新版本信息
//-------------------------------------------------------
//  最新版本号长度
@property (nonatomic,assign) int newversionlen;

//  最新设备版本号 data数据
@property (nonatomic,strong) NSData * newversiondata;

//  最新设备版本号 stirng数据
@property (nonatomic,strong) NSString * newversion;

//  升级url长度
@property (nonatomic,assign) int updateurllen;

//  升级url data数据
@property (nonatomic,strong) NSData * updateurldata;

//  升级url string数据
@property (nonatomic,strong) NSString * updateurl;
//-------------------------------------------------------


#pragma mark - deviceversion data 设备当前版本信息及别名
//-------------------------------------------------------
//   硬件版本长度
@property (nonatomic,assign) UInt8 hlen;

//   硬件版本号 data
@property (nonatomic,strong) NSData * hversiondata;

//   硬件版本号 str
@property (nonatomic,strong) NSString * hversionstr;

//  软件版本长度
@property (nonatomic,assign) UInt8 slen;

//  软件版本号 data
@property (nonatomic,strong) NSData * sversiondata;

//  软件版本号 str
@property (nonatomic,strong) NSString * sversionstr;

//    别名长度
@property (nonatomic,assign) UInt8 alisalen;

//  别名 data
@property (nonatomic,strong) NSData * alisadata;

//  别名 str
@property (nonatomic,strong) NSString * alisastr;
//-------------------------------------------------------

#pragma mark - 专用控制命令数据
//-------------------------------------------------------
//  0x00主设备,是否打开
@property (nonatomic,assign) BOOL mainIsOpen;

//  0x01LED灯,是否打开
@property (nonatomic,assign) BOOL ledIsOpen;

//  0x02雾化,是否打开
@property (nonatomic,assign) BOOL atomizationIsOpen;


//  0x04 获取LED灯颜色(0.0.~1.0)
@property (nonatomic,assign) float Rfloatvalue;
@property (nonatomic,assign) float Gfloatvalue;
@property (nonatomic,assign) float Bfloatvalue;

//  LED灯 , 亮度(0.0~1.0)
@property (nonatomic,assign) float Hfloatvalue;
@property (nonatomic,assign) float Sfloatvalue;
@property (nonatomic,assign) float Vfloatvalue;

//  原亮度V值
@property (nonatomic,assign) float OldVfloatvalue;

//  LED灯工作模式
@property (nonatomic,assign) UInt8 ledModelvalue;

//  雾化度
@property (nonatomic,assign) UInt8 atomizationvalue;

//  倒计时
@property (nonatomic,assign) long closeTimervalue;



//  局域网设备是否被锁定
@property (nonatomic,assign) BOOL islock;



// *  设备对应视图
// */
//@property (nonatomic,weak) DeviceViewCell * deviceView;

//#pragma mark - db data 服务器设备数据,保存到本地数据库
///**
// *  设备数据库id
// */
//@property (nonatomic,assign) int DB_id;
///**
// *  设备局域网IP
// */
//@property (nonatomic,copy) NSString * lanIP;
///**
// *  设备MAC地址NSData
// */
//@property (nonatomic,copy) NSData * macdata;
///**
// *  设备MAC地址NSString
// */
//@property (nonatomic,copy) NSString * macstring;



///**
// *  logo名称
// */
//@property (nonatomic,copy) NSString * logo;
///**
// *  排序号
// */
//@property (nonatomic,assign) int orderNumber;
///**
// *  用户名
// */
//@property (nonatomic,copy) NSString * username;
//
//#pragma mark - convert data 设备通信厂家代码信息
///**
// *  厂家代码对应字节值
// */
//@property (nonatomic,assign) UInt8 companyCodevalue;
///**
// *  设备类型对应字节值
// */
//@property (nonatomic,assign) UInt8 deviceTypevalue;
///**
// *  授权码对应字节值
// */
//@property (nonatomic,strong) NSData * authCodedata;
//
//#pragma mark - isonline data 局域网及远程设备是否在线
///**
// *  设备外网是否在线
// */
//@property (nonatomic,assign) BOOL remoteIsOnline;
///**
// *  设备局域网是否在线
// */
//@property (nonatomic,assign) BOOL localIsOnline;
//
//#pragma mark - lock data 设置设备数据
///**
// *  局域网设备是否被锁定
// */
//@property (nonatomic,assign) BOOL islock;
//
//#pragma mark - heartbeat data 设备心跳检测信息
///**
// *  局域网心跳时间间隔
// */
//@property (nonatomic,assign) UInt16 udpinterval;
//
//@property (nonatomic,strong) NSTimer * heartbeatTimer;
//
//@property (nonatomic,strong) NSTimer * stopheartTimer;
//
//#pragma mark - serverversion data 服务器最新版本信息
///**
// *  最新版本号长度
// */
//@property (nonatomic,assign) int newversionlen;
///**
// *  最新设备版本号 data数据
// */
//@property (nonatomic,strong) NSData * newversiondata;
///**
// *  最新设备版本号 stirng数据
// */
//@property (nonatomic,strong) NSString * newversion;
///**
// *  升级url长度
// */
//@property (nonatomic,assign) int updateurllen;
///**
// *  升级url data数据
// */
//@property (nonatomic,strong) NSData * updateurldata;
///**
// *  升级url string数据
// */
//@property (nonatomic,strong) NSString * updateurl;
//
//#pragma mark - deviceversion data 设备当前版本信息及别名
///**
// *  硬件版本长度
// */
//@property (nonatomic,assign) UInt8 hlen;
///**
// *  硬件版本号 data
// */
//@property (nonatomic,strong) NSData * hversiondata;
///**
// *  硬件版本号 str
// */
//@property (nonatomic,strong) NSString * hversionstr;
///**
// *  软件版本长度
// */
//@property (nonatomic,assign) UInt8 slen;
///**
// *  软件版本号 data
// */
//@property (nonatomic,strong) NSData * sversiondata;
///**
// *  软件版本号 str
// */
//@property (nonatomic,strong) NSString * sversionstr;
///**
// *  别名长度
// */
//@property (nonatomic,assign) UInt8 alisalen;
///**
// *  别名 data
// */
//@property (nonatomic,strong) NSData * alisadata;
///**
// *  别名 str
// */
//@property (nonatomic,strong) NSString * alisastr;
//
//
//#pragma mark - 专用控制命令数据
///**
// *  0x00主设备,是否打开
// */
//@property (nonatomic,assign) BOOL mainIsOpen;
///**
// *  0x01LED灯,是否打开
// */
//@property (nonatomic,assign) BOOL ledIsOpen;
///**
// *  0x02雾化,是否打开
// */
//@property (nonatomic,assign) BOOL atomizationIsOpen;
//
///**
// *  0x04 获取LED灯颜色(0.0.~1.0)
// */
//@property (nonatomic,assign) float Rfloatvalue;
//@property (nonatomic,assign) float Gfloatvalue;
//@property (nonatomic,assign) float Bfloatvalue;
///**
// *  LED灯 , 亮度(0.0~1.0)
// */
//@property (nonatomic,assign) float Hfloatvalue;
//@property (nonatomic,assign) float Sfloatvalue;
//@property (nonatomic,assign) float Vfloatvalue;
///**
// *  原亮度V值
// */
//@property (nonatomic,assign) float OldVfloatvalue;
///**
// *  LED灯工作模式
// */
//@property (nonatomic,assign) UInt8 ledModelvalue;
///**
// *  雾化度
// */
//@property (nonatomic,assign) UInt8 atomizationvalue;
///**
// *  倒计时
// */
//@property (nonatomic,assign) long closeTimervalue;


+ (DevicePreF * )AllInfo;

- (void)firststartcloseTimer;

- (void)startcloseTimer;

- (void)closecloseTimer;

@end
