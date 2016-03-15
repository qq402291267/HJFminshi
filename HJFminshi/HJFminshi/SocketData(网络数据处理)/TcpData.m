//
//  TcpData.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "TcpData.h"

static TcpData * sigleInstance = nil;

@implementation TcpData

+ (TcpData *)shareTcpData
{
    if (sigleInstance == nil) {
        sigleInstance = [[TcpData alloc] init];
    }
    return sigleInstance;
}

@end
