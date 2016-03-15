//
//  OperatorResult.h
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OperatorResult : NSObject
//返回的NSData数据
@property (nonatomic,strong) NSData * responsedata;
//解析得到字典数据
@property (nonatomic,strong) NSDictionary * responsedictionary;

+ (OperatorResult *)ResultWithdata:(NSData *)responsedata dictionary:(NSDictionary *)responsedictionary;
- (id)initWithdata:(NSData *)responsedata dictionary:(NSDictionary *)responsedictionary;
@end
