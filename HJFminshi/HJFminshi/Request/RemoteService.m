//
//  RemoteService.m
//  minshi
//
//  Created by iTC on 15/6/17.
//  Copyright (c) 2015年 ohbuy. All rights reserved.
//

#import "RemoteService.h"
#import "GCDAsyncSocket.h"

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

+ (RemoteService * )shareRemoteService
{
    if (singleInstance == nil) {
        singleInstance = [[RemoteService alloc] init];
    }
    return singleInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _currentConnectStatus = NotConnected;
        _allOperationArray = [[NSMutableArray alloc] init];
        _intervalheat = 10;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interval:) name:ServerInterval_Notification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TcpIsonline:) name:TcpIsonline_Notification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Tcpsubscribetoevent:) name:Tcpsubscribetoevent_Notification object:nil];
        //不加密
        _isencrpt = NO;
        //敏识是否使用ssl加密
        IsUseSsl = YES;
    }
    return self;
}

/**
 *  判断连接并开启定时器
 */
- (void)JudgeConnect
{
    NSString * userName = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERNAME];
    NSString * userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERPASSWORD];
    if (userName == nil || [userName isEqualToString:@""] || [userName isEqual:[NSNull null]] || userPassword == nil || [userPassword isEqualToString:@""] || [userPassword isEqual:[NSNull null]]) {
        [_msgdelegate remoteconnectMsg:@"用户未登录,不能连接Tcp服务器" connectSuccessful:NO];
        return;
    } else {
        //连接TCP
        [self connectfunction];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //开启定时器判断Tcp是否已经连接,如果延时30s后连接仍然未建立,则reconnect
        [_connecttimeoutTimer invalidate];
        _connecttimeoutTimer = nil;
        _connecttimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(JudgeReconnect) userInfo:nil repeats:NO];
    });
}

/**
 *  判断是否需要重连
 */
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

- (void)connectfunction
{
    //判断是否已经连接上TCP服务器
    if (_currentConnectStatus == NotConnected) {
        //开始连接
        if ([NetworkUtilInstance networkStatus] != NotReachable) {
            [_msgdelegate remoteconnectMsg:@"未连接,开始连接" connectSuccessful:NO];
            _currentConnectStatus = Connecting;
            [self connect];
        } else {
            [_msgdelegate remoteconnectMsg:@"未连接,网络不可用" connectSuccessful:NO];
        }
        
    } else if (_currentConnectStatus == Connecting) {
        //正在连接
        [_msgdelegate remoteconnectMsg:@"设备正在连接" connectSuccessful:NO];
    } else {
        //已经连接
        [_msgdelegate remoteconnectMsg:@"设备已经连接" connectSuccessful:YES];
    }
}

#if Type_Protcol == minshi_Protcol
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
            [self.msgdelegate remoteconnectMsg:@"连接负载均衡服务器失败" connectSuccessful:NO];
            
        } else {
            //连接成功,开始连接工作服务器
            self.currentSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:TcpUdpServiceInstance.single_Queue];
            [self.msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"开始连接工作服务器:host = %@,port = %d",host,port] connectSuccessful:NO];
            NSError * error = nil;
            //连接工作服务器
            if (![self.currentSocket connectToHost:host onPort:port error:&error]) {
                [self.msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"连接工作服务器失败"] connectSuccessful:NO];
            }
            //end
        }
    }];
}

#elif Type_Protcol == sanxing_Protcol
//适用于三星项目,直接连接工作服务器
- (void)connect
{
    _currentSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:single_Queue];
    //连接负载均衡服务器
    NSError * error = nil;
    if (![_currentSocket connectToHost:AppWorkHost onPort:AppWorkPort error:&error]) {
        [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"连接工作服务器出错:error = %@",[error localizedDescription]] connectSuccessful:NO];
    }
}
#endif

/**
 *  服务器连接未成功,需要重连
 */
- (void)reconnect
{
    [self disconnect];
    [_msgdelegate remoteconnectMsg:@"断开当前连接,重连服务器" connectSuccessful:NO];
    [self JudgeConnect];
}

/**
 *  断开当前连接
 */
- (void)disconnect
{
    _currentSocket.delegate = nil;
    [_currentSocket disconnect];
    _currentSocket = nil;
    _currentConnectStatus = NotConnected;
    //设置设备tcp断线,并关闭定时器
    for (DeviceAllInfo * deviceinfo in AllDeviceInstance.device_array) {
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
#if Type_Protcol == minshi_Protcol
//使用ssl加密
/**
 * 适用与敏识需获取工作服务器项目
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if (IsUseSsl) {
        //设置ssl字典
        NSDictionary * sslSetting = [Util getsslSettingWithhost:TcpDataInstance.host];
        //开始设置SSL Setting
        [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"SSL设置字典:sslSetting = %@",sslSetting] connectSuccessful:NO];
        if (sslSetting) {
            [_currentSocket startTLS:sslSetting];
        } else {
            [_msgdelegate remoteconnectMsg:@"sslSetting设置为空,不能设置ssl" connectSuccessful:NO];
        }
    } else {
        //不使用ssl,连接工作服务器成功,请求接入TCP
        //请求接入TCP-0x82
        [self requestTcpWorkServer];
    }
}

#elif Type_Protcol == sanxing_Protcol
//适用于三星项目
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //工作服务器连接回调
    //设置SSL通信证书
    NSDictionary * sslSetting = [Util getsslSettingWithhost:KEY_kCFStreamSSLPeerName];
    [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"SSL设置字典:sslSetting = %@",sslSetting] connectSuccessful:NO];
    if (sslSetting) {
        [_currentSocket startTLS:sslSetting];
    } else {
        [_msgdelegate remoteconnectMsg:@"sslSetting设置为空,不能设置ssl" connectSuccessful:NO];
    }
}
#endif

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
    [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"连接断开:socketDidDisconnect,err = %@",[err localizedDescription]] connectSuccessful:NO];
    [self JudgeConnect];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"didReadData:tag = %ld,isMainThread = %d",tag,[NSThread isMainThread]] connectSuccessful:YES];
    if (tag == HeadNoHiddenTag) {
        _responseData = [[NSMutableData alloc] initWithData:data];
        //1.读取第一部分数据帧头未加密数据,得到需要读取的加密部分的长度
#if Type_Protcol == minshi_Protcol
        UInt8 secondlength = ((UInt8 *)[data bytes])[8];  //敏识格式 Len一个字节
#elif Type_Protcol == sanxing_Protcol
        //三星格式 Len 两个字节
        UInt8 hightlength = ((UInt8 *)[data bytes])[8];
        UInt8 lowlength = ((UInt8 *)[data bytes])[9];
        UInt16 secondlength = (hightlength << 8) | lowlength;
#endif
        [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"读取第一部分数据完毕,开始读取第二部分数据:%@",data] connectSuccessful:YES];
        [_currentSocket readDataToLength:secondlength withTimeout:-1 tag:HiddenTag];
    } else {
        //得到第二部分数据
        [_responseData appendData:data];
        [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"第二部分数据读取完毕,开始处理数据:_responseData = %@",_responseData] connectSuccessful:YES];
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
    [_msgdelegate remoteconnectMsg:@"发送数据完成" connectSuccessful:YES];
}
//--------------------------function---------------------------------------
//-------------------------------------------------------------------------
//请求接入TCP-0x82
- (void)requestTcpWorkServer
{
    //连接工作服务器成功,请求接入Tcp
    [_msgdelegate remoteconnectMsg:@"连接工作服务器成功,请求接入Tcp" connectSuccessful:NO];
    //0x82请求接入TCP服务器
    NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERNAME];
    NSString * userpassword = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERPASSWORD];
    //请求接入Tcp
    //读取数据
    [_currentSocket readDataToLength:HeadNoHiddenLen withTimeout:-1 tag:HeadNoHiddenTag];
    NSData * senddata = [ProtocolData requestTcp:[IndexManagerInstance newIndex] username:username password:userpassword];
    [self sendToServerWithData:senddata complete:^(OperatorResult *resultData) {
        //
        if (resultData) {
            //请求成功
            //此时认为TCP连接才算是真正建立
            self.currentConnectStatus = Connected;
            //TCP连接成功
            [self sendDataTcpConnected];
            
        } else {
            //请求失败
            self.currentConnectStatus = NotConnected;
            [self.msgdelegate remoteconnectMsg:@"请求连接Tcp失败" connectSuccessful:NO];
            //重新连接TCP服务器
            [self reconnect];
        }
    }];
}

/**
 *  发送命令到当前连接的socket
 *
 *  @param data     要发送的全部数据
 *  @param delegate 代理回调
 */
- (void)sendToServerWithData:(NSData *)data complete:(Complete)delegate
{
    SocketOperator * currentOperator = [SocketOperator OperatorWithIndex:[IndexManagerInstance currentIndex] complete:delegate];
    [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"tcp>>>>sendToServerWithData:index = %d,data = %@",currentOperator.currentIndex,data] connectSuccessful:YES];
    [currentOperator startTimer:TCPTimeout];
    [_allOperationArray addObject:currentOperator];
    [_currentSocket writeData:data withTimeout:-1 tag:0];
}

/**
 *  处理得到的所有数据_responseData
 */
- (void)dealWithReceiveAllData
{
    //得到返回字典
    NSDictionary * dictinfo = [ResponseAnalysis analysisServerResponse:_responseData];
    //得到返回信息
    OperatorResult * result = [OperatorResult ResultWithdata:_responseData dictionary:dictinfo];
    [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"OperatorResult = %@,isMainThread = %d",result,[NSThread isMainThread]] connectSuccessful:YES];
    //根据currentIndex找到对应操作,回调
    UInt16 currentIndex = [ResponseAnalysis indexFromResponse:_responseData];
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
            [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"删除超时或已经回调操作:operator = %@",operator] connectSuccessful:YES];
            [_allOperationArray removeObject:operator];
        }
    }
    return nil;
}

//--------------------------心跳检测处理-------------------------------------
//-------------------------------------------------------------------------
/**
 *  Tcp连接成功后,发送第一次心跳数据
 */
- (void)sendFirstheartbeat
{
    [self sendheart];
    _intervalheat = 10;
    [_disconnectTimer invalidate];
    _disconnectTimer = nil;
    _disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:_intervalheat*2.5 target:self selector:@selector(stopconnect) userInfo:nil repeats:NO];
}

/**
 *  通知处理函数
 *
 *  @param notification
 */
- (void)interval:(NSNotification *)notification
{
    NSDictionary  *dict =[notification object];
    _intervalheat = [[dict objectForKey:Interval_Key] intValue];
    [_msgdelegate remoteconnectMsg:[NSString stringWithFormat:@"接收到tcp->notification心跳通知:isMainThread = %d,心跳数据:_intervalheat = %f",[NSThread isMainThread],_intervalheat] connectSuccessful:YES];
    [self startheartbeat];
}

/**
 *  执行心跳函数
 */
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

/**
 *  发送心跳包
 */
- (void)sendheart
{
    [self sendToServerWithData:[ProtocolData heartBeatserver:[IndexManagerInstance newIndex]] complete:^(OperatorResult *resultData) {
        if (resultData == nil) {
            [self.msgdelegate remoteconnectMsg:@"心跳包未接收到回复" connectSuccessful:YES];
        } else {
            [self.msgdelegate remoteconnectMsg:@"心跳包收到回复" connectSuccessful:YES];
        }
    }];
}

/**
 *  未检测到心跳,断开连接
 */
- (void)stopconnect
{
    //重新连接TCP服务器
    [self reconnect];
}
//---------------------------------------------------------------------------------
//Tcp设备查询设备是否在线通知
- (void)TcpIsonline:(NSNotification *)notification
{
    NSDictionary  *dict =[notification object];
    NSData * macdata = [dict objectForKey:Mac_Key_data];
    DeviceAllInfo * deviceinfo = [AllDeviceInstance getDeviceAllInfoWithmac:macdata];
    [self sendTCPIsonline:deviceinfo];
}

//发送Tcp设备查询设备是否在线命令
- (void)sendTCPIsonline:(DeviceAllInfo *)deviceinfo
{
    if (deviceinfo) {
        [self sendToServerWithData:[ProtocolData getonlinestatusWithdeviceinfo:deviceinfo index:[IndexManagerInstance newIndex]] complete:^(OperatorResult *resultData) {
        }];
    }
}

//---------------------------订阅TCP事件------------------------------------------
//订阅事件通知
-(void)Tcpsubscribetoevent:(NSNotification *)notification
{
    NSDictionary  *dict =[notification object];
    NSData * macdata = [dict objectForKey:Mac_Key_data];
    DeviceAllInfo * deviceinfo = [AllDeviceInstance getDeviceAllInfoWithmac:macdata];
    [self subscribetoeventWith:deviceinfo];
}

//订阅设备所有事件
- (void)subscribetoeventWith:(DeviceAllInfo *)deviceinfo
{
    if (deviceinfo) {
        //订阅设备上线/离线事件:0x85
        NSData * senddata = [ProtocolData subscribetoeventsWithdeviceinfo:deviceinfo index:NewIndex issub:YES cmd:0x85];
        [_msgdelegate remoteconnectMsg:@"订阅设备上线/离线事件:0x85" connectSuccessful:YES];
        [self sendToServerWithData:senddata complete:^(OperatorResult *resultData) {
            if (resultData) {
                [self.msgdelegate remoteconnectMsg:@"0x85订阅成功" connectSuccessful:YES];
            } else {
                [self.msgdelegate remoteconnectMsg:@"0x85订阅失败,开始再次订阅" connectSuccessful:YES];
                NSData * secondsenddata = [ProtocolData subscribetoeventsWithdeviceinfo:deviceinfo index:NewIndex issub:YES cmd:0x85];
                [self sendToServerWithData:secondsenddata complete:^(OperatorResult *resultData) {
                    if (resultData) {
                        [self.msgdelegate remoteconnectMsg:@"0x85订阅成功" connectSuccessful:YES];
                    } else {
                        [self.msgdelegate remoteconnectMsg:@"0x85订阅失败" connectSuccessful:YES];
                    }
                }];
            }
        }];
        [_msgdelegate remoteconnectMsg:@"设备主动上报数据:0x0F" connectSuccessful:YES];
        //0x0F设备主动上报数据
        senddata = [ProtocolData subscribetoeventsWithdeviceinfo:deviceinfo index:NewIndex issub:YES cmd:0x0F];
        [self sendToServerWithData:senddata complete:^(OperatorResult *resultData) {
            if (resultData) {
                [self.msgdelegate remoteconnectMsg:@"0x0f订阅成功" connectSuccessful:YES];
            } else {
                [self.msgdelegate remoteconnectMsg:@"0x0f订阅失败,开始再次订阅" connectSuccessful:YES];
                NSData * secondsenddata = [ProtocolData subscribetoeventsWithdeviceinfo:deviceinfo index:NewIndex issub:YES cmd:0x0F];
                [self sendToServerWithData:secondsenddata complete:^(OperatorResult *resultData) {
                    if (resultData) {
                        [self.msgdelegate remoteconnectMsg:@"0x0f订阅成功" connectSuccessful:YES];
                    } else {
                        [self.msgdelegate remoteconnectMsg:@"0x0f订阅失败" connectSuccessful:YES];
                    }
                }];
            }
        }];
        //其他事件
    }
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
    for (DeviceAllInfo * deviceinfo in AllDeviceInstance.device_array) {
        //订阅事件
        [self subscribetoeventWith:deviceinfo];
        //查询TCP是否在线
        [self sendTCPIsonline:deviceinfo];
        
    }
}


@end
