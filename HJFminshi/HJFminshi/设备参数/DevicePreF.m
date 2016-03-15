//
//  DevicePreF.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "DevicePreF.h"

@interface DevicePreF()

/**
 *  倒计时定时器
 */
@property (nonatomic,strong) NSTimer * closeTimer;

@end

@implementation DevicePreF

+ (DevicePreF * )AllInfo
{
    
    DevicePreF * allInfo = [[DevicePreF alloc] init];
    return allInfo;
}

//- (instancetype)init
//{
//    if (self = [super init]) {
//        //
//        _closeTimer = nil;
//    }
//    return self;
//}
//
//- (void)closecloseTimer
//{
//    if (_closeTimer != nil) {
//        [_closeTimer invalidate];
//        _closeTimer = nil;
//    }
//}
//
//- (void)firststartcloseTimer
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //
//        if (_closeTimer != nil) {
//            return;
//        } else {
//            [self startcloseTimer];
//        }
//    });
//}
//
//- (void)startcloseTimer
//{
//    [self closecloseTimer];
//    if (_closeTimervalue > 0) {
//        //启用定时器
//        NSLog(@">>>>>>>>>延时30s查询倒计时");
//        _closeTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(sendgetoffTimeMessageWithDeivceInfo) userInfo:nil repeats:NO];
//        
//    } else {
//        //关闭定时器
//        NSLog(@">>>>>>>>>关闭定时器");
//        NSData * senddata = [ProtocolData commonDeviceInfoWithType:deleteDeviceType_offtime index:NewIndex deviceinfo:self isremote:!self.localIsOnline];
//        [TcpUdpServiceInstance sendData:senddata deviceinfo:self complete:^(OperatorResult *resultData) {
//            //
//        }];
//    }
//}
//
//- (void)sendgetoffTimeMessageWithDeivceInfo
//{
//    //查询倒计时
//    NSLog(@">>>>>>>>>查询倒计时");
//    NSData * senddata = [ProtocolData commonDeviceInfoWithType:getDeviceInfoType_offtime index:NewIndex deviceinfo:self isremote:!self.localIsOnline];
//    [TcpUdpServiceInstance sendData:senddata deviceinfo:self complete:^(OperatorResult *resultData) {
//        if (resultData == nil) {
//            //发送失败
//            _closeTimervalue -= 30;
//        }
//        //更新UI
//        if (self.deviceView != nil) {
//            [self.deviceView ReloadData];
//        }
//        //再次发送
//        [self startcloseTimer];
//    }];
//}

//
//- (NSString *)description
//{
//    NSDictionary * dict = @{@"deviceView":(_deviceView == nil) ? @"nil":_deviceView,
//                            @"DB_id":[NSString stringWithFormat:@"%d",_DB_id],
//                            @"lanIP":[NSString stringWithFormat:@"%@",_lanIP],
//                            @"macdata":[NSString stringWithFormat:@"%@",_macdata],
//                            @"macstring":[NSString stringWithFormat:@"%@",_macstring],
//                            @"companyCode":[NSString stringWithFormat:@"%@",_companyCode],
//                            @"deviceType":[NSString stringWithFormat:@"%@",_deviceType],
//                            @"authCode":[NSString stringWithFormat:@"%@",_authCode],
//                            @"devicename":[NSString stringWithFormat:@"%@",_devicename],
//                            @"logo":[NSString stringWithFormat:@"%@",_logo],
//                            @"orderNumber":[NSString stringWithFormat:@"%d",_orderNumber],
//                            @"username":[NSString stringWithFormat:@"%@",_username]};
//    return dict.description;
//}
@end
