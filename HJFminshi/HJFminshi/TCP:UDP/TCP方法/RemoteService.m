//
//  RemoteService.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "RemoteService.h"
#import "GCDAsyncSocket.h"
#import "NetworkUtil.h"
#import "RemoteServiceGetWorkServer.h"
#import "TcpUdpService.h"
#import "TCPUDPmethod.h"
#import "TcpData.h"
#import "ProtocolData.h"
#import "IndexManager.h"
#import "TCP_ResponseAnalysis.h"
#import "OperatorResult.h"
@interface RemoteService ()<GCDAsyncSocketDelegate>
{
    BOOL IsUseSsl;
}

@property (nonatomic,strong) GCDAsyncSocket * currentSocket;

@property (nonatomic,assign) TcpConnectStatus currentConnectStatus;

@property (nonatomic,strong) NSMutableArray * allOperationArray;

@property (nonatomic,strong) NSMutableData * responseData;

@property (nonatomic,assign) NSTimeInterval intervalheat;

@property (nonatomic,strong) NSTimer * heartbeatTimer;

@property (nonatomic,strong) NSTimer * disconnectTimer;

@property (nonatomic,strong) NSTimer * connecttimeoutTimer;

@end

static RemoteService * singleInstance = nil;

@implementation RemoteService

+ (RemoteService * )shareRemoteService{
    if (singleInstance == nil) {
        singleInstance = [[RemoteService alloc] init];
    }
    return singleInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        _currentConnectStatus = NotConnected;
        _allOperationArray = [[NSMutableArray alloc] init];
        _intervalheat = 10;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TcpIsonline:) name:TcpIsonline_Notification object:nil]; //udp查询在线
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Tcpsubscribetoevent:) name:Tcpsubscribetoevent_Notification object:nil];//udp查询订阅
        
        //不加密
        _isencrpt = NO;
        //敏识是否使用ssl加密
        IsUseSsl = YES;
    }
    return self;
}

//  判断连接并开启定时器
- (void)JudgeConnect
{
    NSString * userName = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERNAME];
    NSString * userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERPASSWORD];
    if ([comMethod JudgeUserName:userName userPassword:userPassword]){
        
        [self connectfunction];
    }
    else {
        HJFTCPLog(@"用户未登录,不能连接Tcp服务器");
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //开启定时器判断Tcp是否已经连接,如果延时30s后连接仍然未建立,则reconnect
        [_connecttimeoutTimer invalidate];
        _connecttimeoutTimer = nil;
        _connecttimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(JudgeReconnect) userInfo:nil repeats:NO];
    });
}

//执行tcp连接动作
- (void)connectfunction
{
    //判断是否已经连接上TCP服务器
    if (_currentConnectStatus == NotConnected)
    {
        //开始连接
        if ([NetworkUtilInstance networkStatus] != NotReachable)
            
        {
            HJFTCPLog(@"tcp未连接,开始连接");
            _currentConnectStatus = Connecting;
            [self connect];
        }
        else
        {
            HJFTCPLog(@"tcp未连接未连接,网络不可用");
        }
        
    }
    else if (_currentConnectStatus == Connecting)
    {
        HJFTCPLog(@"tcp正在连接");
    }
    else
    {
         HJFTCPLog(@"tcp设备已经连接");

    }
}

/**
 *  适用与敏识项目,先连接负载均衡服务器,再连接工作服务器
 */
- (void)connect
{
    //获取工作服务器
    [RemoteServiceGetWorkServerInstance connectgetWorkServerWithIsUseSSL:IsUseSsl Complete:^(ConnectStatus resultStatus, NSString *host, uint16_t port, NSString *failmsg) {
        if (resultStatus == ConnectStatus_failed) {
            //连接失败
            self.currentConnectStatus = NotConnected;
            HJFTCPLog(@"连接负载均衡服务器失败");
        }
        else
        { //连接成功,开始连接工作服务器
            self.currentSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:TcpUdpServiceInstance.single_Queue];
            HJFTCPLog(@"%@",[NSString stringWithFormat:@"开始连接工作服务器:host = %@,port = %d",host,port]);
            NSError * error = nil;
            //连接工作服务器
            if (![self.currentSocket connectToHost:host onPort:port error:&error]) {
                
                HJFTCPLog(@"连接工作服务器失败");
            }
        }
    }];
}




//判断是否需要重连
- (void)JudgeReconnect
{
    if (_currentConnectStatus != Connected) {
        //未连接成功,断开重连
        [self reconnect];
    } else {
        //停止定时器
        [_connecttimeoutTimer invalidate];
        _connecttimeoutTimer = nil;
    }
}

//  服务器连接未成功,需要重连

- (void)reconnect
{
    [self disconnect];
    HJFTCPLog(@"断开当前连接,重连服务器");
    [self JudgeConnect];
}


//  断开当前连接

- (void)disconnect
{
    _currentSocket.delegate = nil;
    [_currentSocket disconnect];
    _currentSocket = nil;
    _currentConnectStatus = NotConnected;
    //设置设备tcp断线,并关闭定时器
    for (DevicePreF * deviceinfo in DeviceManageInstance.device_array) {
        deviceinfo.remoteIsOnline = NO;
    }
    //关闭心跳定时器
    [_heartbeatTimer invalidate];
    _heartbeatTimer = nil;
    [_disconnectTimer invalidate];
    _disconnectTimer = nil;
}

//---------------------------GCDAsyncSocketDelegate------------------------
//-------------------------------------------------------------------------

//使用ssl加密
/**
 * 适用与敏识需获取工作服务器项目
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if (IsUseSsl) {
        //设置ssl字典
        NSDictionary * sslSetting = [TCPUDPmethod getsslSettingWithhost:TcpDataInstance.host];
        //开始设置SSL Setting
        HJFTCPLog(@"%@",[NSString stringWithFormat:@"SSL设置字典:sslSetting = %@",sslSetting]);
        
        if (sslSetting) {
            
            [_currentSocket startTLS:sslSetting];
        } else {
            HJFTCPLog(@"sslSetting设置为空,不能设置ssl");
            
        }
    } else {
        //不使用ssl,连接工作服务器成功,请求接入TCP
        //请求接入TCP-0x82
        [self requestTcpWorkServer];
    }
}


/**
 *  Allows a socket delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *  设备回调验证直接返回验证通过
 */
- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    completionHandler(YES);
}

//Called after the socket has successfully completed SSL/TLS negotiation.
//This method is not called unless you use the provided startTLS method.
- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    //请求接入TCP-0x82
    [self requestTcpWorkServer];
}

//Called when a socket disconnects with or without error.
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    //
    _currentConnectStatus = NotConnected;
    [_currentSocket setDelegate:nil];
    [_currentSocket disconnect];
    _currentSocket = nil;
    HJFTCPLog(@"%@",[NSString stringWithFormat:@"连接断开:socketDidDisconnect,err = %@",[err localizedDescription]]);
    [self JudgeConnect];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    HJFTCPLog(@"%@",[NSString stringWithFormat:@"didReadData:tag = %ld,isMainThread = %d",tag,[NSThread isMainThread]]);

    if (tag == HeadNoHiddenTag) {
        _responseData = [[NSMutableData alloc] initWithData:data];    //<a102ffff ffffffff 09>
        //1.读取第一部分数据帧头未加密数据,得到需要读取的加密部分的长度
#if Type_Protcol == minshi_Protcol
        UInt8 secondlength = ((UInt8 *)[data bytes])[8];  //敏识格式 Len一个字节
//#elif Type_Protcol == sanxing_Protcol
//        //三星格式 Len 两个字节
//        UInt8 hightlength = ((UInt8 *)[data bytes])[8];
//        UInt8 lowlength = ((UInt8 *)[data bytes])[9];
//        UInt16 secondlength = (hightlength << 8) | lowlength;
#endif
        
        HJFTCPLog(@"%@",[NSString stringWithFormat:@"读取第一部分数据完毕,开始读取第二部分数据:%@",data]);

        [_currentSocket readDataToLength:secondlength withTimeout:-1 tag:HiddenTag];
    } else {
        //得到第二部分数据
        [_responseData appendData:data];//<000002d1 f1341282 00>
        
        HJFTCPLog(@"%@",[NSString stringWithFormat:@"第二部分数据读取完毕,开始处理数据:_responseData = %@",_responseData]);//<a102ffff ffffffff 09000002 d1f13412 8200>

        //处理数据
        [self dealWithReceiveAllData];
        //处理完后开始读取下一次数据
        [_currentSocket readDataToLength:HeadNoHiddenLen withTimeout:-1 tag:HeadNoHiddenTag];
    }
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    HJFTCPLog(@"TCP-0x82发送数据完成");


}
//--------------------------function---------------------------------------
//-------------------------------------------------------------------------
//请求接入TCP-0x82
- (void)requestTcpWorkServer
{
    //连接工作服务器成功,请求接入Tcp

    HJFTCPLog(@"连接工作服务器成功,请求接入Tcp");

    //0x82请求接入TCP服务器
    NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERNAME];
    NSString * userpassword = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERPASSWORD];
    //请求接入Tcp
    //读取数据
    [_currentSocket readDataToLength:HeadNoHiddenLen withTimeout:-1 tag:HeadNoHiddenTag];
    NSData * senddata = [ProtocolData requestTcp:[IndexManagerInstance newIndex] username:username password:userpassword];
    [self sendToServerWithData:senddata complete:^(OperatorResult *resultData) {
        if (resultData) {
            //请求成功
            //此时认为TCP连接才算是真正建立
            self.currentConnectStatus = Connected;
            //TCP连接成功
            [self sendDataTcpConnected];
        } else {
            //请求失败
            self.currentConnectStatus = NotConnected;
            
            HJFTCPLog(@"请求连接Tcp失败");
    
            //重新连接TCP服务器
            [self reconnect];
        }
    }];
}

                        

//   发送命令到当前连接的socket
- (void)sendToServerWithData:(NSData *)data complete:(Complete)delegate
{
    SocketOperator * currentOperator = [SocketOperator OperatorWithIndex:[IndexManagerInstance currentIndex] complete:delegate];
    
    HJFTCPLog(@"%@",[NSString stringWithFormat:@"tcp---------sendToServerWithData:index = %d,data = %@",currentOperator.currentIndex,data]);

    [currentOperator startTimer:TCPTimeout];
    [_allOperationArray addObject:currentOperator];
    [_currentSocket writeData:data withTimeout:-1 tag:0];
}


//  处理得到的所有数据_responseData
- (void)dealWithReceiveAllData
{
    UInt8 cmd = [TCP_ResponseAnalysisInstance getProtcolCmd:_responseData];
    NSDictionary *dictinfo = [[NSDictionary alloc] init];
    
    if (cmd == heartBeat) {
       dictinfo = [self serverheartBeatInfo:_responseData];
    }

    else{
        dictinfo = [TCP_ResponseAnalysisInstance analysisServerResponse:_responseData];
    }
    
    OperatorResult * result = [OperatorResult ResultWithdata:_responseData dictionary:dictinfo];
    
    HJFTCPLog(@"%@",[NSString stringWithFormat:@"1111OperatorResult = %@,isMainThread = %d",result,[NSThread isMainThread]]);
    //根据currentIndex找到对应操作,回调
    UInt16 currentIndex = [TCP_ResponseAnalysisInstance indexFromResponse:_responseData];
    SocketOperator * socketOperator = [self getIndexSoketOperator:currentIndex];
    if (socketOperator) {
        //关闭超时定时器
        [socketOperator closetimeoutTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [socketOperator didReceiveResponse:result];
            socketOperator.IsCalledback = YES;
        });
    }
}

//  根据序号找到对应的操作

- (SocketOperator *)getIndexSoketOperator:(UInt16)operatorIndex
{
    NSArray * tempOperatorArray = [NSArray arrayWithArray:_allOperationArray];
    for (SocketOperator * operator in tempOperatorArray) {
        if (operator.currentIndex == operatorIndex) {
            return operator;
        }
        //删除超时的操作
        if (operator.IsTimeout || operator.IsCalledback) {
            
            HJFTCPLog(@"%@",[NSString stringWithFormat:@"删除超时或已经回调操作:operator = %@",operator]);
            [_allOperationArray removeObject:operator];
        }
    }
    return nil;
}


//-----------------------------------------------------------------------
/**
 *  TCP连接成功
 *      1.发送第一次心跳命令
 *      1.订阅所有设备事件
 *      2.查询所有设备TCP是否在线
 */
- (void)sendDataTcpConnected
{
    //发送第一次心跳命令
    [self sendFirstheartbeat];
    for (DevicePreF * deviceinfo in DeviceManageInstance.device_array) {
        //订阅事件
        [self subscribetoeventWith:deviceinfo];
        //查询TCP是否在线
        [self sendTCPIsonline:deviceinfo];

    }
}

////--------------------------心跳检测处理-------------------------------------
////-------------------------------------------------------------------------

//  Tcp连接成功后,发送第一次心跳数据
- (void)sendFirstheartbeat
{
    [self sendheart];
    _intervalheat = 10;
    [_disconnectTimer invalidate];
    _disconnectTimer = nil;
    _disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:_intervalheat*2.5 target:self selector:@selector(stopconnect) userInfo:nil repeats:NO];
}

//  发送心跳包
- (void)sendheart
{
    [self sendToServerWithData:[ProtocolData heartBeatserver:[IndexManagerInstance newIndex]] complete:^(OperatorResult *resultData)
     {
        if (resultData == nil) {
            HJFTCPLog(@"心跳包未接收到回复");
        }
        else {
            HJFTCPLog(@"心跳包收到回复");

        }
    }];
}

//  未检测到心跳,断开连接
- (void)stopconnect
{
    //重新连接TCP服务器
    [self reconnect];
}

// ************ 收到心跳包后会发出通知，并由此函数执行通知********************//


- (void)interval
{
    HJFTCPLog(@"*****************************************************************************");
    HJFTCPLog(@"%@",[NSString stringWithFormat:@"接收到tcp->notification心跳通知:isMainThread = %d,心跳数据:_intervalheat = %f",[NSThread isMainThread],_intervalheat]);
    [self startheartbeat];
 
}

//  执行心跳函数

- (void)startheartbeat
{
    //_intervalheat发送心跳数据
    [_heartbeatTimer invalidate];
    _heartbeatTimer = nil;
    _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:_intervalheat target:self selector:@selector(sendheart) userInfo:nil repeats:NO];
    [_disconnectTimer invalidate];
    _disconnectTimer = nil;
    //心跳断开时间设置为2.5倍interval
    _disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:_intervalheat*2.5 target:self selector:@selector(stopconnect) userInfo:nil repeats:NO];
}

//---------------------------------------------------------------------------------


//发送Tcp设备查询设备是否在线命令 0x84
- (void)sendTCPIsonline:(DevicePreF *)deviceinfo
{
    if (deviceinfo) {
        [self sendToServerWithData:[ProtocolData getonlinestatusWithdeviceinfo:deviceinfo index:[IndexManagerInstance newIndex]] complete:^(OperatorResult *resultData) {
        }];
    }
}

//Tcp设备查询设备是否在线通知
- (void)TcpIsonline:(NSNotification *)notification
{
    NSDictionary  *dict =[notification object];
    NSData * macdata = [dict objectForKey:Mac_Key_data];
    DevicePreF * deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
    [self sendTCPIsonline:deviceinfo];
}

//---------------------------订阅TCP事件------------------------------------------
//订阅事件通知
-(void)Tcpsubscribetoevent:(NSNotification *)notification
{
    NSDictionary  *dict =[notification object];
    NSData * macdata = [dict objectForKey:Mac_Key_data];
    DevicePreF* deviceinfo = [DeviceManageInstance getDevicePreFWithmac:macdata];
    [self subscribetoeventWith:deviceinfo];
}

//订阅设备所有事件
- (void)subscribetoeventWith:(DevicePreF *)deviceinfo
{
    if (deviceinfo) {
        //订阅设备上线/离线事件:0x85
        NSData * senddata = [ProtocolData subscribetoeventsWithdeviceinfo:deviceinfo index:NewIndex issub:YES cmd:0x85];
        HJFTCPLog(@"订阅设备上线/离线事件:0x85");
        [self sendToServerWithData:senddata complete:^(OperatorResult *resultData) {
            if (resultData) {
                HJFTCPLog(@"0x85订阅成功");
            } else {
                HJFTCPLog(@"0x85订阅失败,开始再次订阅");
                NSData * secondsenddata = [ProtocolData subscribetoeventsWithdeviceinfo:deviceinfo index:NewIndex issub:YES cmd:0x85];
                [self sendToServerWithData:secondsenddata complete:^(OperatorResult *resultData) {
                    if (resultData) {
                        HJFTCPLog(@"0x85订阅成功");
                    } else {
                        HJFTCPLog(@"0x85订阅失败");
                    }
                }];
            }
        }];

        
        //0x0F设备主动上报数据
        senddata = [ProtocolData subscribetoeventsWithdeviceinfo:deviceinfo index:NewIndex issub:YES cmd:0x0F];
        [self sendToServerWithData:senddata complete:^(OperatorResult *resultData) {
            if (resultData) {
                HJFTCPLog(@"0x0f订阅成功");
            } else {
                HJFTCPLog(@"0x0f订阅失败,开始再次订阅");
                NSData * secondsenddata = [ProtocolData subscribetoeventsWithdeviceinfo:deviceinfo index:NewIndex issub:YES cmd:0x0F];
                [self sendToServerWithData:secondsenddata complete:^(OperatorResult *resultData) {
                    if (resultData) {
                        HJFTCPLog(@"0x0f订阅成功");
                    } else {
                        HJFTCPLog(@"0x0f订阅失败");

                    }
                }];
            }
        }];
        //其他事件
    }
}


//  处理服务器心跳数据0x61
- (NSDictionary *)serverheartBeatInfo:(NSData *)response
{
    @try {
        //
        _intervalheat = [comMethod uint16FromNetData:[response subdataWithRange:NSMakeRange(17, 2)]];
        NSData *mac  =  [response subdataWithRange:NSMakeRange(2, 6)];
        //跳转到主线程中发送通知
        dispatch_async(dispatch_get_main_queue(), ^{
            [self interval];

        });
        return @{@"interval": [NSString stringWithFormat:@"%f",_intervalheat],
                 @"mac":[NSString stringWithFormat:@"%@",mac]};
        
    } @catch (NSException *exception) {
        //
       HJFTCPLog(@"serverheartBeatInfo>>>exception = %@",exception);
        return nil;
    }
}

@end
