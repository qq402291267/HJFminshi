//
//  HTTPService.h
//  KeMan
//
//  Created by user on 14-8-4.
//
//

#import <Foundation/Foundation.h>

#define HTTPServiceInstance [HTTPService shareHTTPService]

typedef void (^succeeBlock) (NSDictionary *dic);
typedef void (^errorBlock) (NSError *error);
typedef void (^downBlock) (NSString *filePath);

extern NSString * const imageType;

@interface HTTPService : NSObject

+ (HTTPService *)shareHTTPService;

/**
 *  用户登录
 *
 *  @param userName    用户名
 *  @param passWord    密码
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)loginServerWithUserName:(NSString *)userName passWord:(NSString *)passWord deviceToken:(NSString *)deviceToken success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  忘记密码
 *
 *  @param username    用户名
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)getPasswordServerWithusername:(NSString *)username success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  用户注册
 *
 *  @param username    用户名
 *  @param userpwd     密码
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)registWithuserName:(NSString *)username userPwd:(NSString *)userpwd success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  修改密码
 *
 *  @param username    用户名
 *  @param oldpwd      旧密码
 *  @param newpwd      新密码
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)modifyPwdWithusername:(NSString *)username oldpwd:(NSString *)oldpwd newpwd:(NSString *)newpwd success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  获取wifi设备列表
 *
 *  @param userName 用户名
 *  @param password 密码
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)getWifiListWithuserName:(NSString * )userName password:(NSString *)password success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  上传设备信息到服务器
 *
 *  @param userName 用户名
 *  @param password 密码
 *  @param deviceinfo 设备信息
 */
- (void)UploadDeviceinfoToHttpServerWithuserName:(NSString * )userName password:(NSString *)password deviceInfo:(DeviceAllInfo *)deviceinfo success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  删除wifi设备
 *
 *  @param userName    用户名
 *  @param password    密码
 *  @param macstring   设备mac信息
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)DeleteDeviceinfoToHttpServerWithuserName:(NSString * )userName password:(NSString *)password macstring:(NSString *)macstring success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  获取反馈列表
 *
 *  @param userName    用户名
 *  @param password    密码
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)getFeedbackListToHttpServerWithuserName:(NSString *)userName password:(NSString *)password success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  删除反馈
 *
 *  @param userName    用户名
 *  @param password    密码
 *  @param feedbackID  反馈id
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)deleteFeedbackToHttpServerWithuserName:(NSString *)userName password:(NSString *)password feedbackID:(NSString *)feedbackID success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  新增反馈
 *
 *  @param userName   用户名
 *  @param password   密码
 *  @param msgcontext 消息内容
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)AddFeedbackToHttpServerWithuserName:(NSString *)userName password:(NSString *)password msgcontext:(NSString *)msgcontext success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  图片文件上传
 *
 *  @param userName    用户名
 *  @param password    密码
 *  @param name        图片名称
 *  @param image       图片UIImage
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)UploadImageToServerWithuserName:(NSString *)userName password:(NSString *)password imageName:(NSString *)name andImageFile:(UIImage *)image success:(succeeBlock)result errorresult:(errorBlock)errorresult;

/**
 *  下载图片
 *
 *  @param fileanme      图片名称
 *  @param saveDirectory 图片保存路径
 *  @param filepathblock 文件下载完成
 *  @param errorresult   返回错误信息
 */
- (void)downloadFileWithfilename:(NSString *)fileanme savefilepath:(NSString *)savefilepath filepathblock:(downBlock)filepathblock errorresult:(errorBlock)errorresult;

@end
