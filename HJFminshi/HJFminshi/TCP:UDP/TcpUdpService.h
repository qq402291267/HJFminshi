//
//  TcpUdpService.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketOperator.h"
#define TcpUdpServiceInstance      [TcpUdpService shareTcpUdpService]

@interface TcpUdpService : NSObject

+ (TcpUdpService *)shareTcpUdpService;

#if OS_OBJECT_USE_OBJC
@property (nonatomic,strong,readonly) dispatch_queue_t single_Queue;
#else
@property (nonatomic,assign,readonly) dispatch_queue_t single_Queue;
#endif

//发送不与设备相关的命令
- (void)sendData:(NSData *)data isRemote:(BOOL)isRemote complete:(Complete)delegate;

//发送与设备相关的命令
- (void)sendData:(NSData *)data deviceinfo:(DevicePreF *)deviceinfo complete:(Complete)delegate;
@end
