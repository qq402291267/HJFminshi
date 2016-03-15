//
//  SocketOperator.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OperatorResult;

typedef void (^Complete)(OperatorResult *resulData);

@interface SocketOperator : NSObject
//当期操作的index
@property (nonatomic,assign) UInt16 currentIndex;
//是否超时
@property (nonatomic,assign) BOOL IsTimeout;
//是否已经回调
@property (nonatomic,assign) BOOL IsCalledback;

+ (SocketOperator *)OperatorWithIndex:(UInt16)index complete:(Complete)delegate;

- (id)initWithIndex:(UInt16)index complete:(Complete)delegate;

/**
 *  启用定时器,设置超时时间,如果超时时还未返回数据则直接回调接口
 *
 *  @param interval 超时时间
 */
- (void)startTimer:(NSTimeInterval)interval;

/**
 *  已经接收到数据,关闭定时器
 */
- (void)closetimeoutTimer;

/**
 *  回调处理结果
 *
 *  @param result 处理的结果实例
 */
- (void)didReceiveResponse:(OperatorResult *)result;


@end
