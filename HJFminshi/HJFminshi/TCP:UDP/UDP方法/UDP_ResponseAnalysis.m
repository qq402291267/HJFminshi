//
//  UDP_ResponseAnalysis.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/9.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "UDP_ResponseAnalysis.h"
#import "SocketError.h"

static UDP_ResponseAnalysis * singleInstance = nil;

@implementation UDP_ResponseAnalysis

+ (UDP_ResponseAnalysis * )shareUDP_ResponseAnalysis{
    if (singleInstance == nil){
        singleInstance = [[UDP_ResponseAnalysis alloc] init];
    }
    return singleInstance;
}

//  分析局域网数据
//a100accf 236566c0 08000001 d1f13412 23

- (NSDictionary *)analysisLocalResponse:(NSData *)response
{
    NSLog(@"分析局域网数据,response = %@",response);
    if (response == nil) {
        return nil;
    }
//    得到cmd data命令
    UInt8 cmd = [self getProtcolCmd:response];
    
   if (cmd == 0x24)
    {
        //0x24锁定/解锁设备
        return [self getlockunlockdeviceInfo:response];
    }     else if (cmd == 0x62)
    {
        //0x62查询模块信息
        return [self getcurrentVersionInfo:response];
    }
    else if (cmd == 0x63)
    {
        //0x63设置模块别名
        return [self getsetalisaInfo:response];
    }
    else if (cmd == 0x65)
    {
        //0x65模块固件升级
        return [self getsetupdateInfo:response];
    }
    else if (cmd == 0x01)
    {
        //0x01控制设备状态
        return [self setdeviceIOstatusInfo:response];
    }
    else if (cmd == 0x03 || cmd == 0x05 || cmd == 0x07 || cmd == 0x09 || cmd == 0x0B)
    {
            //0x03设置LED灯颜色/亮度
            //0x05 设置LED灯工作模式
            //0x07 设置雾化度
            //0x09设置倒计时
            //0x0B删除倒计时
        return [self setdeviceInfo:response];
    } else if (cmd == 0x02)
    {
        //0x02查询设备状态
        return [self getgetIOstatusInfo:response];
    }
    else if (cmd == 0x04)
    {
        //0x04 获取LED灯颜色/亮度
        return [self getLedstatusInfo:response];
    }
    else if (cmd == 0x06)
    {
        //0x06 获取LED灯工作模式
        return [self getLedModelInfo:response];
    }
    else if (cmd == 0x08)
    {
        //0x08 获取雾化度
        return [self getatomizationInfo:response];
    }
    else if (cmd == 0x0A)
    {
        //0x0A查询倒计时
        return [self getclosetimeInfo:response];
    }
    else if (cmd == 0x0C)
    {
        //0x0C设置预约
        return [self setBookInfo:response];
    }
    else if (cmd == 0x0D)
    {
        //0x0D查询预约
        return [self getBookInfo:response];
    }
    else if (cmd == 0x0E)
    {
        //0x0E删除预约
        return [self getdeleteBookInfo:response];
    }
    else if (cmd == 0x0F)
    {
        //0x0F设备主动上报数据
        return [self getpushInfo:response];
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"局域网接收到未知命令,cmd = %d,response = %@", cmd, response] forKey:NSLocalizedDescriptionKey];
    SocketError * error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
    return @{@"error":[NSString stringWithFormat:@"%@",[error localizedDescription]]};
    
}

//  得到发送命令
- (UInt8)getProtcolCmd:(NSData *)response
{
    if (response.length < 17) {
        NSLog(@"getProtcolCmd:接收到错误数据");
        return 0;
    }
    UInt8 cmd = ((UInt8 *)[response bytes])[16];
    return cmd;
}

//  得到返回操作序号
- (UInt16)indexFromResponse:(NSData *)response
{
    if (response.length<12) {
        return 0;
    }
    //10 高字节   :   11 低字节
    UInt16 indexhight = ((UInt8 *)[response bytes])[10];
    UInt16 indexlower = ((UInt8 *)[response bytes])[11];
    UInt16 index = (indexhight << 8) | indexlower;
    NSLog(@"----------index------------ = %d",index);
    return index;
}

//   得到设备锁定,解锁的结果
- (NSDictionary *)getlockunlockdeviceInfo:(NSData *)response{
    @try {
        //得到帧头中设备是否锁定
        BOOL islock = [self isLockFromResponse:response];
        //得到操作结果
        UInt8 lockresult = ((UInt8 *)[response bytes])[17];
        BOOL islockdata = ((lockresult & 0x01) == 0x01);
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        NSData * macdata = [self getProtcolmac:response];
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (deviceinfo) {
            //设备存在,更新设备信息
            deviceinfo.islock = islock;
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"设备锁定,解锁时,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"islock":[NSString stringWithFormat:@"%d",islock],
                 @"lockresult":[NSString stringWithFormat:@"%d",lockresult],
                 KEY_IsLock_B:[NSNumber numberWithBool:islockdata],
                 Mac_Key_data:macdata,
                 @"error":[NSString stringWithFormat:@"%@",[error localizedDescription]]};
        
    } @catch (NSException *exception) {
        //
        NSLog(@"getlockunlockdeviceInfo>>>exception = %@",exception);
        return nil;
    }
}



//  查询模块信息0x62
- (NSDictionary *)getcurrentVersionInfo:(NSData *)response{
    @try {
        //
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        /**
         *  硬件版本长度
         */
        UInt8 hlen = ((UInt8 *)[response bytes])[17];
        /**
         *  硬件版本号 data
         */
        NSData * hversiondata = [response subdataWithRange:NSMakeRange(18, hlen)];
        /**
         *  硬件版本号 str
         */
        NSString * hversionstr = [NSString stringWithUTF8String:[hversiondata bytes]];
        /**
         *  软件版本长度
         */
        UInt8 slen = ((UInt8 *)[response bytes])[18 + hlen];
        /**
         *  软件版本号 data
         */
        NSData * sversiondata = [response subdataWithRange:NSMakeRange(19 + hlen, slen)];
        /**
         *  软件版本号 str
         */
        NSString * sversionstr = [NSString stringWithUTF8String:[sversiondata bytes]];
        
        /**
         *  别名长度
         */
        UInt8 alisalen = ((UInt8 *)[response bytes])[19 + hlen + slen];
        /**
         *  别名 data
         */
        NSData * alisadata = [response subdataWithRange:NSMakeRange(20 + hlen + slen, alisalen)];
        /**
         *  别名 str
         */
        NSString * alisastr = [NSString stringWithUTF8String:[alisadata bytes]];
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        
        NSData * macdata = [self getProtcolmac:response];
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];

        if (deviceinfo) {
            //设备存在,更新设备信息
            deviceinfo.hlen = hlen;
            deviceinfo.hversiondata = hversiondata;
            deviceinfo.hversionstr = hversionstr;
            deviceinfo.slen = slen;
            deviceinfo.sversiondata = sversiondata;
            deviceinfo.sversionstr = sversionstr;
            deviceinfo.alisalen = alisalen;
            deviceinfo.alisadata = alisadata;
            deviceinfo.alisastr = alisastr;
            //结果处理完毕
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"获取当前版本信息时,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 @"macdata":[NSString stringWithFormat:@"%@",macdata],
                 @"hlen":[NSString stringWithFormat:@"%d",hlen],
                 @"hversiondata":[NSString stringWithFormat:@"%@",hversiondata],
                 @"hversionstr":[NSString stringWithFormat:@"%@",hversionstr],
                 @"slen":[NSString stringWithFormat:@"%d",slen],
                 @"sversiondata":[NSString stringWithFormat:@"%@",sversiondata],
                 @"sversionstr":[NSString stringWithFormat:@"%@",sversionstr],
                 @"alisalen":[NSString stringWithFormat:@"%d",alisalen],
                 @"alisadata":[NSString stringWithFormat:@"%@",alisadata],
                 @"alisastr":[NSString stringWithFormat:@"%@",alisastr],
                 @"error":[NSString stringWithFormat:@"%@",[error localizedDescription]]};
        
    } @catch (NSException *exception) {
        //
        NSLog(@"getcurrentVersionInfo>>>exception = %@",exception);
        return nil;
    }
}


//  设置模块别名0x63
- (NSDictionary *)getsetalisaInfo:(NSData *)response
{
    @try {
        //
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 result = ((UInt8 *)[response bytes])[17];
        BOOL issetalisaSuccessful = ((result & 0x01) == 0x01);
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        NSData * macdata = [self getProtcolmac:response];
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (deviceinfo) {
            //设置别名完成
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"设置设备别名时,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 @"result":[NSString stringWithFormat:@"%d",result],
                 Mac_Key_data:macdata,
                 KEY_Result_B:[NSNumber numberWithBool:issetalisaSuccessful],
                 @"error":[NSString stringWithFormat:@"%@",[error localizedDescription]]};
        
    } @catch (NSException *exception) {
        //
        NSLog(@"getsetalisaInfo>>>exception = %@",exception);
        return nil;
    }
}

//  设置模块升级0x65
- (NSDictionary *)getsetupdateInfo:(NSData *)response
{
    @try {
        //
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 result = ((UInt8 *)[response bytes])[17];
        BOOL issetupdateSuccessful = ((result & 0x01) == 0x01);
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        NSData * macdata = [self getProtcolmac:response];
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (deviceinfo) {
            //设置设备升级完成
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"设置设备别名时,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 @"result":[NSString stringWithFormat:@"%d",result],
                 Mac_Key_data:macdata,
                 KEY_Result_B:[NSNumber numberWithBool:issetupdateSuccessful],
                 @"error":[NSString stringWithFormat:@"%@",[error localizedDescription]]};
        
    } @catch (NSException *exception) {
        //
        NSLog(@"getsetupdateInfo>>>exception = %@",exception);
        return nil;
    }
}

-(NSDictionary *)setdeviceInfo:(NSData *)response{
    @try {
        //
        if ([response length] < 18) {
            NSLog(@"数据不完整");
            return nil;
        }
        //0x00表示成功，0x01表示失败
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 Result = ((UInt8 *)[response bytes])[17];
        BOOL issuccess = ((Result & 0x00) == 0x00);
        NSData * macdata = [self getProtcolmac:response];
        
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 @"Result":[NSString stringWithFormat:@"%d",Result],
                 KEY_Result_B:[NSNumber numberWithBool:issuccess],
                 Mac_Key_data:macdata};
        
    } @catch (NSException *exception) {
        NSLog(@"setdeviceInfo>>>exception = %@",exception);
        return nil;
    }
}

//0x01设置设备状态,需要特别处理
- (NSDictionary *)setdeviceIOstatusInfo:(NSData *)response
{
    /*
     Request:		| 0x01 | Control_Type | Control_Status |
     Response:		| 0x01 | Control_Type | Result |
     参数说明：
     Control_Type：1 - Byte，0x00表示主设备，0x01表示LED灯，0x02表示雾化。
     Control_Status：1 - Byte，0x00表示关，0xFF表示开。
     
     Result：1-Byte,	0x00表示成功，其他值表示失败。如果是控制雾化，则返回值E0表示缺水，E1-E9表示故障，故障码含义待定
     */
    @try {
        //
        if ([response length] < 19) {
            NSLog(@"数据不完整");
            return nil;
        }
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 controlType = ((UInt8 *)[response bytes])[17];
        UInt8 result = ((UInt8 *)[response bytes])[18];
        BOOL isSuccess = (result == 0x00);
        NSData * macdata = [self getProtcolmac:response];
        //
        //......如果发生故障 ,需要发送通知
        /**
         *  ...result:0x00成功, 0xe1~0xe9表示故障
         */
        //跳转到主线程中发送通知
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DeviceError_Notification object:@{Mac_Key_data:macdata,KEY_ErrorCode_I:[NSNumber numberWithInt:result]}];
        });
        return @{@"cmd":[NSString stringWithFormat:@"0x%x",cmd],
                 @"controlType":[NSString stringWithFormat:@"0x%x",controlType],
                 @"result":[NSNumber numberWithInt:result],
                 Mac_Key_data:macdata,
                 KEY_ErrorCode_I:[NSNumber numberWithInt:result],
                 KEY_Result_B:[NSNumber numberWithBool:isSuccess]};
        
    } @catch (NSException *exception) {
        NSLog(@"setdeviceIOstatusInfo>>>exception = %@",exception);
        return nil;
    }
}

//0x02查询设备状态
- (NSDictionary *)getgetIOstatusInfo:(NSData *)response
{
    /*
     Request:		| 0x02 | Control_Type |
     Response:		| 0x02 | Control_Type | Control_Status |
     参数说明：
     Control_Type：1 - Byte，0x00表示主设备，0x01表示LED灯，0x02表示雾化。
     
     Control_Status：1 - Byte，0x00表示关，0xFF表示开
     */
    @try {
        //
        if ([response length] < 19) {
            NSLog(@"数据不完整");
            return nil;
        }
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 Control_Type = ((UInt8 *)[response bytes])[17];
        UInt8 Control_Status = ((UInt8 *)[response bytes])[18];
        BOOL isOpen = ((Control_Status & 0xff) == 0xff);
        NSData * macdata = [self getProtcolmac:response];
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (deviceinfo) {
            //更新设备数据
            [DeviceManageInstance DealWithIOStatus:deviceinfo controlType:Control_Type IOOpen:isOpen];
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"设置设备别名时,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 KEY_ControlType:[NSNumber numberWithInt:Control_Type],
                 @"Control_Status":[NSString stringWithFormat:@"%d",Control_Status],
                 KEY_IsOpen_B:[NSNumber numberWithBool:isOpen],
                 Mac_Key_data:macdata};
        
    } @catch (NSException *exception) {
        NSLog(@"getgetIOstatusInfo>>>exception = %@",exception);
        return nil;
    }
}

//0x04 获取LED灯颜色/亮度
- (NSDictionary *)getLedstatusInfo:(NSData *)response
{
    /*
     Request:	 | 0x04 |
     Response:  | 0x04 | R | G | B |
     参数说明：
     R：1 - Byte，红色值（0~255）。
     G：1 - Byte，绿色值（0~255）。
     B：1 - Byte，蓝色值（0~255）。
     */
    @try {
        //
        if ([response length] < 20) {
            NSLog(@"数据不完整");
            return nil;
        }
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 Rvalue = ((UInt8 *)[response bytes])[17];
        UInt8 Gvalue = ((UInt8 *)[response bytes])[18];
        UInt8 Bvalue = ((UInt8 *)[response bytes])[19];
        NSData * macdata = [self getProtcolmac:response];
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (deviceinfo) {
            //更新设备数据
            [DeviceManageInstance DealWithLedRGB:deviceinfo Rvalue:Rvalue Gvalue:Gvalue Bvalue:Bvalue];
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"设置设备别名时,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 @"Rvalue":[NSString stringWithFormat:@"%d",Rvalue],
                 @"Gvalue":[NSString stringWithFormat:@"%d",Gvalue],
                 @"Bvalue":[NSString stringWithFormat:@"%d",Bvalue],
                 Mac_Key_data:macdata};
        
    } @catch (NSException *exception) {
        NSLog(@"getLedstatusInfo>>>exception = %@",exception);
        return nil;
    }
}

//0x06 获取LED灯工作模式
- (NSDictionary *)getLedModelInfo:(NSData *)response
{
    /*
     Request:	 | 0x06 |
     Response:  | 0x06 | Value |
     参数说明：
     Value ：1 - Byte。Value为1时，表示设置内定模式的渐变。Value为2时，表示设置固定某种颜色与亮度
     */
    @try {
        //
        if ([response length] < 18) {
            NSLog(@"数据不完整");
            return nil;
        }
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 modelvalue = ((UInt8 *)[response bytes])[17];
        NSData * macdata = [self getProtcolmac:response];
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (deviceinfo) {
            //更新设备数据
            [DeviceManageInstance DealWithLedModel:deviceinfo modelvalue:modelvalue];
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"设置设备别名时,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 @"modelvalue":[NSString stringWithFormat:@"%d",modelvalue],
                 Mac_Key_data:macdata};
        
    } @catch (NSException *exception) {
        NSLog(@"getLedModelInfo>>>exception = %@",exception);
        return nil;
    }
}

//0x08 获取雾化度
- (NSDictionary *)getatomizationInfo:(NSData *)response
{
    @try {
        //
        if ([response length] < 18) {
            NSLog(@"数据不完整");
            return nil;
        }
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 atomizationvalue = ((UInt8 *)[response bytes])[17];
        NSData * macdata = [self getProtcolmac:response];
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (deviceinfo) {
            //更新设备数据
            [DeviceManageInstance DealWithatomization:deviceinfo atomizationvalue:atomizationvalue];
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"设置设备别名时,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 @"atomizationvalue":[NSString stringWithFormat:@"%d",atomizationvalue],
                 Mac_Key_data:macdata};
        
    } @catch (NSException *exception) {
        NSLog(@"getatomizationInfo>>>exception = %@",exception);
        return nil;
    }
}

//0x0A查询倒计时
- (NSDictionary *)getclosetimeInfo:(NSData *)response
{
    /*
     Request:		| 0x0A |
     Response:		| 0x0A | Remain_Time |
     参数说明：
     Remain_Time：4 - Byte，倒计时任务执行剩余的秒数，如：10分钟，则该值为10*60=600，表示设备在10分钟后关闭
     */
    /*
     >>>>>>>>>查询倒计时
     2015-07-16 16:32:32.224 minshi[800:907] sendToDeviceWithData:index = 42,data = <a100accf 2354be96 0800002a d1f13412 0a>,lanIP = 192.168.1.196
     2015-07-16 16:32:32.279 minshi[800:601b] 接收到UDP数据,sock = <GCDAsyncUdpSocket: 0x1dd40040>,_currentSocket = <GCDAsyncUdpSocket: 0x1dd40040>,data = <a102accf 2354be96 0c00002a d1f13412 0a00002d 22>
     */
    @try {
        //
        if ([response length] < 21) {
            NSLog(@"数据不完整");
            return nil;
        }
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 * bytes = (UInt8 *)[response bytes];
        long closeTimervalue = ((long)bytes[17] << 24) | ((long)bytes[18] << 16) | ((long)bytes[19] << 8) | (long)bytes[20];
        NSLog(@">>>>>>>>closeTimervalue = %ld",closeTimervalue);
        NSData * macdata = [self getProtcolmac:response];
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (deviceinfo) {
            //更新设备数据
            [DeviceManageInstance DealWithcloseTimer:deviceinfo closeTimervalue:closeTimervalue];
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"设置设备别名时,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 Mac_Key_data:macdata,
                 @"closeTimervalue":[NSString stringWithFormat:@"%ld",closeTimervalue]};
        
    } @catch (NSException *exception) {
        NSLog(@"getclosetimeInfo>>>exception = %@",exception);
        return nil;
    }
}


//0x0C设置预约
- (NSDictionary *)setBookInfo:(NSData *)response
{
    /*
     Request:		| 0x0C | Num | Flag | Hour | Min | Control_Status |
     Response:		| 0x0C | Num |
     参数说明：
     Num：1 - Byte，预约任务序号，取值范围为 1~10。响应包返回时，成功则返回相应序号，失败返回0。
     Flag：1 - Byte，预约任务标志。Bit7 为预约任务状态（1~开启/0~关闭） ，若单次预约事件触发，则将对应预约任务的 Bit7 清零。Bit6~0 分别对应周日到周一（Bit6 对应星期天，Bit5 对应星期六，以此类推，Bit0 对应星期一），Bit6~0 的相应位被置位，则表示该预约为重复定时，预约事件触发后 Bit7 不清零，直到用户手动清零 Bit7，否则一直重复。
     Hour：1 - Byte，小时，取值范围 0 ~ 23。
     Min：1 - Byte，分钟，取值范围 0 ~ 59。
     Control_Status：1 - Byte，0x00表示关，0xFF表示开。
     */
    @try {
        //
        if ([response length] < 18) {
            NSLog(@"数据不完整");
            return nil;
        }
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 Num = ((UInt8 *)[response bytes])[17];
        NSData * macdata = [self getProtcolmac:response];
        
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 Mac_Key_data:macdata,
                 KEY_BookNum_I:[NSNumber numberWithInt:Num]};
        
    } @catch (NSException *exception) {
        NSLog(@"setBookInfo>>>exception = %@",exception);
        return nil;
    }
}

//0x0D查询预约
- (NSDictionary *)getBookInfo:(NSData *)response
{
    /*
     Num：1 - Byte，预约任务序号，取值范围为 1~10。响应包返回时，成功则返回相应序号，失败返回0。
     Flag：1 - Byte，预约任务标志。Bit7 为预约任务状态（1~开启/0~关闭） ，若单次预约事件触发，则将对应预约任务的 Bit7 清零。Bit6~0 分别对应周日到周一（Bit6 对应星期天，Bit5 对应星期六，以此类推，Bit0 对应星期一），Bit6~0 的相应位被置位，则表示该预约为重复定时，预约事件触发后 Bit7 不清零，直到用户手动清零 Bit7，否则一直重复。
     Hour：1 - Byte，小时，取值范围 0 ~ 23。
     Min：1 - Byte，分钟，取值范围 0 ~ 59。
     Control_Status：1 - Byte，0x00表示关，0xFF表示开
     */
    @try {
        //
        //存放预约数据
        NSMutableArray * bookInfo_array = [[NSMutableArray alloc] init];
        //
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        NSUInteger datalength = [response length];
        NSLog(@"response = %@,datalength = %ld",response,(unsigned long)datalength);
        NSData * macdata = [self getProtcolmac:response];
        if (datalength > 17) {
            //有预约数据
            NSLog(@"有预约数据");
            NSData * bookdata = [response subdataWithRange:NSMakeRange(17, datalength - 17)];
            NSUInteger bookDatalegth = [bookdata length];
            NSUInteger booknumber = bookDatalegth/5;
            UInt8 * databytes = (UInt8 *)[bookdata bytes];
            NSLog(@"bookdata = %@,bookDatalegth = %ld,booknumber = %ld", bookdata, (unsigned long)bookDatalegth,(unsigned long)booknumber);
            
//            BookInfo * mbookInfo = nil;
//            for (int i = 0; i < booknumber; ++i) {
//                //
//                mbookInfo = [BookInfo BookInfo];
//                mbookInfo.Num = databytes[i * 5];
//                mbookInfo.Flag = databytes[i * 5 + 1];
//                mbookInfo.Hour = databytes[i * 5 + 2];
//                mbookInfo.Min = databytes[i * 5 + 3];
//                mbookInfo.Control_Status = databytes[i * 5 + 4];
//                mbookInfo.isOpen = ((mbookInfo.Control_Status & 0xff) == 0xff);
//                //转化时间为本地时间
//                UInt8 hour = mbookInfo.Hour;
//                UInt8 minute = mbookInfo.Min;
//                UInt8 flag = mbookInfo.Flag;
//                [Util getLocalTimeWithhour:&hour minute:&minute flag:&flag];
//                mbookInfo.Hour = hour;
//                mbookInfo.Min = minute;
//                mbookInfo.Flag = flag;
//                [bookInfo_array addObject:mbookInfo];
//            }
            //
        }
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 KEY_BookArray:bookInfo_array,
                 Mac_Key_data:macdata};
        
    } @catch (NSException *exception) {
        
        NSLog(@"getBookInfo>>>exception = %@",exception);
        return nil;
    }
}

//0x0E删除预约
- (NSDictionary *)getdeleteBookInfo:(NSData *)response
{
    /*
     Request:		| 0x0E | Num |
     Response:		| 0x0E | Num |
     参数说明：
     参见7.10节 0x0A 设置预约操作。
     命令说明：
     删除预约操作才会将此预约任务彻底删除，释放对应的 Num 资源
     */
    @try {
        //
        if ([response length] < 18) {
            NSLog(@"数据不完整");
            return nil;
        }
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 Num = ((UInt8 *)[response bytes])[17];
        NSData * macdata = [self getProtcolmac:response];
        
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 KEY_BookNum_I:[NSNumber numberWithInt:Num],
                 Mac_Key_data:macdata};
        
    } @catch (NSException *exception) {
        
        NSLog(@"getdeleteBookInfo>>>exception = %@",exception);
        return nil;
    }
}

//0x0F设备主动上报数据
- (NSDictionary *)getpushInfo:(NSData *)response
{
    @try {
        //
        if ([response length] < 19) {
            NSLog(@"数据不完整");
            return nil;
        }
        UInt8 cmd = ((UInt8 *)[response bytes])[16];
        UInt8 Event_Type = ((UInt8 *)[response bytes])[17];
        UInt8 Event_Status = ((UInt8 *)[response bytes])[18];
        
        NSData * macdata = [self getProtcolmac:response];
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (deviceinfo) {
            //处理设备上报数据
            [DeviceManageInstance DealWithDeviceUploadData:deviceinfo Event_Type:Event_Type Event_Status:Event_Status];
            //跳转到主线程中发送通知
            dispatch_async(dispatch_get_main_queue(), ^{
                //发送通知,更新设备状态
                [[NSNotificationCenter defaultCenter] postNotificationName:UpdateStatus_Notification object:@{Mac_Key_data:macdata}];
            });
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"设置设备别名时,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"cmd":[NSString stringWithFormat:@"%d",cmd],
                 @"Event_Type":[NSString stringWithFormat:@"0x%x",Event_Type],
                 @"Event_Status":[NSString stringWithFormat:@"0x%x",Event_Status],
                 Mac_Key_data:macdata};
        
    } @catch (NSException *exception) {
        NSLog(@"getpushInfo>>>exception = %@",exception);
        return nil;
    }
}
//--------------------------------------------------------------


//  判断设备是否被锁定

- (BOOL)isLockFromResponse:(NSData *)response{
    if (response.length < 2) {
        NSLog(@"isLockFromResponse:接收到错误数据");
        return NO;
    }
    UInt8 flag = ((UInt8 *)[response bytes])[1];
    BOOL islock = ((flag & 0x04) == 0x04);
    return islock;
}

//  得到信息中mac
- (NSData *)getProtcolmac:(NSData *)response{
    NSData * macdata = [response subdataWithRange:NSMakeRange(2, 6)];
    return macdata;
}



@end
