//
//  ResponseAnalysis.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#define TCP_ResponseAnalysisInstance [TCP_ResponseAnalysis shareTCP_ResponseAnalysis]

@protocol TCP_ResponseAnalysisDelegate <NSObject>
@required
//http打印信息
-(void)TCP_ResponseAnalysisNSLogString:(NSString*)str;
@end


@interface TCP_ResponseAnalysis : NSObject

// 分析外网数据
- (NSDictionary *)analysisServerResponse:(NSData *)response;

//  得到返回操作序号
- (UInt16)indexFromResponse:(NSData *)response;

//  得到发送命令
- (UInt8)getProtcolCmd:(NSData *)response;

+ (TCP_ResponseAnalysis * )shareTCP_ResponseAnalysis;


@property (nonatomic,weak) id<TCP_ResponseAnalysisDelegate> TCP_ResponseAnalysisDelegate;
@end
