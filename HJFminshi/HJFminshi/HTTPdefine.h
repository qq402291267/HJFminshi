//
//  HTTPdefine.h
//  HJFminshi
//
//  Created by 胡江峰 on 16/3/7.
//  Copyright © 2016年 胡江峰. All rights reserved.


//定义http 需要的头文件

#ifndef HTTPdefine_h
#define HTTPdefine_h

#define HTTPTimeout         20

/*HTTP*/

//用户是否开启接收消息,默认开启
#define KEY_IsRecvMsg_B                             @"KEY_IsRecvMsg"
//用户头像
#define KEY_headImagePath                           @"headImagePath"


#define KEY_deviceToken                     @"token"
#define KEY_Accesskey                       @"accessKey"
#define KEY_username                        @"username"
#define KEY_password                        @"password"
#define KEY_appType                         @"appType"
#define KEY_appName                         @"appName"
#define KEY_appVersion                      @"appVersion"
#define KEY_country                         @"country"
#define KEY_old_password                    @"old_password"
#define KEY_new_password                    @"new_password"
#define KEY_file                            @"file"


#define KEY_success                         @"success"
#define KEY_msg                             @"msg"
#define KEY_list                            @"list"
#define KEY_macAddress                      @"macAddress"
#define KEY_companyCode                     @"companyCode"
#define KEY_deviceType                      @"deviceType"
#define KEY_authCode                        @"authCode"
#define KEY_deviceName                      @"deviceName"
#define KEY_imageName                       @"imageName"
#define KEY_orderNumber                     @"orderNumber"
#define KEY_lastOperation                   @"lastOperation"

//反馈
#define KEY_feedbackID                      @"id"
#define KEY_content                         @"content"
#define KEY_reply                           @"reply"
#define KEY_feedbackTime                    @"feedbackTime"
#define KEY_replyTime                       @"replyTime"

#define AccessKey @"abcdefg0123456789"      //AccessKey
#define URLHead  @"https://minshi-test.yunext.com"
//#define URLHead  @"https://minshi-test2.yunext.com"
//登录
#define LoginURL [NSString stringWithFormat:@"%@%@",URLHead,@"/api/account/login"]

//忘记密码
#define ForgetPwdURL [NSString stringWithFormat:@"%@%@",URLHead,@"/api/account/password/forget"]
//注册
#define SignUpURL [NSString stringWithFormat:@"%@%@",URLHead,@"/api/account/signup"]

//修改密码
#define ChangePwdURL [NSString stringWithFormat:@"%@%@",URLHead,@"/api/account/password/change"]

//获取wifi列表
#define GetwifiInfoURL [NSString stringWithFormat:@"%@%@",URLHead,@"/api/device/list"]

//编辑WiFi设备
#define EditWifiURL [NSString stringWithFormat:@"%@%@",URLHead,@"/api/device/edit"]

//删除WiFi设备
#define DeleteWifiURL [NSString stringWithFormat:@"%@%@",URLHead,@"/api/device/delete"]

//获取反馈列表
#define GetFeedbackURL [NSString stringWithFormat:@"%@%@",URLHead,@"/api/feedback/list"]

//删除反馈
#define DeleteFeedbackURL [NSString stringWithFormat:@"%@%@",URLHead,@"/api/feedback/delete"]

//新增反馈
#define AddFeedbackURL [NSString stringWithFormat:@"%@%@",URLHead,@"/api/feedback/add"]

//上传图片
//HTTPS://xxx.com/image/upload
#define UploadImageURL [NSString stringWithFormat:@"%@%@",URLHead,@"/image/upload"]

//下载图片
//HTTPS://xxx.com/UploadedFile/{imageName}
#define DownloadImageURL [NSString stringWithFormat:@"%@%@",URLHead,@"/UploadedFile"]


#endif /* HTTPdefine_h */
