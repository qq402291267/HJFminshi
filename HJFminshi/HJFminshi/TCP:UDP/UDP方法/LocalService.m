//
//  LocalService.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/9.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "LocalService.h"
#import "GCDAsyncUdpSocket.h"
#import "BoardCastAdress.h"
#import "UDP_ResponseAnalysis.h"
#import "GCDAsyncSocket.h"
#import "NetworkUtil.h"
#import "ProtocolData.h"
#import "IndexManager.h"
#import "TcpUdpService.h"
#import "DevicePreF.h"
#import "UDP_ResponseAnalysis.h"
#import "OperatorResult.h"
#import "SocketError.h"
#import "UDPMethod.h"

@interface LocalService()<GCDAsyncSocketDelegate>

@property (nonatomic,assign) UdpBindStatus currentbindStatus;

@property (nonatomic,strong) GCDAsyncUdpSocket * currentSocket;

//将操作设置为线程锁定
@property (nonatomic,strong) NSMutableArray * allOperationArray;

@property (nonatomic,assign) int currentSearchtime;
@end
static LocalService * singleInstance = nil;
@implementation LocalService
+ (LocalService *)shareLocalService{
    if (singleInstance == nil) {
        singleInstance = [[LocalService alloc] init];
    }
    return singleInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        _currentbindStatus = NotBinded;
        _allOperationArray = [[NSMutableArray alloc] init];
        self.MethodDelegate = UDPMethodInstance;
    }
    return self;
}

//  绑定Udp并开启定时器
- (void)udpBindConnect{
    NSString * userName = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERNAME];
    NSString * userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERPASSWORD];
    if (![comMethod JudgeUserName:userName userPassword:userPassword]){
        HJFUDPLog(@"用户未登录,不能进行Udp监听");
        return;
    }
    
    if (_currentbindStatus == NotBinded){
        if ([NetworkUtilInstance networkStatus] == ReachableViaWiFi)
        {
             HJFUDPLog(@"udp端口未绑定,开始绑定");
            //开始绑定端口
            _currentbindStatus = Binding;
            [self beginbindSocket];
        }
        
        else{
            HJFUDPLog(@"udp端口未绑定,网络未连接或连接的为数据流量");
        }
        
    }
    
    else if (_currentbindStatus == Binding){
        HJFUDPLog(@"udp正在绑定端口");
    }
    
    else{
        [self rebindedsocket];
        HJFUDPLog(@"重新绑定udp端口");

    }
    
}

//  开始绑定udp
- (void)beginbindSocket{
    //更新广播地址
    [BoardCastAdressInstance updateBroadCastAddress];
    //创建udp Socket
    _currentSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:TcpUdpServiceInstance.single_Queue];
    NSError * error = nil;
    //先绑定监听端口
    if (![_currentSocket bindToPort:UdpBindPort error:&error]){
        HJFUDPLog(@"%@",[NSString stringWithFormat:@"端口绑定出错,error = %@",[error localizedDescription]]);
        _currentbindStatus = NotBinded;
    }
    
    else if (![_currentSocket enableBroadcast:YES error:&error]){
        HJFUDPLog(@"%@",[NSString stringWithFormat:@"开启发送广播,error = %@",[error localizedDescription]]);
        _currentbindStatus = NotBinded;
    }
    
    else if (![_currentSocket beginReceiving:&error]){
        HJFUDPLog(@"%@",[NSString stringWithFormat:@"开启发送广播,error = %@",[error localizedDescription]]);
        _currentbindStatus = NotBinded;
    }
    
    else {
        HJFUDPLog(@"udp绑定成功");
        _currentbindStatus = Binded;
    }
}

//  重新绑定udp端口
- (void)rebindedsocket{
    [self CloseUdpBind];
    [self udpBindConnect];
}

//  断开udp绑定监听

- (void)CloseUdpBind{
    _currentSocket.delegate = nil;
    [_currentSocket close];
    _currentSocket = nil;
    _currentbindStatus = NotBinded;
    //设置所有设备udp断线,并关闭所有定时器
    HJFUDPLog(@"--------------CloseUdpBind----------------");
    for (DevicePreF * deviceinfo in DeviceManageInstance.device_array) {
        deviceinfo.localIsOnline = NO;
        [deviceinfo.heartbeatTimer invalidate];
        deviceinfo.heartbeatTimer = nil;
        [deviceinfo.stopheartTimer invalidate];
        deviceinfo.stopheartTimer = nil;
        
    }
}


//--------------------------------发现所有设备,udp 在线判断-----------------------------
- (void)JugeAllDeviceudpOnline{
    for (DevicePreF * currentdevice in DeviceManageInstance.device_array) {
        [self SearchDeviceWithdeviceinfo:currentdevice];
    }
}

//  发送搜索发现设备命令
- (void)SearchDeviceWithdeviceinfo:(DevicePreF *)deviceinfo{
    
    HJFUDPLog(@"%@",[NSString stringWithFormat:@"发送搜索发现设备命令:deviceinfo = %@",deviceinfo]);
    
    [self sendToDeviceWithData:[ProtocolData discorverdevice:NewIndex deviceinfo:deviceinfo] deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
    
          HJFUDPLog(@"%@",[NSString stringWithFormat:@"搜索发现设备结果 = %@",resultData]);
        
        if (!resultData) {
            HJFUDPLog(@"udp搜索10秒延时到,未搜索到设备");

        }
    }];
}

//  发送命令到当前连接的udpsocket
- (void)sendToDeviceWithData:(NSData *)data deviceinfo:(DevicePreF *)deviceinfo complete:(Complete)delegate{
    SocketOperator * currentOperator = [SocketOperator OperatorWithIndex:[IndexManagerInstance currentIndex] complete:delegate];
    HJFUDPLog(@"%@",[NSString stringWithFormat:@"sendToDeviceWithData:index = %d,data = %@,lanIP = %@", currentOperator.currentIndex, data,deviceinfo.lanIP]);
    [currentOperator startTimer:UDPTimeout];
    [_allOperationArray addObject:currentOperator];
    if (deviceinfo && deviceinfo.lanIP) {
        
        for (int i = 0; i < 2; i++) {
            [_currentSocket sendData:data toHost:deviceinfo.lanIP port:DevicePort withTimeout:-1 tag:0];
        }
    }
    
    else {
        
        //发送广播发送3次
        for (int i = 0; i < 3; i++) {
            NSString * sendboardcastAddress = [BoardCastAdressInstance getcurrentBroadCastAddress];
            HJFUDPLog(@"%@",[NSString stringWithFormat:@"sendboardcastAddress = %@",sendboardcastAddress]);
            [_currentSocket sendData:data toHost:sendboardcastAddress port:DevicePort withTimeout:-1 tag:0];
        }
        
    }
}


//-----------------------GCDAsyncUdpSocketDelegate-------------------------
//-------------------------------------------------------------------------
/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    HJFUDPLog(@"UDP连接关闭");
    [self CloseUdpBind];
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    if (data.length <= 16) {
        //发送命令长度为17,如果回复命令长度不大于16,则认为接收数据有误
        return;
    }
    HJFUDPLog(@"%@",[NSString stringWithFormat:@"接收到UDP数据,sock = %@,_currentSocket = %@,data = %@",sock ,_currentSocket,data]);
    //    UInt8 byte1 = ((UInt8 *)[data bytes])[1];
    //处理得到的最终数据
    //判断是否是接收到设备返回信息
    //1.是否是回复信息  2.是否是推送信息
    UInt8 flag = ((UInt8 *)[data bytes])[1];
    UInt8 cmd = ((UInt8 *)[data bytes])[16];
    if ((flag & 0x02) == 0x00 && cmd != LAN_PUSH_CMD) {
//            [self NSLogDelegateWithString:[NSString stringWithFormat:@">>>>----接收到无效数据:flag = 0x%x,cmd = 0x%x", flag, cmd]];

        return;
    }
    [self dealWithReceiveAllData:data];
}

//  处理得到的数据
- (void)dealWithReceiveAllData:(NSData *)response
{
    UInt8 cmd = [UDP_ResponseAnalysisInstance getProtcolCmd:response];
    NSDictionary *dictinfo = [[NSDictionary alloc] init];
    if (cmd ==findDeviceOrder) {

         dictinfo = [self getdiscroverdevcieInfo:response];
    }
    else if (cmd ==heartBeat){
         dictinfo = [self localheartBeatInfo:response];

    }
    else{
          dictinfo = [UDP_ResponseAnalysisInstance analysisLocalResponse:response];
    }

    //得到返回信息
    OperatorResult * result = [OperatorResult ResultWithdata:response dictionary:dictinfo];
    //根据currentIndex找到对应操作,回调
    UInt16 currentIndex = [UDP_ResponseAnalysisInstance indexFromResponse:response];
    SocketOperator * socketOperator = [self getIndexSoketOperator:currentIndex];
    if (socketOperator) {
        [socketOperator closetimeoutTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [socketOperator didReceiveResponse:result];
            socketOperator.IsCalledback = YES;
        });
    }
}

//  根据序号找到对应的操作
- (SocketOperator *)getIndexSoketOperator:(UInt16)operatorIndex{
    NSArray * tempOperatorArray = [NSArray arrayWithArray:_allOperationArray];
    for (SocketOperator * operator in tempOperatorArray) {
        if (operator.currentIndex == operatorIndex) {
            return operator;
        }
        //删除超时的操作
        if (operator.IsTimeout || operator.IsCalledback) {
            [_allOperationArray removeObject:operator];
        }
    }
    return nil;
}

//  局域网发现设备
- (NSDictionary *)getdiscroverdevcieInfo:(NSData *)response{
    @try {
        
        //解析得到设备信息,添加设备到本地数据库及服务器
        HJFUDPLog(@"得到局域网需要添加的设备信息");
        if (response.length <= 17) {
            return nil;
        }
        //帧头mac地址
        NSData * headMac = [response subdataWithRange:NSMakeRange(2, 6)];
        HJFUDPLog(@"headMac = %@",headMac);
        //得到搜索到的设备信息
        NSData * dataip = [response subdataWithRange:NSMakeRange(17, 4)];
        NSString * host = [comMethod convertDataToip:dataip];
        HJFUDPLog(@"host = %@",host);
        NSData * macdata = [response subdataWithRange:NSMakeRange(21, 6)];
        NSString * macstring = [comMethod convertDataTomacstring:macdata];
        //测试数据转换是否正确
        NSData * testmacdata = [comMethod convertmacstringToData:macstring];
        HJFUDPLog(@"macdata = %@,macstring = %@,testmacdata = %@",macdata,macstring,testmacdata);
        //添加设备数据到设备单例/本地数据库/服务器
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (!deviceinfo) {
            HJFUDPLog(@"搜索设备不存在,首先添加设备到单例");
            deviceinfo = [DevicePreF AllInfo];
            deviceinfo.lanIP = host;
            deviceinfo.macdata = macdata;
            deviceinfo.macAddress = macstring;
            //设置默认设备信息,companyCode,deviceType,authCode,devicename,logo,orderNumber
            deviceinfo.companyCode = @"F1";
            deviceinfo.deviceType = @"D1";
            deviceinfo.authCode = @"3412";
            deviceinfo.imageName = @"0.png";
            deviceinfo.deviceName = @"minshiRT";
            //得到用户名
            NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERNAME];
            deviceinfo.username = username;
            //转化数据为网络传输格式
            [DeviceManageInstance convertDeviceinfo:deviceinfo];
            //添加到单例
            [DeviceManageInstance.device_array addObject:deviceinfo];
            //添加到本地数据库
            [DeviceDataManagerInstance insertIntoDataBase:deviceinfo];
            //得到添加的设备的数据库id
            int DB_id = [DeviceDataManagerInstance getDetailRowDB_idWithmac:macstring username:username];
            deviceinfo.DB_id = DB_id;
            //添加完设备
            [self sendFirstAddDevicecmd:deviceinfo];
            
            
        }
        else {
            HJFUDPLog(@"搜索设备存在");
            [self sendDeviceExistsOnlinecmd:deviceinfo lanIP:host];
        }
        return @{@"headMac":[NSString stringWithFormat:@"%@",headMac],
                 @"host":[NSString stringWithFormat:@"%@",host],
                 @"macdata":[NSString stringWithFormat:@"%@",macdata],
                 @"macstring":[NSString stringWithFormat:@"%@",macstring]};
        
    } @catch (NSException *exception) {
        //
        HJFUDPLog(@"getdiscroverdevcieInfo>>>exception = %@",exception);
        return nil;
    }
}

//局域网发现设备,设备存在,设备从离线到在线
-(void)sendDeviceExistsOnlinecmd:(DevicePreF *)deviceinfo lanIP:(NSString *)lanIP
{
    //判断设备局域网是否在线
    if (!deviceinfo.localIsOnline) {
        //设备局域网不在线
        //修改局域网在线标志位
        deviceinfo.localIsOnline = YES;
        deviceinfo.lanIP = lanIP;
        //发送局域网udp首次心跳通知
        [self sendfirstheartbeatDataWithdeviceInfo:deviceinfo];
        
        //获取设备所有状态信息
        if ([self.MethodDelegate respondsToSelector:@selector(getDeviceStatusWithDeviceInfo:)]) {
            [self.MethodDelegate getDeviceStatusWithDeviceInfo:deviceinfo];
        }
        
        
    }
    //设备局域网在线,不处理
}

//发送初次心跳通知(LocalService中实现)
- (void)sendfirstheartbeatDataWithdeviceInfo:(DevicePreF *)deviceinfo
{
    UInt16 interval = 10;
    //得到操作设备的mac,找到对应的设备
    NSData * macdata = deviceinfo.macdata;
    deviceinfo.udpinterval = interval;
    //    开始心跳动作
    dispatch_async(dispatch_get_main_queue(), ^{
        [self UDPfirstinterval:macdata];
    });
    
    
}

//-------------------------------------------------------------------
//  第一次心跳通知

- (void)UDPfirstinterval:(NSData *)data{
    
    NSData * macdata = data;
    //找到对应的设备
    DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
    if (deviceinfo) {
        //发送第一次心跳通知,并启用1.5断线定时器
        HJFUDPLog(@">>>>>>>>>>发送第一次心跳通知,并启用1.5断线定时器");
        [self sendbeatData:deviceinfo];
        [self startstopheartbeatTimer:deviceinfo];
        
    } else {
        //设备不存在
        HJFUDPLog(@"接收到第一次心跳通知,设备不存在");
    }
}


//发送心跳命令
- (void)sendbeatData:(DevicePreF *)deviceinfo{
    //发送udp心跳包
    HJFUDPLog(@">>>>>>>>-----------发送udp心跳包");
    [self sendToDeviceWithData:[ProtocolData heartBeatLocal:[IndexManagerInstance newIndex] deviceinfo:deviceinfo] deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
    }];
}

//启用断线定时器
- (void)startstopheartbeatTimer:(DevicePreF *)deviceinfo{
    [deviceinfo.stopheartTimer invalidate];
    deviceinfo.stopheartTimer = nil;
    deviceinfo.stopheartTimer = [NSTimer scheduledTimerWithTimeInterval:deviceinfo.udpinterval*1.5 target:self selector:@selector(stopheartbeat:) userInfo:deviceinfo repeats:NO];
    
}

- (void)stopheartbeat:(NSTimer *)timer{
    DevicePreF * deviceinfo = timer.userInfo;
    //udp设备断开,设备需要使用外网通信
    deviceinfo.localIsOnline = NO;
    //继续发送心跳
    [self sendbeatData:deviceinfo];
    //再次搜索设备,发现设备
    NSData * senddata = [ProtocolData discorverdevice:NewIndex deviceinfo:deviceinfo];
    [LocalServiceInstance sendToDeviceWithData:senddata deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
        //
        if (resultData) {
            HJFUDPLog(@"局域网设备断开");
        } else {
            if ([self.MethodDelegate respondsToSelector:@selector(UpdateStatusWithDeviceInfo:)]) {
                [self.MethodDelegate UpdateStatusWithDeviceInfo:deviceinfo];
            }
            //跳转到主线程中发送通知
            //发送通知,更新设备状态
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateStatus_Notification object:@{Mac_Key_data:deviceinfo.macdata}];
            HJFUDPLog(@"%@",[NSString stringWithFormat:@"局域网设备断开,使用TCP访问,localIsOnline = %d,remoteIsOnline = %d", deviceinfo.localIsOnline, deviceinfo.remoteIsOnline]);
        }
    }];
}


//  发送第一个心跳包后，解析收到的udp心跳数据
- (NSDictionary *)localheartBeatInfo:(NSData *)response{
    @try {
        //
        UInt16 interval = [comMethod uint16FromNetData:[response subdataWithRange:NSMakeRange(17, 2)]];
        //得到操作设备的mac,找到对应的设备
        SocketError * error = nil;
        NSData * macdata = [UDP_ResponseAnalysisInstance getProtcolmac:response];
        DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
        if (deviceinfo) {
            //设备存在,更新设备信息
            HJFLog(@"localheartBeatInfo");
            deviceinfo.udpinterval = interval;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self UDPinterval:macdata];
            });
            
        } else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"得到udp设备心跳数据,设备不存在" forKey:NSLocalizedDescriptionKey];
            error = [SocketError errorWithcode:XDefultFailed userInfo:userInfo];
        }
        return @{@"interval":[NSString stringWithFormat:@"%d",interval],
                 @"macdata":[NSString stringWithFormat:@"%@",macdata],
                 @"error":[NSString stringWithFormat:@"%@",[error localizedDescription]]};
        
    } @catch (NSException *exception) {
        //
        NSLog(@"localheartBeatInfo>>>exception = %@",exception);
        return nil;
    }
}

//解析完成第一个心跳包后执行
- (void)UDPinterval:(NSData *)data{
    HJFUDPLog(@"%@",[NSString stringWithFormat:@"接收到udp->notification心跳通知:isMainThread = %d,isMultiThreaded = %d",[NSThread isMainThread],[NSThread isMultiThreaded]]);
    NSData * macdata = data;
    
    //找到对应的设备
    DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
    
    if (deviceinfo) {
        [self startsendheartbeatTimer:deviceinfo];
        [self startstopheartbeatTimer:deviceinfo];
        
    } else {
        //设备不存在
        HJFUDPLog(@"接收到心跳通知,设备不存在");
        
    }
}

//  开始心跳定时函数
- (void)startsendheartbeatTimer:(DevicePreF *)deviceinfo{
    HJFUDPLog(@"%@",[NSString stringWithFormat:@"接收到udp心跳数据:udpinterval = %d",deviceinfo.udpinterval]);
    [deviceinfo.heartbeatTimer invalidate];
    deviceinfo.heartbeatTimer = nil;
    deviceinfo.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:deviceinfo.udpinterval target:self selector:@selector(sendheartbeatData:) userInfo:deviceinfo repeats:NO];
    
}

- (void)sendheartbeatData:(NSTimer *)timer{
    HJFUDPLog(@"定时时间到,发送心跳数据");
    DevicePreF * deviceinfo = timer.userInfo;
    [self sendbeatData:deviceinfo];
}




//局域网发现设备,首次添加设备
- (void)sendFirstAddDevicecmd:(DevicePreF *)deviceinfo
{
    deviceinfo.localIsOnline = YES;
    
    //发送局域网udp首次心跳通知
    [self sendfirstheartbeatDataWithdeviceInfo:deviceinfo];
    
    //添加设备视图
    if ([self.MethodDelegate respondsToSelector:@selector(AddViewToScrollViewWithDeviceInfo:)]) {
        [self.MethodDelegate AddViewToScrollViewWithDeviceInfo:deviceinfo];
    }

    //获取设备所有状态信息
    if ([self.MethodDelegate respondsToSelector:@selector(getDeviceStatusWithDeviceInfo:)]) {
        [self.MethodDelegate getDeviceStatusWithDeviceInfo:deviceinfo];
    }

    
    //查询设备Tcp是否在线
    if ([self.MethodDelegate respondsToSelector:@selector(TcponlineDataWithDeviceInfo:)]) {
        [self.MethodDelegate TcponlineDataWithDeviceInfo:deviceinfo];
    }
    
    //Tcp事件订阅
    if ([self.MethodDelegate respondsToSelector:@selector(TcpsubscribetoeventWithDeviceInfo:)]) {
        [self.MethodDelegate TcpsubscribetoeventWithDeviceInfo:deviceinfo];
    }

    
    //上传设备信息到服务器
    if ([self.MethodDelegate respondsToSelector:@selector(UploadDeviceinfoToHttpServerWithDeviceInfo:)]) {
        [self.MethodDelegate UploadDeviceinfoToHttpServerWithDeviceInfo:deviceinfo];
    }
    
}

//---------------------------------------------------------------------------

//  搜索所有未锁定设备
- (void)SearchAllUnlockDevice
{
    //每隔5s发送一个搜索命令,发送6次,共30s后停止
    _currentSearchtime = 0;
    //开启定时器
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(searchTimefunction:) userInfo:nil repeats:YES];
}

- (void)searchTimefunction:(NSTimer *)timer
{
    //发送6次后停止
    if (_currentSearchtime >= 6) {
        //停止
        HJFUDPLog(@"搜索设备完毕");

        [timer invalidate];
        timer = nil;
    } else {
        _currentSearchtime ++;
        [self SearchDeviceWithdeviceinfo:nil];
    }
}

//  停止局域网搜索设备

- (void)StopSearchDevice
{
    _currentSearchtime = 100;
}


//--------------------------------------------------------------------

@end
