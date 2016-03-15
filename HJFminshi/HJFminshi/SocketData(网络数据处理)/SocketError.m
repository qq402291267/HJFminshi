//
//  SocketError.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "SocketError.h"

@implementation SocketError

+ (SocketError *)errorWithcode:(CustomErrorFailed)code userInfo:(NSDictionary *)userInfo
{
    SocketError * error = [[SocketError alloc] initWithDomain:CustomErrorDomain code:code userInfo:userInfo];
    return error;
}

- (NSString *)description
{
    NSDictionary * dict = @{@"CustomErrorDomain":CustomErrorDomain,
                            @"code":[NSString stringWithFormat:@"%ld",(long)[super code]],
                            @"errordescription":[super userInfo]};
    return [dict description];
}

@end
