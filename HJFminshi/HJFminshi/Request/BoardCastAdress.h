//
//  BoardCastAdress.h
//  minshi
//
//  Created by iTC on 15/7/28.
//  Copyright (c) 2015年 ohbuy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BoardCastAdressInstance [BoardCastAdress shareBoardCastAdress]

@interface BoardCastAdress : NSObject

+ (BoardCastAdress *)shareBoardCastAdress;

/**
 *  更新广播地址
 *  局域网监听时更新
 */
- (void)updateBroadCastAddress;

//获取当前广播地址
- (NSString *)getcurrentBroadCastAddress;

@end
