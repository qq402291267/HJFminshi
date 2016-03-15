//
//  UDPMethod.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/28.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

//此方法调用udp
#import <Foundation/Foundation.h>
#import "LocalService.h"

#define UDPMethodInstance [UDPMethod shareUDPMethod]


@interface UDPMethod : NSObject<LocalServiceMethodDelegate>
+ (UDPMethod *)shareUDPMethod;

//UDP绑定
-(void)udpBindConnect;

//判断设备是否在线
-(void)JugeAllDeviceudpOnline;
@end
