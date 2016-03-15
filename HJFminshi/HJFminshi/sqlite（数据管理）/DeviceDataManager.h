//
//  DeviceDataManager.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DeviceDataManagerInstance [DeviceDataManager shareDeviceDataManager]

@protocol DeviceDataManagerDelegate <NSObject>
@required
//DeviceDataManager打印信息
-(void)DeviceDataManagerNSLogString:(NSString*)str;
@end

@class DevicePreF;

@interface DeviceDataManager : NSObject

@property (nonatomic,weak) id<DeviceDataManagerDelegate> DeviceDataManagerDelegate;

+ (DeviceDataManager*)shareDeviceDataManager;

/**
 *  插入数据到数据库
 *
 *  @param deviceinfo 设备信息
 */
- (void)insertIntoDataBase:(DevicePreF *)deviceinfo;
/**
 *  根据设备mac地址得到设备数据库id
 *
 *  @param macstring mac
 *
 *  @return DB_id
 */
- (int)getDetailRowDB_idWithmac:(NSString *)macstring username:(NSString *)username;

/**
 *  根据设备mac地址得到设备数据库信息
 *
 *  @param macstring mac
 *
 *  @return DevicePreF
 */
- (DevicePreF *)getdeviceInfo:(NSString *)macstring username:(NSString *)username;

/**
 *  删除数据库中设备
 *
 *  @param deviceinfo 设备信息
 */
- (void)deleteDataBase:(DevicePreF *)deviceinfo;

/**
 *  更新设备信息
 *
 *  @param deviceinfo 设备信息
 */
- (void)updateDataBase:(DevicePreF *)deviceinfo;

//----------------------保存推送消息----------------------------
////插入数据
//- (void)insertPushIntoDataBase:(PushMsgInfo *)pushinfo;
//
////更新推送数据
//- (void)UpdatepushDB:(PushMsgInfo *)msgInfo;
//
////查询所有数据
//- (NSMutableArray *)getAllpushInfo;

//------------------------------------------------------------

@end
