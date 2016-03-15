//
//  TcpUdpService.h
//  minshi
//
//  Created by iTC on 15/7/13.
//  Copyright (c) 2015年 ohbuy. All rights reserved.
//

#import <Foundation/Foundation.h>

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
- (void)sendData:(NSData *)data deviceinfo:(DeviceAllInfo *)deviceinfo complete:(Complete)delegate;

@end
