//
//  RemoteServiceGetWorkServer.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>


#define RemoteServiceGetWorkServerInstance  [RemoteServiceGetWorkServer shareRemoteServiceGetWorkServer]
typedef enum{
    ConnectStatus_success,
    ConnectStatus_failed
} ConnectStatus;

typedef void (^RemoteServiceGetWorkServerComplete)(ConnectStatus resultStatus,NSString * host,uint16_t port,NSString * failmsg);
@interface RemoteServiceGetWorkServer : NSObject

+ (RemoteServiceGetWorkServer *)shareRemoteServiceGetWorkServer;

- (void)connectgetWorkServerWithIsUseSSL:(BOOL)isUseSSL Complete:(RemoteServiceGetWorkServerComplete)Complete;
@end
