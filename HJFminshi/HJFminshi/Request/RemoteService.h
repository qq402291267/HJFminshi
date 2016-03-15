//
//  RemoteService.h
//  minshi
//
//  Created by iTC on 15/6/17.
//  Copyright (c) 2015年 ohbuy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RemoteServiceInstance [RemoteService shareRemoteService]

typedef enum
{
    NotConnected  = 0,
    Connecting    = 1,
    Connected     = 2
} TcpConnectStatus;

@protocol RemoteDelegate <NSObject>

@required
- (void)remoteconnectMsg:(NSString *)msg connectSuccessful:(BOOL)connected;

@end

@interface RemoteService : NSObject

@property (nonatomic,weak) id<RemoteDelegate> msgdelegate;

/**
 *  数据是否加密
 */
@property (nonatomic,assign,readonly) BOOL isencrpt;

+ (RemoteService * )shareRemoteService;

/**
 *  判断连接并开启定时器
 */
- (void)JudgeConnect;

/**
 *  断开当前连接
 */
- (void)disconnect;

/**
 *  发送命令到当前连接的socket
 *
 *  @param data     要发送的全部数据
 *  @param delegate 代理回调
 */
- (void)sendToServerWithData:(NSData *)data complete:(Complete)delegate;



@end
