//
//  DeviceDataManager.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "DeviceDataManager.h"
#import "DevicePreF.h"
#import "FMDB.h"
#define Table_Device        @"device_info"
#define KEY_id              @"id"
//MAC
#define KEY_mac             @"mac"
//厂家代码
#define KEY_companyCode     @"companyCode"
//设备类型
#define KEY_deviceType      @"deviceType"
//授权码
#define KEY_authCode        @"authCode"
//设备名称
#define KEY_devicename      @"devicename"
//logo
#define KEY_logo            @"logo"
//排序号
#define KEY_orderNumber     @"orderNumber"
//用户名
#define KEY_username        @"username"
@interface DeviceDataManager ()

@property (nonatomic,strong) NSString * databasefilepath;
@property (nonatomic,strong) FMDatabase * database;

@end

static DeviceDataManager * singleInstance = nil;

@implementation DeviceDataManager
+ (DeviceDataManager *)shareDeviceDataManager
{
    if (singleInstance == nil) {
        singleInstance = [[DeviceDataManager alloc] init];
    }
    return singleInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        //得到数据库文件存放的路径
        [self getDBFilepath];
        //创建数据库
        [self CreateDataBase];
        //创建数据库设备表
        [self CreateDeviceTable];
        //创建数据库推送信息表
//        [self CreatePushMsgTable];
    }
    return self;
}

- (void)getDBFilepath
{
    NSArray *documentPath =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [documentPath objectAtIndex:0];
    _databasefilepath = [path stringByAppendingPathComponent:@"db_test.sqlite"];
    
    if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
        [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"databasefilepath的路径 = %@",self.databasefilepath]];
    }
}


#pragma mark - 数据库初始化并创建表格
/**
 * 创建数据库
 */
- (void)CreateDataBase
{
    _database = [[FMDatabase alloc] initWithPath:_databasefilepath];
    //为数据库设置缓存,提高查询效率
    _database.shouldCacheStatements = YES;
}

/**
 *  创建数据库设备表
 */
- (void)CreateDeviceTable
{
    [_database open];
    [self excuteCreateTableSql];
    [_database close];
}

/**
 *  执行建表格语句
 */
- (void)excuteCreateTableSql
{
    //    储存格式 mac，companyCode deviceType authCode devicename logo orderNumber（int） username
    
    NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id INTEGER PRIMARY KEY AUTOINCREMENT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ TEXT,%@ INTEGER,%@ TEXT);",Table_Device,KEY_mac,KEY_companyCode,KEY_deviceType,KEY_authCode,KEY_devicename,KEY_logo,KEY_orderNumber,KEY_username];
    
    if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
        [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"创建存储格式＝%@",sql]];
    }

    NSError * error = nil;
    if (![_database executeUpdate:sql withErrorAndBindings:&error]) {
        if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
            [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"表格创建失败:error = %@,sql = %@",error,sql]];
        }
    }
}

#pragma mark - 数据库操作
/**
 *  插入数据到数据库
 *
 *  @param deviceinfo 设备信息
 */
- (void)insertIntoDataBase:(DevicePreF *)deviceinfo
{
    //打开数据库
    [_database open];
    //开始插入数据
//    [self showMsg:[NSString stringWithFormat:@"insertIntoDataBase:deviceinfo = %@",deviceinfo]];
    NSString * sql = [NSString stringWithFormat:@"INSERT INTO %@(%@,%@,%@,%@,%@,%@,%@,%@) VALUES('%@','%@','%@','%@','%@','%@',%d,'%@');",Table_Device,KEY_mac,KEY_companyCode,KEY_deviceType,KEY_authCode,KEY_devicename,KEY_logo,KEY_orderNumber,KEY_username,deviceinfo.macAddress,deviceinfo.companyCode,deviceinfo.deviceType,deviceinfo.authCode,deviceinfo.deviceName,deviceinfo.imageName,deviceinfo.orderNumber,deviceinfo.username];
    
    if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
        [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"插入数据:sql = %@",sql]];
    }

    NSError * error = nil;
    if (![_database executeUpdate:sql withErrorAndBindings:&error]) {
        if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
            [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"插入数据失败:error = %@,sql = %@",error,sql]];}
    }
    [_database close];
}

/**
 *  根据设备mac地址得到设备数据库id
 *
 *  @param macstring mac
 *
 *  @return DB_id
 */
- (int)getDetailRowDB_idWithmac:(NSString *)macstring username:(NSString *)username
{
    int DB_id = 0;
    [_database open];
    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@';",Table_Device, KEY_mac, macstring,KEY_username, username];
    
    if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
        [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"getDetailRowDB_idWithmac:sql = %@",sql]];}
    
    FMResultSet * resultSet = [_database executeQuery:sql];
    if ([resultSet next]) {
        DB_id = [resultSet intForColumn:KEY_id];
    }
    [_database close];
    return DB_id;
}

/**
 *  根据设备mac地址得到设备数据库信息
 *
 *  @param macstring mac
 *
 *  @return DevicePreF
 */
- (DevicePreF *)getdeviceInfo:(NSString *)macstring username:(NSString *)username
{
    DevicePreF * deviceinfo = nil;
    [_database open];
    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@='%@';",Table_Device, KEY_mac, macstring,KEY_username, username];
    if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
        [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"getdeviceInfo:sql = %@",sql]];}
    FMResultSet * resultSet = [_database executeQuery:sql];
    if ([resultSet next]) {
        deviceinfo = [[DevicePreF alloc] init];
        deviceinfo.DB_id = [resultSet intForColumn:KEY_id];
        deviceinfo.macAddress = [resultSet stringForColumn:KEY_mac];
        deviceinfo.companyCode = [resultSet stringForColumn:KEY_companyCode];
        deviceinfo.deviceType = [resultSet stringForColumn:KEY_deviceType];
        deviceinfo.authCode = [resultSet stringForColumn:KEY_authCode];
        deviceinfo.deviceName = [resultSet stringForColumn:KEY_devicename];
        deviceinfo.imageName = [resultSet stringForColumn:KEY_logo];
        deviceinfo.orderNumber = [resultSet intForColumn:KEY_orderNumber];
        deviceinfo.username = [resultSet stringForColumn:KEY_username];
    }
    [_database close];
    return deviceinfo;
}

/**
 *  删除数据库中设备
 *
 *  @param deviceinfo 设备信息
 */
- (void)deleteDataBase:(DevicePreF *)deviceinfo
{
    [_database open];
    NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=%d AND %@='%@';",Table_Device,KEY_id,deviceinfo.DB_id, KEY_username, deviceinfo.username];

    if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
        [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"deleteDataBase:sql = %@",sql]];}
    NSError * error = nil;
    if (![_database executeUpdate:sql withErrorAndBindings:&error]) {
        if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
            [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"删除设备失败:error = %@,sql = %@", error, sql]];}
    }
    [_database close];
}

/**
 *  更新设备信息,但不更新mac地址
 *
 *  @param deviceinfo 设备信息
 */
- (void)updateDataBase:(DevicePreF *)deviceinfo
{
    [_database open];
    NSString * sql = [NSString stringWithFormat:@"UPDATE %@ SET %@='%@',%@='%@',%@='%@',%@='%@',%@='%@',%@=%d WHERE %@=%d AND %@='%@';",Table_Device,KEY_companyCode,deviceinfo.companyCode,KEY_deviceType,deviceinfo.deviceType,KEY_authCode,deviceinfo.authCode,KEY_devicename,deviceinfo.deviceName,KEY_logo,deviceinfo.imageName,KEY_orderNumber,deviceinfo.orderNumber,KEY_id,deviceinfo.DB_id, KEY_username, deviceinfo.username];
    
    if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
        [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"updateDataBase:sql = %@",sql]];}
    
    NSError * error = nil;
    if (![_database executeUpdate:sql withErrorAndBindings:&error]) {
        
        if ([self.DeviceDataManagerDelegate respondsToSelector:@selector(DeviceDataManagerNSLogString:)]) {
            [self.DeviceDataManagerDelegate DeviceDataManagerNSLogString:[NSString stringWithFormat:@"设备更新失败,error = %@,sql = %@",error,sql]];}

    }
    [_database close];
}

//----------------------保存推送消息----------------------------
///**
// *  创建数据库设备表
// */
//- (void)CreatePushMsgTable
//{
//    [_database open];
//    [self excuteCreatePushTableSql];
//    [_database close];
//}
//
///**
// *  执行建表格语句
// */
//- (void)excuteCreatePushTableSql
//{
//    NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@ INTEGER PRIMARY KEY AUTOINCREMENT,%@ INTEGER,%@ INTEGER,%@ TEXT,%@ INTEGER);",Table_PushMsg,KEY_pushid,KEY_receivetime,KEY_xgpushmsgtime,KEY_pushmsgcontext,KEY_Isviewed];
//    [self showMsg:[NSString stringWithFormat:@"excuteCreateTableSql:sql = %@",sql]];
//    NSError * error = nil;
//    if (![_database executeUpdate:sql withErrorAndBindings:&error]) {
//        [self showMsg:[NSString stringWithFormat:@"表格创建失败:error = %@,sql = %@",error,sql]];
//    }
//}
//
////插入数据
//- (void)insertPushIntoDataBase:(PushMsgInfo *)pushinfo
//{
//    //打开数据库
//    [_database open];
//    //开始插入数据
//    [self showMsg:[NSString stringWithFormat:@"insertPushIntoDataBase:deviceinfo = %@",pushinfo]];
//    NSString * sql = [NSString stringWithFormat:@"INSERT INTO %@(%@,%@,%@,%@) VALUES(%lld,%lld,'%@',%d);",Table_PushMsg,KEY_receivetime, KEY_xgpushmsgtime,KEY_pushmsgcontext,KEY_Isviewed,pushinfo.receivepushTime,pushinfo.XG_pushTime, pushinfo.msgContext,pushinfo.IsViewed];
//    [self showMsg:[NSString stringWithFormat:@"insertPushIntoDataBase:sql = %@",sql]];
//    NSError * error = nil;
//    if (![_database executeUpdate:sql withErrorAndBindings:&error]) {
//        [self showMsg:[NSString stringWithFormat:@"插入数据失败:error = %@,sql = %@",error,sql]];
//    }
//    [_database close];
//}
//
////更新推送数据
//- (void)UpdatepushDB:(PushMsgInfo *)msgInfo
//{
//    [_database open];
//    NSString * sql = [NSString stringWithFormat:@"UPDATE %@ SET %@=%d WHERE %@=%d;",Table_PushMsg,KEY_Isviewed,msgInfo.IsViewed,KEY_pushid,msgInfo.DB_id];
//    [self showMsg:[NSString stringWithFormat:@"updateDataBase:sql = %@",sql]];
//    NSError * error = nil;
//    if (![_database executeUpdate:sql withErrorAndBindings:&error]) {
//        [self showMsg:[NSString stringWithFormat:@"更新失败,error = %@,sql = %@",error,sql]];
//    }
//    [_database close];
//}
//
////查询所有数据
//- (NSMutableArray *)getAllpushInfo
//{
//    NSMutableArray * pushInfoArray = [NSMutableArray array];
//    PushMsgInfo * pushInfo = nil;
//    [_database open];
//    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE 1;",Table_PushMsg];
//    [self showMsg:[NSString stringWithFormat:@"getdeviceInfo:sql = %@",sql]];
//    FMResultSet * resultSet = [_database executeQuery:sql];
//    while ([resultSet next]) {
//        int DB_id = [resultSet intForColumn:KEY_pushid];
//        long long receiveTime = [resultSet longLongIntForColumn:KEY_receivetime];
//        long long xgpushTime = [resultSet longLongIntForColumn:KEY_xgpushmsgtime];
//        NSString * pushMsg = [resultSet stringForColumn:KEY_pushmsgcontext];
//        BOOL isViewed = [resultSet boolForColumn:KEY_Isviewed];
//        pushInfo = [PushMsgInfo msgInfoWith:DB_id receivepushTime:receiveTime XG_pushTime:xgpushTime msgContext:pushMsg IsViewed:isViewed];
//        [pushInfoArray addObject:pushInfo];
//    }
//    NSLog(@"getAllpushInfo = %@",pushInfoArray);
//    [_database close];
//    return pushInfoArray;
//}
//
//------------------------------------------------------------



@end
