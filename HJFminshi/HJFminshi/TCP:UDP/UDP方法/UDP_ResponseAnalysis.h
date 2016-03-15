//
//  UDP_ResponseAnalysis.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/9.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#define UDP_ResponseAnalysisInstance [UDP_ResponseAnalysis shareUDP_ResponseAnalysis]

@interface UDP_ResponseAnalysis : NSObject
//  分析局域网数据
- (NSDictionary *)analysisLocalResponse:(NSData *)response;

//  得到返回操作序号
- (UInt16)indexFromResponse:(NSData *)response;

//命令号
- (UInt8)getProtcolCmd:(NSData *)response;

//  得到信息中mac
- (NSData *)getProtcolmac:(NSData *)response;

+ (UDP_ResponseAnalysis * )shareUDP_ResponseAnalysis;

@end
