//
//  SocketError.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>


#define CustomErrorDomain @"com.oubuy.minshi"

typedef enum {
    XDefultFailed = -1000,
    XRegisterFailed,
    XConnectFailed,
    XNotBindedFailed
} CustomErrorFailed;

@interface SocketError : NSError

+ (SocketError *)errorWithcode:(CustomErrorFailed)code userInfo:(NSDictionary *)userInfo;




@end
