//
//  TCPUDPdefine.h
//  HJFminshi
//
//  Created by 胡江峰 on 16/3/9.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#ifndef TCPUDPdefine_h
#define TCPUDPdefine_h


/**
 *  敏识连接负载均衡服务器host,port
 */
#define AppBalanceHost      @"minshi-test.yunext.com"
#define AppBalancePort      13593//u
#define UdpBindPort         13530//l
#define DevicePort          13530

//接受字符标识和长度
#define HeadNoHiddenTag     1
#define HiddenTag           2
#define HeadNoHiddenLen     9

//定义minshi模式
#define minshi_Protcol      1
#define sanxing_Protcol     2
#define Type_Protcol        minshi_Protcol
//#define Type_Protcol        sanxing_Protcol



//指令
#define findDeviceOrder          0x23
#define heartBeat                0x61

//超时时间
#define UDPTimeout          10
#define TCPTimeout          30

//key
#define Interval_Key                        @"interval"//tcp心跳时间
#define KEY_IsLock_B                        @"IsLock"//设备是否锁定
#define KEY_ControlType                     @"ControlType_I"//设备类型，主、灯、或雾化器
#define KEY_Result_B                        @"Result_B"//操作是否成功
#define KEY_IsOpen_B                        @"IsOpen_B"//设备是否打开
#define Mac_Key_data                        @"mac"//mac地址


//bookdata定时
#define KEY_BookArray                         @"BookArray"
#define KEY_BookNum_I                         @"BookNum_I"
#define KEY_ErrorCode_I                       @"ErrorCode_I"
//----------------------------------Notification----------------------------------

#define TcpIsonline_Notification            @"TcpIsonline" //设备在线
#define Tcpsubscribetoevent_Notification    @"Tcpsubscribetoevent" //订阅事件
#define GetDeviceStatus_Notification        @"GetDeviceStatus" //更新设备状态
#define AddDeviceViewToArray_Notification   @"AddDeviceViewToArray" //添加设备视图
#define LAN_PUSH_CMD        0x0f


//故障通知, 0xe1~0xe9表示故障
#define DeviceError_Notification             @"DeviceError"






//#define BroadcastHost       @"255.255.255.255"


////推送模式
//#define XG_push           1
//#define JG_push           2
//#define push_Type         XG_push
//#define push_Type         JG_push


///**
// *  三星直接连接工作服务器host,port
// */
//#define AppWorkHost      @"sanxing-test.yunext.com"
//#define AppWorkPort      35593










///**
// *  消息头不是阴影部分的长度,三星与敏识Len所占字节不同,所以程序解析完全不同,需要注意
// */
//#if Type_Protcol == minshi_Protcol
//
//#define KEY_kCFStreamSSLPeerName AppBalanceHost
//
//#define DevicePort          13530
//#elif Type_Protcol == sanxing_Protcol
//#define HeadNoHiddenLen     10
//#define KEY_kCFStreamSSLPeerName AppWorkHost
//#define UdpBindPort         35530
//#define DevicePort          35530
//#endif











#endif /* TCPUDPdefine_h */
