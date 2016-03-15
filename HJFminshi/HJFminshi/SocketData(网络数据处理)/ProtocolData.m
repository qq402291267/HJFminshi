//
//  ProtocolData.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "ProtocolData.h"
#import "HTTPcomMethod.h"

@implementation ProtocolData

#pragma mark - tcp

#if Type_Protcol == minshi_Protcol
//敏识
/**
 *  与服务器通信
 *  敏识项目,Len为一个字节,有预置位,且设备类型/厂家代码/授权码,顺序不一样
 *  三星项目,Len长度有两个字节(8,9),没有Reversed预留位,且设备类型/厂家代码/授权码,顺序不一样
 *
 *  @param data       设备控制部分命令
 *  @param index      通信序号
 *  @param deviceinfo app操作时传入nil,否则传入单点操作设备信息,1.帧头mac. 2.厂家代码等
 *
 *  @return NSData组包后数据
 */
+ (NSData *)tcpProtocolDataWithData:(NSData *)data index:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo
{
    //发送帧头非阴影部分数据
    UInt8 preData[9];      //敏识格式,此部分因为Len长度改变长度为1
    preData[0] = 0xA1;
    preData[1] = 0x00;
    NSData * macdata = nil;
    if (deviceinfo && deviceinfo.macdata) {
        macdata = deviceinfo.macdata;
    } else {
        UInt8 macs[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
        macdata = [NSData dataWithBytes:macs length:6];
    }
    //添加mac地址到->帧头非阴影部分数据
    memcpy(preData + 2, [macdata bytes], [macdata length]);
    
    //帧头阴影部分数据
    UInt8 shadow[7];       //这里阴影部分长度也不一样
    shadow[0] = 0x00;
    shadow[1] = ((index >> 8)&0xff);  //高字节
    shadow[2] = (index&0xff);  //低字节
    //设备单点控制,需传入设备厂家代码等信息
    if (deviceinfo) {
        //设备类型/厂家代码/授权码:2字节
        shadow[3] = deviceinfo.deviceTypevalue;
        shadow[4] = deviceinfo.companyCodevalue;
        memcpy(shadow + 5, [deviceinfo.authCodedata bytes], [deviceinfo.authCodedata length]);
        
    } else {
        //设备类型/厂家代码/授权码:2字节
        shadow[3] = 0xD1;  //设备类型
        shadow[4] = 0xF1;  //厂家代码
        shadow[5] = 0x34;  //授权码:2字节
        shadow[6] = 0x12;
    }
    //得到阴影部分数据
    NSMutableData * shadowdata = [[NSMutableData alloc] initWithBytes:shadow length:7];   //敏识格式,阴影部分有一个Reversed预留字节
    [shadowdata appendData:data];
    
    //敏识格式   //这里阴影部分长度占一个字节
    preData[8] = (UInt8)shadowdata.length;
    //得到数据
    NSMutableData *protocolData =[[NSMutableData alloc] init];
    [protocolData appendBytes:preData length:9];  //敏识格式
    [protocolData appendData:shadowdata];
    return protocolData;
}
#elif Type_Protcol == sanxing_Protcol
//三星
/**
 *  与服务器通信
 *  三星项目,Len长度有两个字节(8,9),没有Reversed预留位,且设备类型/厂家代码/授权码,顺序不一样
 *
 *  @param data       设备控制部分命令
 *  @param index      通信序号
 *  @param deviceinfo app操作时传入nil,否则传入单点操作设备信息,1.帧头mac. 2.厂家代码等
 *
 *  @return NSData组包后数据
 */
+ (NSData *)tcpProtocolDataWithData:(NSData *)data index:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo
{
    //发送帧头非阴影部分数据
    UInt8 preData[10];     //三星格式,此部分因为Len长度改变长度加1
    preData[0] = 0xA1;
    preData[1] = 0x00;
    NSData * macdata = nil;
    if (deviceinfo && deviceinfo.macdata) {
        macdata = deviceinfo.macdata;
    } else {
        UInt8 macs[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
        macdata = [NSData dataWithBytes:macs length:6];
    }
    //添加mac地址到->帧头非阴影部分数据
    memcpy(preData + 2, [macdata bytes], [macdata length]);
    
    //帧头阴影部分数据
    UInt8 shadow[6];       //这里阴影部分长度也不一样
    shadow[0] = ((index >> 8)&0xff);  //高字节
    shadow[1] = (index&0xff);  //低字节
    //设备单点控制,需传入设备厂家代码等信息
    if (deviceinfo) {
        //设备类型/厂家代码/授权码:2字节
        shadow[2] = deviceinfo.deviceTypevalue;
        shadow[3] = deviceinfo.companyCodevalue;
        memcpy(shadow + 4, [deviceinfo.authCodedata bytes], [deviceinfo.authCodedata length]);
        
    } else {
        //设备类型/厂家代码/授权码:2字节
        shadow[2] = 0xDA;  //设备类型
        shadow[3] = 0xAA;  //厂家代码
        shadow[4] = 0xCA;  //授权码:2字节
        shadow[5] = 0x75;
    }
    //得到阴影部分数据
    NSMutableData * shadowdata = [[NSMutableData alloc] initWithBytes:shadow length:6];   //三星格式,阴影部分没有一个Reversed预留字节
    [shadowdata appendData:data];
    
    //三星格式   //这里阴影部分长度占两个字节
    //得到阴影部分数据长度
    UInt16 shadowlength = [shadowdata length];
    preData[8] = (shadowlength >> 8) & 0xff;
    preData[9] = shadowlength & 0xff;
    //得到数据
    NSMutableData *protocolData =[[NSMutableData alloc] init];
    [protocolData appendBytes:preData length:10];  //三星格式,帧头长度有变化
    [protocolData appendData:shadowdata];
    return protocolData;
}
#endif


/**
 *  获取工作服务器
 *
 *  @param index    通信序号
 *
 *  @return NSData
 */
+ (NSData *)workingServer:(UInt16)index
{
    UInt8 data[1] = {0x81};
    NSData * cmddata = [NSData dataWithBytes:data length:1];
    return [self tcpProtocolDataWithData:cmddata index:index deviceinfo:nil];
}

/**
 *  请求接入Tcp服务器
 *
 *  @param index    通信序号
 *  @param username 用户名
 *  @param password 密码
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)requestTcp:(UInt16)index username:(NSString *)username password:(NSString *)password
{
    NSData * usernamedata = [username dataUsingEncoding:NSUTF8StringEncoding];
    NSString * md5pwd = [HTTPcomMethod getPassWordWithmd5:password];
    NSData * passworddata = [md5pwd dataUsingEncoding:NSUTF8StringEncoding];
    UInt8 usernamelen = [usernamedata length];
    UInt8 passwordlen = [passworddata length];
    //package data
    UInt8 cmd[1] = {0x82};
    NSMutableData * cmddata = [[NSMutableData alloc] initWithBytes:cmd length:1];
    UInt8 cmd_userlen[1] = {usernamelen};
    UInt8 cmd_passwordlen[1] = {passwordlen};
    
    //JLen:1 – Byte,表示JoinCode接入码的长度。
    //JoinCode:N – Byte,设备接入服务器的接入码,接入码是服务器用来校验 接入设备的合法性
#if Type_Protcol == minshi_Protcol
    //添加app接入码
    UInt8 JLen[1] = {0x06};
    UInt8 JoinCode[6] = {0x68,0xF7,0x28,0x1C,0x94,0x4E};
    //接入码长度
    [cmddata appendBytes:JLen length:1];
    //接入码
    [cmddata appendBytes:JoinCode length:6];
#elif Type_Protcol == sanxing_Protcol
    //添加app接入码
    UInt8 JLen[1] = {0x06};
    UInt8 JoinCode[6] = {0x41,0xB0,0xAC,0x2D,0xC3,0x55};
    //接入码长度
    [cmddata appendBytes:JLen length:1];
    //接入码
    [cmddata appendBytes:JoinCode length:6];
#endif
    [cmddata appendBytes:cmd_userlen length:1];
    [cmddata appendData:usernamedata];
    [cmddata appendBytes:cmd_passwordlen length:1];
    [cmddata appendData:passworddata];
    return [self tcpProtocolDataWithData:cmddata index:index deviceinfo:nil];
}

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
+ (NSData *)subscribetoeventsWithdeviceinfo:(DevicePreF *)deviceinfo index:(UInt16)index issub:(BOOL)issub cmd:(UInt8)cmd
{
    UInt8 cmds[4];
    cmds[0] = 0x83;
    if (issub) {
        cmds[1] = 0x01;
    } else {
        cmds[1] = 0x00;
    }
    cmds[2] = cmd;
    cmds[3] = 0x00;
    NSData * cmddata = [NSData dataWithBytes:cmds length:4];
    return [self tcpProtocolDataWithData:cmddata index:index deviceinfo:deviceinfo];
}

/**
 *  查询设备是否在线0x84
 *
 *  @param deviceinfo 需查询的设备
 *  @param index      通信序号
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)getonlinestatusWithdeviceinfo:(DevicePreF *)deviceinfo index:(UInt16)index
{
    UInt8 cmds[1] = {0x84};
    NSData * cmddata = [NSData dataWithBytes:cmds length:1];
    return [self tcpProtocolDataWithData:cmddata index:index deviceinfo:deviceinfo];
}

/**
 *  获取设备最新固件版本信息0x86
 *
 *  @param deviceinfo 需查询的设备
 *  @param index      通信序号
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)getnewversionWithdeviceinfo:(DevicePreF *)deviceinfo index:(UInt16)index
{
    UInt8 cmds[1] = {0x86};
    NSData * cmddata = [NSData dataWithBytes:cmds length:1];
    return [self tcpProtocolDataWithData:cmddata index:index deviceinfo:deviceinfo];
}

/**
 *  发送心跳包到服务器
 *
 *  @param index    通信序号
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)heartBeatserver:(UInt16)index
{
    UInt8 cmd[1] = {0x61};
    NSData * cmddata = [NSData dataWithBytes:cmd length:1];
    return [self tcpProtocolDataWithData:cmddata index:index deviceinfo:nil];
}

#pragma mark - udp
#if Type_Protcol == minshi_Protcol
/**
 *  组包命令
 *
 *  @param data       命令数据
 *  @param index      通信序号
 *  @param deviceinfo 设备信息
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)udpprotocolDataWithData:(NSData *)data index:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo
{
    //发送帧头非阴影部分数据
    UInt8 preData[9];
    preData[0] = 0xA1;
    preData[1] = 0x00;
    NSData * macdata = nil;
    if (deviceinfo && deviceinfo.macdata) {
        macdata = deviceinfo.macdata;
    } else {
        UInt8 macs[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
        macdata = [NSData dataWithBytes:macs length:6];
    }
    //添加mac地址到->帧头非阴影部分数据
    memcpy(preData + 2, [macdata bytes], [macdata length]);
    
    //帧头阴影部分数据
    UInt8 shadow[7];
    shadow[0] = 0x00;
    shadow[1] = ((index >> 8)&0xff);  //高字节
    shadow[2] = (index&0xff);  //低字节
    //与设备通信
    if (deviceinfo) {
        //设备类型/厂家代码/授权码:2字节
        shadow[3] = deviceinfo.deviceTypevalue;
        shadow[4] = deviceinfo.companyCodevalue;
        memcpy(shadow + 5, [deviceinfo.authCodedata bytes], [deviceinfo.authCodedata length]);
        
    } else {
        //设备类型/厂家代码/授权码:2字节
        shadow[3] = 0xD1;  //设备类型
        shadow[4] = 0xF1;  //厂家代码
        shadow[5] = 0x34;  //授权码:2字节
        shadow[6] = 0x12;
    }
    //得到阴影部分数据
    NSMutableData * shadowdata = [[NSMutableData alloc] initWithBytes:shadow length:7];
    [shadowdata appendData:data];
    //得到阴影部分数据长度
    preData[8] = (UInt8)shadowdata.length;
    
    //得到数据
    NSMutableData *protocolData =[[NSMutableData alloc] init];
    [protocolData appendBytes:preData length:9];
    [protocolData appendData:shadowdata];
    return protocolData;
}

/**
 *  组包设备是否锁定命令
 *
 *  @param data       命令数据
 *  @param islock     设置设备是否锁定
 *  @param index      通信序号
 *  @param deviceinfo 设备信息
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)udpprotocollockunlockWithData:(NSData *)data lock:(BOOL)islock index:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo
{
    //发送帧头非阴影部分数据
    UInt8 preData[9];
    preData[0] = 0xA1;
    preData[1] = 0x00;
    //设备是否锁定
    if (islock) {
        preData[1] |= 0x04;
    } else {
        preData[1] |= 0x00;
    }
    
    NSData * macdata = nil;
    if (deviceinfo && deviceinfo.macdata) {
        macdata = deviceinfo.macdata;
    } else {
        UInt8 macs[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
        macdata = [NSData dataWithBytes:macs length:6];
    }
    //添加mac地址到->帧头非阴影部分数据
    memcpy(preData + 2, [macdata bytes], [macdata length]);
    
    //帧头阴影部分数据
    UInt8 shadow[7];
    shadow[0] = 0x00;
    shadow[1] = ((index >> 8)&0xff);  //高字节
    shadow[2] = (index&0xff);  //低字节
    //与设备通信
    if (deviceinfo) {
        //设备类型/厂家代码/授权码:2字节
        shadow[3] = deviceinfo.deviceTypevalue;
        shadow[4] = deviceinfo.companyCodevalue;
        memcpy(shadow + 5, [deviceinfo.authCodedata bytes], [deviceinfo.authCodedata length]);
        
    } else {
        //设备类型/厂家代码/授权码:2字节
        shadow[3] = 0xD1;  //设备类型
        shadow[4] = 0xF1;  //厂家代码
        shadow[5] = 0x34;  //授权码:2字节
        shadow[6] = 0x12;
    }
    //得到阴影部分数据
    NSMutableData * shadowdata = [[NSMutableData alloc] initWithBytes:shadow length:7];
    [shadowdata appendData:data];
    //得到阴影部分数据长度
    preData[8] = (UInt8)shadowdata.length;
    
    //得到数据
    NSMutableData *protocolData =[[NSMutableData alloc] init];
    [protocolData appendBytes:preData length:9];
    [protocolData appendData:shadowdata];
    return protocolData;
}
#elif Type_Protcol == sanxing_Protcol
/**
 *  组包命令
 *
 *  @param data       命令数据
 *  @param index      通信序号
 *  @param deviceinfo 设备信息
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)udpprotocolDataWithData:(NSData *)data index:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo
{
    //发送帧头非阴影部分数据
    UInt8 preData[10];
    preData[0] = 0xA1;
    preData[1] = 0x00;
    NSData * macdata = nil;
    if (deviceinfo && deviceinfo.macdata) {
        macdata = deviceinfo.macdata;
    } else {
        UInt8 macs[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
        macdata = [NSData dataWithBytes:macs length:6];
    }
    //添加mac地址到->帧头非阴影部分数据
    memcpy(preData + 2, [macdata bytes], [macdata length]);
    
    //帧头阴影部分数据
    UInt8 shadow[6];
    shadow[0] = ((index >> 8)&0xff);  //高字节
    shadow[1] = (index&0xff);  //低字节
    //与设备通信
    if (deviceinfo) {
        //设备类型/厂家代码/授权码:2字节
        shadow[2] = deviceinfo.deviceTypevalue;
        shadow[3] = deviceinfo.companyCodevalue;
        memcpy(shadow + 4, [deviceinfo.authCodedata bytes], [deviceinfo.authCodedata length]);
        
    } else {
        //设备类型/厂家代码/授权码:2字节
        shadow[2] = 0xDA;  //设备类型
        shadow[3] = 0xAA;  //厂家代码
        shadow[4] = 0xCA;  //授权码:2字节
        shadow[5] = 0x75;
    }
    //得到阴影部分数据
    NSMutableData * shadowdata = [[NSMutableData alloc] initWithBytes:shadow length:6];
    [shadowdata appendData:data];
    //得到阴影部分数据长度
    UInt16 shadowlenght = shadowdata.length;
    preData[8] = (shadowlenght >> 8) & 0xff;
    preData[9] = shadowlenght & 0xff;
    //得到数据
    NSMutableData *protocolData =[[NSMutableData alloc] init];
    [protocolData appendBytes:preData length:10];
    [protocolData appendData:shadowdata];
    return protocolData;
}

/**
 *  组包设备是否锁定命令
 *
 *  @param data       命令数据
 *  @param islock     设置设备是否锁定
 *  @param index      通信序号
 *  @param deviceinfo 设备信息
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)udpprotocollockunlockWithData:(NSData *)data lock:(BOOL)islock index:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo
{
    //发送帧头非阴影部分数据
    UInt8 preData[10];
    preData[0] = 0xA1;
    //设备是否锁定
    if (islock) {
        preData[1] |= 0x04;
    } else {
        preData[1] |= 0x00;
    }
    NSData * macdata = nil;
    if (deviceinfo && deviceinfo.macdata) {
        macdata = deviceinfo.macdata;
    } else {
        UInt8 macs[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
        macdata = [NSData dataWithBytes:macs length:6];
    }
    //添加mac地址到->帧头非阴影部分数据
    memcpy(preData + 2, [macdata bytes], [macdata length]);
    
    //帧头阴影部分数据
    UInt8 shadow[6];
    shadow[0] = ((index >> 8)&0xff);  //高字节
    shadow[1] = (index&0xff);  //低字节
    //与设备通信
    if (deviceinfo) {
        //设备类型/厂家代码/授权码:2字节
        shadow[2] = deviceinfo.deviceTypevalue;
        shadow[3] = deviceinfo.companyCodevalue;
        memcpy(shadow + 4, [deviceinfo.authCodedata bytes], [deviceinfo.authCodedata length]);
        
    } else {
        //设备类型/厂家代码/授权码:2字节
        shadow[2] = 0xDA;  //设备类型
        shadow[3] = 0xAA;  //厂家代码
        shadow[4] = 0xCA;  //授权码:2字节
        shadow[5] = 0x75;
    }
    //得到阴影部分数据
    NSMutableData * shadowdata = [[NSMutableData alloc] initWithBytes:shadow length:6];
    [shadowdata appendData:data];
    //得到阴影部分数据长度
    UInt16 shadowlenght = shadowdata.length;
    preData[8] = (shadowlenght >> 8) & 0xff;
    preData[9] = shadowlenght & 0xff;
    //得到数据
    NSMutableData *protocolData =[[NSMutableData alloc] init];
    [protocolData appendBytes:preData length:10];
    [protocolData appendData:shadowdata];
    return protocolData;
}
//end
#endif



/**
 *  udp发现设备0x23
 *
 *  @param index      通信序号
 *  @param deviceinfo 设备信息
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)discorverdevice:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo
{
    UInt8 cmd[1] = {0x23};
    NSData * cmddata = [NSData dataWithBytes:cmd length:1];
    return [self udpprotocolDataWithData:cmddata index:index deviceinfo:deviceinfo];
}

/**
 *  udp锁定解锁设备0x24
 *
 *  @param index      通信序号
 *  @param islock     是否锁定
 *  @param deviceinfo 设备信息
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)lockunlockdevice:(UInt16)index lock:(BOOL)islock deviceinfo:(DevicePreF *)deviceinfo
{
    UInt8 cmd[1] = {0x24};
    NSData * cmddata = [NSData dataWithBytes:cmd length:1];
    NSData * resultdata = [self udpprotocollockunlockWithData:cmddata lock:islock index:index deviceinfo:deviceinfo];
    return resultdata;
}

/**
 *  udp发送心跳包0x61
 *
 *  @param index      通信序号
 *  @param deviceinfo 设备信息
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)heartBeatLocal:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo
{
    NSTimeInterval currenttime = [[NSDate date] timeIntervalSince1970];
    long time = (long)currenttime;
    UInt8 cmds[5];
    cmds[0] = 0x61;
    cmds[1] = (time >> 24) & 0xff;
    cmds[2] = (time >> 16) & 0xff;
    cmds[3] = (time >> 8) & 0xff;
    cmds[4] = time & 0xff;
    NSData * cmddata = [NSData dataWithBytes:cmds length:5];
    return [self udpprotocolDataWithData:cmddata index:index deviceinfo:deviceinfo];
}

#pragma mark - tcp/udp
+ (NSData *)getTcpUdpDataWithdata:(NSData *)data index:(UInt16)index deviceinfo:(DevicePreF*)deviceinfo isremote:(BOOL)isremote
{
    if (isremote) {
        //tcp访问
        return [self tcpProtocolDataWithData:data index:index deviceinfo:deviceinfo];

    } else {
        //udp访问
        return [self udpprotocolDataWithData:data index:index deviceinfo:deviceinfo];

    }
}

/**
 *  0x62查询模块信息
 *
 *  @param index      通信序号
 *  @param deviceinfo 设备信息
 *  @param isremote   是否是远程访问
 *
 *  @return NSData 组包后的数据
 */
+ (NSData *)getcurrentdeviceVersion:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[1] = {0x62};
    NSData * cmddata = [NSData dataWithBytes:cmds length:1];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)setdevicealisa:(UInt16)index alisalen:(UInt8)alisalen alisadata:(NSData *)alisadata deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[2];
    cmds[0] = 0x63;
    cmds[1] = alisalen;
    NSMutableData * cmddata = [[NSMutableData alloc] init];
    [cmddata appendBytes:cmds length:2];
    [cmddata appendData:alisadata];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)updatedevice:(UInt16)index urllen:(UInt8)urllen urldata:(NSData *)urldata deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[2];
    cmds[0] = 0x65;
    cmds[1] = urllen;
    NSMutableData * cmddata = [[NSMutableData alloc] init];
    [cmddata appendBytes:cmds length:2];
    [cmddata appendData:urldata];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)commonDeviceInfoWithType:(getDeviceInfoType)Type index:(UInt16)index deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[1];
    switch (Type) {
        case getDeviceInfoType_ledRGB:{
            //0x04 获取LED RGB
            cmds[0] = 0x04;
            break;
        }
        case getDeviceInfoType_ledModel:{
            //0x06 获取LED工作模式
            cmds[0] = 0x06;
            break;
        }
        case getDeviceInfoType_antomization:{
            //0x08 获取雾化度
            cmds[0] = 0x08;
            break;
        }
        case getDeviceInfoType_offtime:{
            //0x0A 查询倒计时
            cmds[0] = 0x0A;
            break;
        }
        case deleteDeviceType_offtime:{
            //0x0B删除倒计时
            cmds[0] = 0x0B;
            break;
        }
        default:
            break;
    }
    NSData * cmddata = [NSData dataWithBytes:cmds length:1];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)setDeviceIOStatus:(UInt16)index controlType:(UInt8)controlType controlStatus:(UInt8)controlStatus deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[3];
    cmds[0] = 0x01;
    cmds[1] = controlType;
    cmds[2] = controlStatus;
    NSData * cmddata = [NSData dataWithBytes:cmds length:3];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)getDeviceIOStatus:(UInt16)index controlType:(UInt8)controlType deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[2];
    cmds[0] = 0x02;
    cmds[1] = controlType;
    NSData * cmddata = [NSData dataWithBytes:cmds length:2];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)setDeviceledRGB:(UInt16)index Rvalue:(UInt8)Rvalue Gvalue:(UInt8)Gvalue Bvalue:(UInt8)Bvalue deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[4] = {0x03,Rvalue,Gvalue,Bvalue};
    NSData * cmddata = [NSData dataWithBytes:cmds length:4];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)setLedModel:(UInt16)index model:(UInt8)model deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[2] = {0x05,model};
    NSData * cmddata = [NSData dataWithBytes:cmds length:2];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)setatomization:(UInt16)index atomization:(UInt8)atomization deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[2] = {0x07,atomization};
    NSData * cmddata = [NSData dataWithBytes:cmds length:2];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)setofftime:(UInt16)index time:(long)time deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[5];
    cmds[0] = 0x09;
    cmds[1] = (time >> 24) & 0xff;
    cmds[2] = (time >> 16) & 0xff;
    cmds[3] = (time >> 8) & 0xff;
    cmds[4] = time & 0xff;
    
    NSData * cmddata = [NSData dataWithBytes:cmds length:5];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)setBookWithindx:(UInt16)index Num:(UInt8)num Flag:(UInt8)flag Hour:(UInt8)hour Min:(UInt8)min isOpen:(BOOL)isOpen deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[6];
    cmds[0] = 0x0c;
    cmds[1] = num;
    cmds[2] = flag;
    cmds[3] = hour;
    cmds[4] = min;
    cmds[5] = isOpen ? 0xff:0x00;
    NSData * cmddata = [NSData dataWithBytes:cmds length:6];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)getBookDataWithindex:(UInt16)index Numdata:(NSData *)numData deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[1] = {0x0d};
    NSMutableData * cmddata = [[NSMutableData alloc] initWithBytes:cmds length:1];
    [cmddata appendData:numData];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}

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
+ (NSData *)deleteBookWithindex:(UInt16)index Num:(UInt8)num deviceinfo:(DevicePreF *)deviceinfo isremote:(BOOL)isremote
{
    UInt8 cmds[2] = {0x0e,num};
    NSData * cmddata = [NSData dataWithBytes:cmds length:2];
    return [self getTcpUdpDataWithdata:cmddata index:index deviceinfo:deviceinfo isremote:isremote];
}



@end
