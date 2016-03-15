//
//  LocalService.m
//  minshi
//
//  Created by iTC on 15/6/18.
//  Copyright (c) 2015年 ohbuy. All rights reserved.
//
#import "LocalService.h"
#import "GCDAsyncUdpSocket.h"

@interface LocalService ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic,assign) UdpBindStatus currentbindStatus;

@property (nonatomic,strong) GCDAsyncUdpSocket * currentSocket;

//将操作设置为线程锁定
@property (nonatomic,strong) NSMutableArray * allOperationArray;

@property (nonatomic,assign) int currentSearchtime;

@end

static LocalService * singleInstance = nil;

@implementation LocalService

+ (LocalService *)shareLocalService
{
    if (singleInstance == nil) {
        singleInstance = [[LocalService alloc] init];
    }
    return singleInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _currentbindStatus = NotBinded;
        _allOperationArray = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interval:) name:LocalInterval_Notification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstinterval:) name:FirstUdpInterval_Notification object:nil];
    }
    return self;
}

/**
 *  绑定Udp并开启定时器
 */
- (void)udpBindConnect
{
    NSString * userName = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERNAME];
    NSString * userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERPASSWORD];
    if (userName == nil || [userName isEqualToString:@""] || [userName isEqual:[NSNull null]] || userPassword == nil || [userPassword isEqualToString:@""] || [userPassword isEqual:[NSNull null]]) {
        [_bindmsgdelegate bindConnectSucceed:NO msg:@"用户未登录,不能进行Udp监听"];
        return;
    }
    //
    if (_currentbindStatus == NotBinded) {
        
        if ([NetworkUtilInstance networkStatus] == ReachableViaWiFi) {
            [_bindmsgdelegate bindConnectSucceed:NO msg:@"udp端口未绑定,开始绑定"];
            //开始绑定端口
            _currentbindStatus = Binding;
            [self beginbindSocket];
            
        } else {
            [_bindmsgdelegate bindConnectSucceed:NO msg:@"udp端口未绑定,网络未连接或连接的为数据流量"];
        }
        
    } else if (_currentbindStatus == Binding) {
        [_bindmsgdelegate bindConnectSucceed:NO msg:@"udp正在绑定端口"];
    } else {
        [self rebindedsocket];
        [_bindmsgdelegate bindConnectSucceed:YES msg:@"重新绑定udp端口"];
    }
}

/**
 *  开始绑定udp
 */
- (void)beginbindSocket
{
    //更新广播地址
    [BoardCastAdressInstance updateBroadCastAddress];
    //创建udp Socket
    _currentSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:TcpUdpServiceInstance.single_Queue];
    NSError * error = nil;
    //先绑定监听端口
    if (![_currentSocket bindToPort:UdpBindPort error:&error])
    {
        [_bindmsgdelegate bindConnectSucceed:NO msg:[NSString stringWithFormat:@"端口绑定出错,error = %@",[error localizedDescription]]];
        _currentbindStatus = NotBinded;
    } else if
        (![_currentSocket enableBroadcast:YES error:&error])
    {
        [_bindmsgdelegate bindConnectSucceed:NO msg:[NSString stringWithFormat:@"开启发送广播,error = %@",[error localizedDescription]]];
        _currentbindStatus = NotBinded;
    } else if (![_currentSocket beginReceiving:&error]) {
        [_bindmsgdelegate bindConnectSucceed:NO msg:[NSString stringWithFormat:@"开启发送广播,error = %@",[error localizedDescription]]];
        _currentbindStatus = NotBinded;
    } else {
        [_bindmsgdelegate bindConnectSucceed:YES msg:@"udp绑定成功"];
        _currentbindStatus = Binded;
    }
}

/**
 *  重新绑定udp端口
 */
- (void)rebindedsocket
{
    [self CloseUdpBind];
    [self udpBindConnect];
}

/**
 *  断开udp绑定监听
 */
- (void)CloseUdpBind
{
    _currentSocket.delegate = nil;
    [_currentSocket close];
    _currentSocket = nil;
    _currentbindStatus = NotBinded;
    //设置所有设备udp断线,并关闭所有定时器
    for (DeviceAllInfo * deviceinfo in AllDeviceInstance.device_array) {
        deviceinfo.localIsOnline = NO;
        [deviceinfo.heartbeatTimer invalidate];
        deviceinfo.heartbeatTimer = nil;
        [deviceinfo.stopheartTimer invalidate];
        deviceinfo.stopheartTimer = nil;
    }
}
//-----------------------GCDAsyncUdpSocketDelegate-------------------------
//-------------------------------------------------------------------------
/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    [_bindmsgdelegate udpmsg:@"UDP连接关闭"];
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
    [_bindmsgdelegate udpmsg:[NSString stringWithFormat:@"接收到UDP数据,sock = %@,_currentSocket = %@,data = %@",sock ,_currentSocket,data]];
//    UInt8 byte1 = ((UInt8 *)[data bytes])[1];
    //处理得到的最终数据
    //判断是否是接收到设备返回信息
    //1.是否是回复信息  2.是否是推送信息
    UInt8 flag = ((UInt8 *)[data bytes])[1];
    UInt8 cmd = ((UInt8 *)[data bytes])[16];
    if ((flag & 0x02) == 0x00 && cmd != LAN_PUSH_CMD) {
        NSLog(@"");
        [_bindmsgdelegate udpmsg:[NSString stringWithFormat:@">>>>----接收到无效数据:flag = 0x%x,cmd = 0x%x", flag, cmd]];
        return;
    }
    [self dealWithReceiveAllData:data];
}

//----------------------function-----------------------------------
/**
 *  处理得到的数据
 *
 *  @param response
 */
- (void)dealWithReceiveAllData:(NSData *)response
{
    //得到返回字典
    NSDictionary * dictinfo = [ResponseAnalysis analysisLocalResponse:response];
    //得到返回信息
    OperatorResult * result = [OperatorResult ResultWithdata:response dictionary:dictinfo];
    //根据currentIndex找到对应操作,回调
    UInt16 currentIndex = [ResponseAnalysis indexFromResponse:response];
    SocketOperator * socketOperator = [self getIndexSoketOperator:currentIndex];
    if (socketOperator) {
        [socketOperator closetimeoutTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [socketOperator didReceiveResponse:result];
            socketOperator.IsCalledback = YES;
        });
    }
}

/**
 *  根据序号找到对应的操作
 *
 *  @param operatorIndex 操作序号
 *
 *  @return 对应的操作
 */
- (SocketOperator *)getIndexSoketOperator:(UInt16)operatorIndex
{
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

/**
 *  发送命令到当前连接的udpsocket
 *
 *  @param data       要发送的全部数据
 *  @param deviceinfo 设备信息,如果为nil,则发送到广播地址
 *  @param delegate   代理回调
 */
- (void)sendToDeviceWithData:(NSData *)data deviceinfo:(DeviceAllInfo *)deviceinfo complete:(Complete)delegate
{
    SocketOperator * currentOperator = [SocketOperator OperatorWithIndex:[IndexManagerInstance currentIndex] complete:delegate];
    [_bindmsgdelegate udpmsg:[NSString stringWithFormat:@"sendToDeviceWithData:index = %d,data = %@,lanIP = %@", currentOperator.currentIndex, data,deviceinfo.lanIP]];
    [currentOperator startTimer:UDPTimeout];
    [_allOperationArray addObject:currentOperator];
    if (deviceinfo && deviceinfo.lanIP) {
        
        for (int i = 0; i < 2; i++) {
            [_currentSocket sendData:data toHost:deviceinfo.lanIP port:DevicePort withTimeout:-1 tag:0];
        }
        
    } else {
        
        //发送广播发送3次
        for (int i = 0; i < 3; i++) {

            NSString * sendboardcastAddress = [BoardCastAdressInstance getcurrentBroadCastAddress];
            [_bindmsgdelegate udpmsg:[NSString stringWithFormat:@"sendboardcastAddress = %@",sendboardcastAddress]];
            [_currentSocket sendData:data toHost:sendboardcastAddress port:DevicePort withTimeout:-1 tag:0];
        }
        
    }
}

//---------------------------------------------------------------------------
/**
 *  搜索所有未锁定设备
 */
- (void)SearchAllUnlockDevice
{
    //每隔5s发送一个搜索命令,发送6次,共30s后停止
    _currentSearchtime = 0;
    //开启定时器
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(searchTimefunction:) userInfo:nil repeats:YES];
}

/**
 *  停止局域网搜索设备
 */
- (void)StopSearchDevice
{
    _currentSearchtime = 100;
}

/**
 *  发送搜索发现设备命令
 *
 *  @param deviceinfo 设备信息
 */
- (void)SearchDeviceWithdeviceinfo:(DeviceAllInfo *)deviceinfo
{
    [_bindmsgdelegate udpmsg:[NSString stringWithFormat:@"发送搜索发现设备命令:deviceinfo = %@",deviceinfo]];
    [self sendToDeviceWithData:[ProtocolData discorverdevice:[IndexManagerInstance newIndex] deviceinfo:deviceinfo] deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
        NSLog(@"resultData = %@",resultData);
        if (!resultData) {
            [self.bindmsgdelegate udpmsg:@"udp搜索10秒延时到,未搜索到设备"];
        }
    }];
}

- (void)searchTimefunction:(NSTimer *)timer
{
    //发送6次后停止
    if (_currentSearchtime >= 6) {
        //停止
        [_bindmsgdelegate udpmsg:@"搜索设备完毕"];
        [timer invalidate];
        timer = nil;
    } else {
        _currentSearchtime ++;
        [self SearchDeviceWithdeviceinfo:nil];
    }
}

//---------------------------------------------------------------------------
/**
 *  第一次心跳通知
 *
 *  @param notification
 */
- (void)firstinterval:(NSNotification *)notification
{
    NSDictionary * dict = [notification object];
    NSData * macdata = [dict objectForKey:Mac_Key_data];
    //找到对应的设备
    DeviceAllInfo * deviceinfo = [AllDeviceInstance getDeviceAllInfoWithmac:macdata];
    if (deviceinfo) {
        //发送第一次心跳通知,并启用1.5断线定时器
        [_bindmsgdelegate udpmsg:@">>>>>>>>>>发送第一次心跳通知,并启用1.5断线定时器"];
        [self sendbeatData:deviceinfo];
        [self startstopheartbeatTimer:deviceinfo];
        
    } else {
        //设备不存在
        [_bindmsgdelegate udpmsg:@"接收到第一次心跳通知,设备不存在"];
    }
}

/**
 *  通知处理函数
 *
 *  @param notification
 */
- (void)interval:(NSNotification *)notification
{
    [_bindmsgdelegate udpmsg:[NSString stringWithFormat:@"接收到udp->notification心跳通知:isMainThread = %d,isMultiThreaded = %d",[NSThread isMainThread],[NSThread isMultiThreaded]]];
    NSDictionary * dict = [notification object];
    NSData * macdata = [dict objectForKey:Mac_Key_data];
    //找到对应的设备
    DeviceAllInfo * deviceinfo = [AllDeviceInstance getDeviceAllInfoWithmac:macdata];
    if (deviceinfo) {
        [self startsendheartbeatTimer:deviceinfo];
        [self startstopheartbeatTimer:deviceinfo];
    } else {
        //设备不存在
        [_bindmsgdelegate udpmsg:@"接收到心跳通知,设备不存在"];
    }
}

/**
 *  开始心跳定时函数
 *
 *  @param deviceinfo
 */
- (void)startsendheartbeatTimer:(DeviceAllInfo *)deviceinfo
{
    [_bindmsgdelegate udpmsg:[NSString stringWithFormat:@"接收到udp心跳数据:udpinterval = %d",deviceinfo.udpinterval]];
    [deviceinfo.heartbeatTimer invalidate];
    deviceinfo.heartbeatTimer = nil;
    deviceinfo.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:deviceinfo.udpinterval target:self selector:@selector(sendheartbeatData:) userInfo:deviceinfo repeats:NO];
}

- (void)sendheartbeatData:(NSTimer *)timer
{
    [_bindmsgdelegate udpmsg:[NSString stringWithFormat:@"定时时间到,发送心跳数据"]];
    DeviceAllInfo * deviceinfo = timer.userInfo;
    [self sendbeatData:deviceinfo];
}

//发送心跳命令
- (void)sendbeatData:(DeviceAllInfo *)deviceinfo
{
    //发送udp心跳包
    [_bindmsgdelegate udpmsg:[NSString stringWithFormat:@">>>>>>>>-----------发送udp心跳包"]];
    [self sendToDeviceWithData:[ProtocolData heartBeatLocal:[IndexManagerInstance newIndex] deviceinfo:deviceinfo] deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
    }];
}

//启用断线定时器
- (void)startstopheartbeatTimer:(DeviceAllInfo *)deviceinfo
{
    [deviceinfo.stopheartTimer invalidate];
    deviceinfo.stopheartTimer = nil;
    deviceinfo.stopheartTimer = [NSTimer scheduledTimerWithTimeInterval:deviceinfo.udpinterval*1.5 target:self selector:@selector(stopheartbeat:) userInfo:deviceinfo repeats:NO];
}

- (void)stopheartbeat:(NSTimer *)timer
{
    DeviceAllInfo * deviceinfo = timer.userInfo;
    //udp设备断开,设备需要使用外网通信
    deviceinfo.localIsOnline = NO;
    //继续发送心跳
    [self sendbeatData:deviceinfo];
    //再次搜索设备,发现设备
    NSData * senddata = [ProtocolData discorverdevice:NewIndex deviceinfo:deviceinfo];
    [LocalServiceInstance sendToDeviceWithData:senddata deviceinfo:deviceinfo complete:^(OperatorResult *resultData) {
        //
        if (resultData) {
            [self.bindmsgdelegate udpmsg:@"局域网设备断开"];
        } else {
            //跳转到主线程中发送通知
            //发送通知,更新设备状态
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateStatus_Notification object:@{Mac_Key_data:deviceinfo.macdata}];
            [self.bindmsgdelegate udpmsg:[NSString stringWithFormat:@"局域网设备断开,使用TCP访问,localIsOnline = %d,remoteIsOnline = %d", deviceinfo.localIsOnline, deviceinfo.remoteIsOnline]];
        }
    }];
}

//---------------------------------------------------------------------
/**
 *  发现所有设备,udp 在线判断
 */
- (void)JugeAllDeviceudpOnline
{
    for (DeviceAllInfo * currentdevice in AllDeviceInstance.device_array) {
        [self SearchDeviceWithdeviceinfo:currentdevice];
    }
}

//----------------------------------------------------------------------



@end
