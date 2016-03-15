//
//  NetworkUtil.m
//  LifeShanghai
//
//  Created by wenjun on 12-12-1.
//
//

#import "NetworkUtil.h"
#define BaiduURL @"www.baidu.com"

@interface NetworkUtil ()

@property (nonatomic,weak) id<NetworkUtilDelegate> networkDelegate;
@property (strong,nonatomic) Reachability * reachability;

@property (nonatomic,assign) BOOL IsInitNetWorkSataus;

@end

static NetworkUtil* singleton = nil;

@implementation NetworkUtil

+ (NetworkUtil *)shareNetworkUtil
{
    @synchronized(self)
    {
        if (singleton == nil)
        {
            singleton = [[self alloc] init];
            singleton.reachability = [Reachability reachabilityWithHostname:BaiduURL];
        }
    }
    return  singleton;
}

- (instancetype)init
{
    if (self = [super init]) {
        _networkDelegate = nil;
        _IsInitNetWorkSataus = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EnterBackground:) name:EnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isNetworkEnabled
{
    return NetworkUtilInstance.reachability.currentReachabilityStatus != NotReachable;
}

- (SCNetworkReachabilityFlags)networkFlags
{
    return NetworkUtilInstance.reachability.reachabilityFlags;
}

- (ReachabilityNetworkStatus)networkStatus
{
    return NetworkUtilInstance.reachability.currentReachabilityStatus;
}

- (void)setNetworkStatusDelegate:(id<NetworkUtilDelegate>)delegate
{
    if (delegate != _networkDelegate) {
        [self removeNotification];
    }
    _networkDelegate = delegate;
    if (_networkDelegate != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        [NetworkUtilInstance.reachability startNotifier];
    }
}

- (void)removeNotification
{
    if (_networkDelegate) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [NetworkUtilInstance.reachability stopNotifier];
    }
}

- (void)reachabilityChanged:(NSNotification *)note
{
    if (!_IsInitNetWorkSataus) {
        _IsInitNetWorkSataus = YES;
        return;
    }
    [_networkDelegate networkStatusChanged:[self networkStatus]];
}

- (void)EnterBackground:(NSNotification *)notification
{
    _IsInitNetWorkSataus = NO;
    NSLog(@">>>>>>>>接收到程序进入后台通知");
}


@end
