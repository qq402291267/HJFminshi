//
//  TcpUdpService.m
//  minshi
//
//  Created by iTC on 15/7/13.
//  Copyright (c) 2015年 ohbuy. All rights reserved.
//

#import "TcpUdpService.h"

static TcpUdpService * singleInstance = nil;
NSString *const TcpUdpServiceQueueName = @"TcpUdpServiceQueueName";

@implementation TcpUdpService

+ (TcpUdpService *)shareTcpUdpService
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (singleInstance == nil) {
            singleInstance = [[TcpUdpService alloc] init];
        }
    });
    return singleInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        //single_Queue
        _single_Queue = dispatch_queue_create([TcpUdpServiceQueueName UTF8String], DISPATCH_QUEUE_SERIAL);
        //Queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        /*
         NSString * str = @"Name";
         const char * queuename = [str UTF8String];
         Queue = dispatch_queue_create(queuename, DISPATCH_QUEUE_PRIORITY_DEFAULT);
         */
    }
    return self;
}

//发送不与设备相关的命令
- (void)sendData:(NSData *)data isRemote:(BOOL)isRemote complete:(Complete)delegate
{
    if (isRemote) {
        //udp
        [LocalServiceInstance sendToDeviceWithData:data deviceinfo:nil complete:delegate];
    } else {
        //tcp
        [RemoteServiceInstance sendToServerWithData:data complete:delegate];
    }
}

//发送与设备相关的命令
- (void)sendData:(NSData *)data deviceinfo:(DeviceAllInfo *)deviceinfo complete:(Complete)delegate
{
    if (deviceinfo.localIsOnline) {
        //udp
        [LocalServiceInstance sendToDeviceWithData:data deviceinfo:deviceinfo complete:delegate];
    } else {
        //tcp
        [RemoteServiceInstance sendToServerWithData:data complete:delegate];
    }
}



@end
