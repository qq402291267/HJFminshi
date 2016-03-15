//
//  OperatorResult.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/8.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "OperatorResult.h"

@implementation OperatorResult


+ (OperatorResult *)ResultWithdata:(NSData *)responsedata dictionary:(NSDictionary *)responsedictionary
{
    OperatorResult * result = [[OperatorResult alloc] initWithdata:responsedata dictionary:responsedictionary];
    return result;
}

- (id)initWithdata:(NSData *)responsedata dictionary:(NSDictionary *)responsedictionary
{
    if (self = [super init]) {
        _responsedata = responsedata;
        _responsedictionary = responsedictionary;
    }
    return self;
}

- (NSString *)description
{
    NSString * result = [NSString stringWithFormat:@"_responsedata = %@,_responsedictionary = %@",_responsedata,_responsedictionary];
    return result;
}


@end
