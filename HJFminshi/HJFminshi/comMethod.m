//
//  comMethod.m
//  HJFminshi
//
//  Created by 胡江峰 on 16/3/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "comMethod.h"
#import "Crypt.h"
@implementation comMethod

+ (UInt16)uint16FromNetData:(NSData *)data
{
    return ntohs(*((UInt16 *)[data bytes]));
}

+ (NSString *)convertDataToip:(NSData *)data
{
    NSMutableString * temphost = [[NSMutableString alloc] init];
    for (int i = 0; i < [data length]; i++) {
        UInt8 no = ((UInt8*)[data bytes])[i];
        [temphost appendFormat:@"%d.",no];
    }
    NSString * host = [temphost substringWithRange:NSMakeRange(0, temphost.length-1)];
    return host;
}

+ (NSString *)convertDataTomacstring:(NSData *)data
{
    NSString * macstring = [[Crypt hexEncode:data] uppercaseStringWithLocale:[NSLocale currentLocale]];
    //    NSLog(@"convertDataTomac:mac = %@,macstring = %@",data,macstring);
    return macstring;
}

//string转data
+ (NSData *)convertmacstringToData:(NSString *)macstring
{
    NSData * macdata = [Crypt decodeHex:macstring];
    //    NSLog(@"convertmacstringToData:macstring = %@,macdata = %@",macstring,macdata);
    return macdata;
}




//得到文本输入左侧空视图
+ (UIView *)gettextRectLeftView{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    return paddingView;
}

//获取宽度和高度

+ (CGSize) titleSizeWithTitle:(NSString *)title size:(CGFloat)size;{
    return [self titleSizeWithTitle:title size:size MaxW:MAXFLOAT];
}

+ (CGSize) titleSizeWithTitle:(NSString *)title size:(CGFloat)size MaxW:(CGFloat)MaxW{
    NSDictionary *dict = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:size]
                           };
    CGSize maxSize = CGSizeMake(MaxW, MAXFLOAT);
    return [title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
}


//判断userName和userPassword是否合法
+(BOOL)JudgeUserName:(NSString *)userName userPassword:(NSString *)userPassword{
    return !( userName == nil || [userName isEqualToString:@""] || [userName isEqual:[NSNull null]] || userPassword == nil || [userPassword isEqualToString:@""] || [userPassword isEqual:[NSNull null]]);
}

//警告框
+ (UIAlertView *)showAlertWithTitle:(NSString *)title msg:(NSString *)msg
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    return alert;
}

+ (void)RGBtoHSVr:(float)r g:(float)g b:(float)b h:(float *)h s:(float *)s v:(float *)v
{
    float min, max, delta;
    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    *v = max;               // v
    delta = max - min;
    if( max != 0 )
        *s = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        *h = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta; // between magenta & cyan
    *h *= 60;               // degrees
    if( *h < 0 )
        *h += 360;
}

+ (void)HSVtoRGBh:(float)h s:(float)s v:(float)v r:(float *)r g:(float*)g b:(float *)b
{
    int i;
    float f, p, q, t;
    if( s == 0 ) {
        // achromatic (grey)
        *r = *g = *b = v;
        return;
    }
    h /= 60;            // sector 0 to 5
    i = floor( h );
    f = h - i;          // factorial part of h
    p = v * ( 1 - s );
    q = v * ( 1 - s * f );
    t = v * ( 1 - s * ( 1 - f ) );
    switch( i ) {
        case 0:
            *r = v;
            *g = t;
            *b = p;
            break;
        case 1:
            *r = q;
            *g = v;
            *b = p;
            break;
        case 2:
            *r = p;
            *g = v;
            *b = t;
            break;
        case 3:
            *r = p;
            *g = q;
            *b = v;
            break;
        case 4:
            *r = t;
            *g = p;
            *b = v;
            break;
        default:        // case 5:
            *r = v;
            *g = p;
            *b = q;
            break;
    }
}













@end
