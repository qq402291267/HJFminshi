//
//  DeviceManage.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DevicePreF.h"
#define DeviceManageInstance [DeviceManage shareAllDevice]
@interface DeviceManage : NSObject
/**
 *  保存所有设备信息
 */
@property (nonatomic,strong) NSMutableArray * device_array;

+ (DeviceManage *)shareAllDevice;
//
- (DevicePreF *)getDevicePreFWithmac:(NSData *)mac;
//
//- (BOOL)IsExistsWithmac:(NSData *)mac;

- (BOOL)IsExistsWithmacstr:(NSString *)macstr;

//转化数据
- (void)convertDeviceinfo:(DevicePreF *)deviceinfo;

//处理设备IO状态
- (void)DealWithIOStatus:(DevicePreF *)deviceinfo controlType:(UInt8)controlType IOOpen:(BOOL)IOOpen;
//处理LED RGB值
- (void)DealWithLedRGB:(DevicePreF *)deviceinfo Rvalue:(UInt8)Rvalue Gvalue:(UInt8)Gvalue Bvalue:(UInt8)Bvalue;
//处理LED 模式
- (void)DealWithLedModel:(DevicePreF *)deviceinfo modelvalue:(UInt8)modelvalue;
//处理雾化度
- (void)DealWithatomization:(DevicePreF *)deviceinfo atomizationvalue:(UInt8)atomizationvalue;
//倒计时
- (void)DealWithcloseTimer:(DevicePreF *)deviceinfo closeTimervalue:(long)closeTimervalue;
//处理设备上报数据
- (void)DealWithDeviceUploadData:(DevicePreF *)deviceinfo Event_Type:(UInt8)Event_Type Event_Status:(UInt8)Event_Status;

@end
