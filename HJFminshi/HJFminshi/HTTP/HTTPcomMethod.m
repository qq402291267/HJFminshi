//
//  HTTPcomMethod.m
//  HJFminshi
//
//  Created by 胡江峰 on 16/3/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "HTTPcomMethod.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HTTPcomMethod

//获取app名字
+ (NSString *)getAppName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

//获取app版本
+ (NSString *)getAppVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

//获取当前所在国家/区域
+ (NSString *)getCurrentCountry
{
    NSLocale *currentLocale = [NSLocale currentLocale];
    //    NSLog(@"Country Code is %@", [currentLocale objectForKey:NSLocaleCountryCode]);
    return  [currentLocale objectForKey:NSLocaleCountryCode];
}

+ (NSString *)getPassWordWithmd5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    NSString * string = [NSString stringWithFormat:
                         @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                         result[0], result[1], result[2], result[3],
                         result[4], result[5], result[6], result[7],
                         result[8], result[9], result[10], result[11],
                         result[12], result[13], result[14], result[15]
                         ];
    return [string uppercaseStringWithLocale:[NSLocale currentLocale]];
}

//获取当前UTC时间
+ (NSString *)getcurrentOperationtime
{
    NSString *timeSp = [NSString stringWithFormat:@"%f", (double)[[NSDate date] timeIntervalSince1970]*1000];
    NSArray *temp =   [timeSp componentsSeparatedByString:@"."];
    NSLog(@"timeSp = %@,Index[0] = %@",timeSp,[temp objectAtIndex:0]);
    NSString * lastOperationtime = [temp objectAtIndex:0];
    return lastOperationtime;
}

@end
