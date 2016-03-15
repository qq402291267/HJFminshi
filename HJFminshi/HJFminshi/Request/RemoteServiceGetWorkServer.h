//
//  RemoteServiceGetWorkServer.h
//  minshi
//
//  Created by iTC on 15/7/6.
//  Copyright (c) 2015年 ohbuy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

typedef enum{
    ConnectStatus_success,
    ConnectStatus_failed
} ConnectStatus;

typedef void (^RemoteServiceGetWorkServerComplete)(ConnectStatus resultStatus,NSString * host,uint16_t port,NSString * failmsg);

#define RemoteServiceGetWorkServerInstance  [RemoteServiceGetWorkServer shareRemoteServiceGetWorkServer]

@interface RemoteServiceGetWorkServer : NSObject

+ (RemoteServiceGetWorkServer *)shareRemoteServiceGetWorkServer;

- (void)connectgetWorkServerWithIsUseSSL:(BOOL)isUseSSL Complete:(RemoteServiceGetWorkServerComplete)Complete;

@end
