//
//  TcpData.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TcpDataInstance [TcpData shareTcpData]

@interface TcpData : NSObject

+ (TcpData *)shareTcpData;

/**
 *  是否是第一次加载,如果不是第一次加载则可以直接TCP连接
 */
@property (nonatomic,assign) BOOL IsFirstLoad;
/**
 *  TCP连接host
 */
@property (nonatomic,strong) NSString * host;
/**
 *  TCP连接port
 */
@property (nonatomic,assign) UInt16 port;

@end
