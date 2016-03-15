//
//  HTTPcomMethod.h
//  HJFminshi
//
//  Created by 胡江峰 on 16/3/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPcomMethod : NSObject

//获取app名字
+ (NSString *)getAppName;

//获取app版本
+ (NSString *)getAppVersion;

//获取当前所在国家/区域
+ (NSString *)getCurrentCountry;

//加密
+ (NSString *)getPassWordWithmd5:(NSString *)str;

//获取当前UTC时间
+ (NSString *)getcurrentOperationtime;
@end
