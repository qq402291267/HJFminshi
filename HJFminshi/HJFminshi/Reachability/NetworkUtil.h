//
//  NetworkUtil.h
//  LifeShanghai
//
//  Created by wenjun on 12-12-1.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

#define NetworkUtilInstance [NetworkUtil shareNetworkUtil]
#define EnterBackgroundNotification @"EnterBackgroundNotification"

@protocol NetworkUtilDelegate <NSObject>
@required
- (void)networkStatusChanged:(ReachabilityNetworkStatus)status;
@end

@interface NetworkUtil : NSObject

+ (NetworkUtil *)shareNetworkUtil;
- (BOOL)isNetworkEnabled;
- (SCNetworkReachabilityFlags)networkFlags;
- (ReachabilityNetworkStatus)networkStatus;
- (void)setNetworkStatusDelegate:(id<NetworkUtilDelegate>)delegate;
- (void)removeNotification;


@end
