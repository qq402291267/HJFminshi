//
//  SocketOperator.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "SocketOperator.h"

@interface SocketOperator ()

//回调接口
@property (nonatomic,copy) Complete delegate;
//定时器检测超时
@property (nonatomic,strong) NSTimer * timeoutTimer;

@end

@implementation SocketOperator

+ (SocketOperator *)OperatorWithIndex:(UInt16)index complete:(Complete)delegate
{
    SocketOperator * result = [[SocketOperator alloc] initWithIndex:index complete:delegate];
    return result;
}

- (id)initWithIndex:(UInt16)index complete:(Complete)delegate
{
    if (self = [super init]) {
        _currentIndex = index;
        _delegate = delegate;
        _IsTimeout = NO;
        _IsCalledback = NO;
    }
    return self;
}

/**
 *  启用定时器,设置超时时间,如果超时时还未返回数据则直接回调接口
 *
 *  @param interval 超时时间
 */
- (void)startTimer:(NSTimeInterval)interval
{
//    HJFLog(@"<<<<<<<<设置超时定时器,isMainThread = %d",[NSThread isMainThread]);
    if ([NSThread isMainThread]) {
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timeout) userInfo:nil repeats:NO];
    } else {
        //必须主线程中设置超时定时器
        dispatch_async(dispatch_get_main_queue(), ^{
            _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timeout) userInfo:nil repeats:NO];
        });
    }
}

/**
 *  操作超时,强制回调
 */
- (void)timeout
{
    [self didReceiveResponse:nil];
    _IsTimeout = YES;
}

/**
 *  已经接收到数据,关闭定时器
 */
- (void)closetimeoutTimer
{
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
}

/**
 *  回调处理结果
 *
 *  @param result 处理的结果实例
 */
- (void)didReceiveResponse:(OperatorResult *)result
{
    if (_timeoutTimer != nil) {
        [self closetimeoutTimer];
    }
    if (_delegate)
    {
        _delegate(result);
        _delegate = nil;

    }

}

- (NSString *)description
{
    NSString * result = [NSString stringWithFormat:@"currentIndex = %d,IsTimeout = %d",_currentIndex,_IsTimeout];
    return result;
}

@end

