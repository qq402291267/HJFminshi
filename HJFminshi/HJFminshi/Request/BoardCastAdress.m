//
//  BoardCastAdress.m
//  minshi
//
//  Created by iTC on 15/7/28.
//  Copyright (c) 2015年 ohbuy. All rights reserved.
//

#import "BoardCastAdress.h"
//#import "getgateway.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <ifaddrs.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <sys/socket.h>

@interface BoardCastAdress ()

@property (nonatomic,copy) NSString * BoardCastAdress;

@end

static BoardCastAdress * signleInstance = nil;

@implementation BoardCastAdress

+ (BoardCastAdress *)shareBoardCastAdress
{
    if (signleInstance == nil) {
        signleInstance = [[BoardCastAdress alloc] init];
    }
    return signleInstance;
}

//获取当前广播地址
- (NSString *)getcurrentBroadCastAddress
{
    return _BoardCastAdress;
}

/**
 *  更新广播地址
 *  局域网监听时更新
 */
- (void)updateBroadCastAddress
{
    NSLog(@"//////////////updateBroadCastAddress:begin");
    if ([NetworkUtilInstance networkStatus] == ReachableViaWiFi) {
        //连接wifi网络,获取广播地址
        _BoardCastAdress = [self getrouterBroadCastAddress];
    }
    NSLog(@"//////////////updateBroadCastAddress:end");
}

//--------------------------------------------------------------------
//获取路由器的广播地址
- (NSString *)getrouterBroadCastAddress
{
    NSString * routerBroadCastAddress = @"255.255.255.255";
    NSString * localIPAddress = nil;
    NSString * netmask = nil;
    NSString * en0Port = nil;
    NSString *address = @"error";
    //
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        //Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String //ifa_addr
                    //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
                    
                    //routerBroadCastAddress
                    routerBroadCastAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    NSLog(@"routerBroadCastAddress = %@",routerBroadCastAddress);
                    //localIPAddress
                    localIPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    NSLog(@"localIPAddress = %@",localIPAddress);
                    //netmask
                    netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                    NSLog(@"netmask = %@",netmask);
                    //en0Port
                    en0Port = [NSString stringWithUTF8String:temp_addr->ifa_name];
                    NSLog(@"en0Port = %@",en0Port);
                    //address
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    NSLog(@"address = %@",address);
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    //Free memory
    freeifaddrs(interfaces);
    return routerBroadCastAddress;
}

//--------------------------------------------------------------------

@end
