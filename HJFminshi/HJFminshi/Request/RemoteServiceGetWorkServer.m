//
//  RemoteServiceGetWorkServer.m
//  minshi
//
//  Created by iTC on 15/7/6.
//  Copyright (c) 2015年 ohbuy. All rights reserved.
//

#import "RemoteServiceGetWorkServer.h"

@interface RemoteServiceGetWorkServer ()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket * _balanceSocket;
    ConnectStatus currentStatus;
    BOOL _isUseSSL;
}

@property (nonatomic,copy) RemoteServiceGetWorkServerComplete Complete;
@property (nonatomic,strong) NSMutableArray * allOperationArray;
@property (nonatomic,strong) NSMutableData * responseData;

@end

static RemoteServiceGetWorkServer * singleRemoteServiceGetWorkServer = nil;

@implementation RemoteServiceGetWorkServer

+ (RemoteServiceGetWorkServer *)shareRemoteServiceGetWorkServer
{
    if (singleRemoteServiceGetWorkServer == nil) {
        singleRemoteServiceGetWorkServer = [[RemoteServiceGetWorkServer alloc] init];
    }
    return singleRemoteServiceGetWorkServer;
}

- (instancetype)init
{
    if (self = [super init]) {
        _allOperationArray = [[NSMutableArray alloc] init];
        currentStatus = ConnectStatus_failed;
    }
    return self;
}

- (void)connectgetWorkServerWithIsUseSSL:(BOOL)isUseSSL Complete:(RemoteServiceGetWorkServerComplete)Complete
{
    _isUseSSL = isUseSSL;
    _Complete = Complete;
    //连接服务器
    _balanceSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //连接负载均衡服务器
    NSError * error = nil;
    if (![_balanceSocket connectToHost:AppBalanceHost onPort:AppBalancePort error:&error]) {
        NSString * failmsg = [NSString stringWithFormat:@"连接负载均衡服务器出错:error = %@",[error localizedDescription]];
        currentStatus = ConnectStatus_failed;
        _Complete(currentStatus,nil,0,failmsg);
    }
}

//---------------------------GCDAsyncSocketDelegate------------------------
//-------------------------------------------------------------------------
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if (_isUseSSL) {
        //使用ssl连接
        //设置SSL通信证书
        NSDictionary * sslSetting = [Util getsslSettingWithhost:KEY_kCFStreamSSLPeerName];
        if (sslSetting) {
            [_balanceSocket startTLS:sslSetting];
        } else {
            NSString * failmsg = @"sslSetting设置为空,不能设置ssl";
            currentStatus = ConnectStatus_failed;
            _Complete(currentStatus,nil,0,failmsg);
        }
        
    } else {
        //不适用ssl连接,直接获取工作服务器IP,PORT
        [self GetWorkServer];
    }
}

/**
 *  Allows a socket delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
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
    //ssl连接成功
    [self GetWorkServer];
}

//Called when a socket disconnects with or without error.
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    //连接失败或连接被服务器关闭
    if (currentStatus == ConnectStatus_failed) {
        //连接失败
        _Complete(currentStatus,nil,0,[NSString stringWithFormat:@"socketDidDisconnect:err = %@",[err localizedDescription]]);
    }
    [_balanceSocket setDelegate:nil];
    [_balanceSocket disconnect];
    _balanceSocket = nil;
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //接收到数据
    if (tag == HeadNoHiddenTag) {
        _responseData = [[NSMutableData alloc] initWithData:data];
        //1.读取第一部分数据帧头未加密数据,得到需要读取的加密部分的长度
        UInt8 secondlength = ((UInt8 *)[data bytes])[8];  //敏识格式 Len一个字节
        [_balanceSocket readDataToLength:secondlength withTimeout:-1 tag:HiddenTag];
    } else {
        //得到第二部分数据
        [_responseData appendData:data];
        //处理数据
        [self dealWithReceiveAllData];
    }
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //发送数据完毕
    NSLog(@"didWriteDataWithTag:tag = %ld",tag);
}
//----------------------------------------------------------------------
//获取工作服务器
- (void)GetWorkServer
{
    //从负载均衡服务器获取工作服务器IP.Port
    [_balanceSocket readDataToLength:HeadNoHiddenLen withTimeout:-1 tag:HeadNoHiddenTag];
    [self sendToServerWithData:[ProtocolData workingServer:[IndexManagerInstance newIndex]] complete:^(OperatorResult *resultData) {
        //得到工作服务器IP.Port
        if (resultData == nil) {
            currentStatus = ConnectStatus_failed;
            _Complete(currentStatus,nil,0,@"获取工作服务器失败,超时");
        } else {
            //获取工作服务器成功
            NSString * host = TcpDataInstance.host;
            int port = TcpDataInstance.port;
            currentStatus = ConnectStatus_success;
            _Complete(currentStatus,host,port,@"获取工作服务器成功");
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
    NSLog(@"sendToServerWithData:index = %d,data = %@",currentOperator.currentIndex,data);
    [currentOperator startTimer:TCPTimeout];
    [_allOperationArray addObject:currentOperator];
    [_balanceSocket writeData:data withTimeout:-1 tag:0];
}

/**
 *  处理得到的所有数据_responseData
 */
- (void)dealWithReceiveAllData
{
    NSLog(@"_allOperationArray = %@",_allOperationArray);
    //得到返回字典
    NSDictionary * dictinfo = [ResponseAnalysis analysisServerResponse:_responseData];
    //得到返回信息
    OperatorResult * result = [OperatorResult ResultWithdata:_responseData dictionary:dictinfo];
    NSLog(@"OperatorResult = %@",result);
    //根据currentIndex找到对应操作,回调
    UInt16 currentIndex = [ResponseAnalysis indexFromResponse:_responseData];
    SocketOperator * socketOperator = [self getIndexSoketOperator:currentIndex];
    if (socketOperator) {
        [_allOperationArray removeObject:socketOperator];
        NSLog(@"找到对应的操作,回调操作:_allOperationArray = %@",_allOperationArray);
        [socketOperator didReceiveResponse:result];
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
    NSLog(@"_allOperationArray = %@",_allOperationArray);
    for (SocketOperator * operator in _allOperationArray) {
        if (operator.currentIndex == operatorIndex) {
            return operator;
        }
    }
    return nil;
}

@end
