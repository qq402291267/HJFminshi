//
//  RemoteService.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketOperator.h"


#define RemoteServiceInstance [RemoteService shareRemoteService]
typedef enum
{
    NotConnected  = 0,
    Connecting    = 1,
    Connected     = 2
} TcpConnectStatus;
@interface RemoteService : NSObject


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
