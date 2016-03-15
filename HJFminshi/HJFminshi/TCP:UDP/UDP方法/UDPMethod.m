//
//  UDP_method.m
//  Minshi
//
//  Created by 胡江峰 on 16/1/28.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "UDPMethod.h"
#import "LocalService.h"
#import "UDP_ResponseAnalysis.h"
#import "HTTPService.h"

@interface UDPMethod()

@end

static UDPMethod * signleInstance = nil;

@implementation UDPMethod


+ (UDPMethod *)shareUDPMethod
{
    if (signleInstance == nil) {
        signleInstance = [[UDPMethod alloc] init];
        
    }
    return signleInstance;
}

-(void)udpBindConnect{
    [LocalServiceInstance udpBindConnect];
}

-(void)JugeAllDeviceudpOnline{
    [LocalServiceInstance JugeAllDeviceudpOnline];
}


//---------------------------------------------------
//根据设备mac获取设备状态，具体功能需要自己写
-(void)getDeviceStatusWithDeviceInfo:(DevicePreF *)deviceinfo{
    NSData *data = deviceinfo.macdata;
    dispatch_async(dispatch_get_main_queue(), ^{
        //发送获取设备状态信息通知
        [[NSNotificationCenter defaultCenter] postNotificationName:GetDeviceStatus_Notification object:@{Mac_Key_data:data}];
    });

}

//找到设备，根据设备添加视图，具体功能需要自己写
- (void)AddViewToScrollViewWithDeviceInfo:(DevicePreF *)deviceinfo{
    HJFLog(@"找到新的设备了。-----------------");
    //跳转到主线程中发送通知
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AddDeviceViewToArray_Notification object:nil];
    });

}

//根据设备查询设备是否在线，具体功能需要自己写
- (void)TcponlineDataWithDeviceInfo:(DevicePreF *)deviceinfo{
    NSData *data = deviceinfo.macdata;
    [[NSNotificationCenter defaultCenter] postNotificationName:TcpIsonline_Notification object:@{Mac_Key_data:data}];
}

//根据设备设置在线订阅，具体功能需要自己写
- (void)TcpsubscribetoeventWithDeviceInfo:(DevicePreF *)deviceinfo{
}

//上传设备数据，具体功能需要自己写
- (void)UploadDeviceinfoToHttpServerWithDeviceInfo:(DevicePreF*)deviceinfo{
    NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERNAME];
    NSString * userpassword = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERPASSWORD];
    [HTTPServiceInstance UploadDeviceinfoToHttpServerWithuserName:username password:userpassword deviceInfo:deviceinfo success:^(NSDictionary *dic) {
        
        BOOL issuccessful = [[dic objectForKey:KEY_success] boolValue];
        NSString * failmsg = [dic objectForKey:KEY_msg];
        NSLog(@"issuccessful = %d,failmsg = %@",issuccessful,failmsg);
        
    } errorresult:^(NSError *error) {
        
        NSLog(@"UploadDeviceinfoToHttpServerWithdeviceInfo:error = %@",[error localizedDescription]);
        
    }];

}

-(void)UpdateStatusWithDeviceInfo:(DevicePreF *)deviceinfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateStatus_Notification object:@{Mac_Key_data:deviceinfo.macdata}];
    });

}



@end
