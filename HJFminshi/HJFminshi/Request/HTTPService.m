//
//  HTTPService.m
//  KeMan
//
//  Created by user on 14-8-4.
//
//

#import "HTTPService.h"
#import "AFNetworking.h"

NSString * const imageType = @"image/png";


@interface HTTPService ()
{
    dispatch_queue_t Queue;
    dispatch_group_t group;
}

@end

static HTTPService * singleInstance = nil;

@implementation HTTPService

+ (HTTPService *)shareHTTPService
{
    if (singleInstance == nil) {
        //
        singleInstance = [[HTTPService alloc] init];
    }
    return singleInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        //
        //定义线程队列和组
        Queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        group = dispatch_group_create();
    }
    return self;
}

/**
 *  用户登录
 *
 *  @param userName    用户名
 *  @param passWord    密码
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)loginServerWithUserName:(NSString *)userName passWord:(NSString *)passWord deviceToken:(NSString *)deviceToken success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    //开始登录服务器
    NSString * appName = [Util getAppName];
    NSString * appVersion = [Util getAppVersion];
    NSString * countrycode = [Util getCurrentCountry];
    NSString * pwdmd5 = [Util getPassWordWithmd5:passWord];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:userName forKey:KEY_username];
    [dict setObject:pwdmd5 forKey:KEY_password];
    [dict setObject:[NSString stringWithFormat:@"%d",2] forKey:KEY_appType];
    [dict setObject:appName forKey:KEY_appName];
    [dict setObject:appVersion forKey:KEY_appVersion];
    [dict setObject:countrycode forKey:KEY_country];
    [dict setValue:deviceToken forKey:KEY_deviceToken];
    NSLog(@"LoginURL = %@:dict = %@",LoginURL,dict);
    [self HttpPostToServerWith:LoginURL WithParameters:dict timeoutInterval:HTTPTimeout success:result errorresult:errorresult];
}

/**
 *  忘记密码
 *
 *  @param username    用户名
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)getPasswordServerWithusername:(NSString *)username success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:username forKey:KEY_username];
    NSLog(@"ForgetPwdURL = %@:dict = %@",ForgetPwdURL,dict);
    [self HttpPostToServerWith:ForgetPwdURL WithParameters:dict timeoutInterval:HTTPTimeout success:result errorresult:errorresult];
}

/**
 *  用户注册
 *
 *  @param username    用户名
 *  @param userpwd     密码
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)registWithuserName:(NSString *)username userPwd:(NSString *)userpwd success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSString * pwdmd5 = [Util getPassWordWithmd5:userpwd];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:username forKey:KEY_username];
    [dict setObject:pwdmd5 forKey:KEY_password];
    NSLog(@"SignUpURL = %@:dict = %@",SignUpURL,dict);
    [self HttpPostToServerWith:SignUpURL WithParameters:dict timeoutInterval:HTTPTimeout success:result errorresult:errorresult];
}

/**
 *  修改密码
 *
 *  @param username    用户名
 *  @param oldpwd      旧密码
 *  @param newpwd      新密码
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)modifyPwdWithusername:(NSString *)username oldpwd:(NSString *)oldpwd newpwd:(NSString *)newpwd success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSString * md5oldpwd = [Util getPassWordWithmd5:oldpwd];
    NSString * md5newpwd = [Util getPassWordWithmd5:newpwd];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:username forKey:KEY_username];
    [dict setObject:md5oldpwd forKey:KEY_old_password];
    [dict setObject:md5newpwd forKey:KEY_new_password];
    NSLog(@"ChangePwdURL = %@:dict = %@",ChangePwdURL,dict);
    [self HttpPostToServerWith:ChangePwdURL WithParameters:dict timeoutInterval:HTTPTimeout success:result errorresult:errorresult];
}

/**
 *  获取wifi设备列表
 *
 *  @param userName 用户名
 *  @param password 密码
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)getWifiListWithuserName:(NSString * )userName password:(NSString *)password success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSString * md5pwd = [Util getPassWordWithmd5:password];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:userName forKey:KEY_username];
    [dict setObject:md5pwd forKey:KEY_password];
    NSLog(@"GetwifiInfoURL = %@:dict = %@",GetwifiInfoURL,dict);
    [self HttpGetToServerWith:GetwifiInfoURL WithParameters:dict timeoutInterval:HTTPTimeout success:result errorresult:errorresult];
}

/**
 *  上传设备信息到服务器
 *
 *  @param userName 用户名
 *  @param password 密码
 *  @param deviceinfo 设备信息
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)UploadDeviceinfoToHttpServerWithuserName:(NSString * )userName password:(NSString *)password deviceInfo:(DeviceAllInfo *)deviceinfo success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSString * md5pwd = [Util getPassWordWithmd5:password];
    NSString * lastOperationtime = [Util getcurrentOperationtime];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:userName forKey:KEY_username];
    [dict setObject:md5pwd forKey:KEY_password];
    [dict setObject:deviceinfo.macstring forKey:KEY_macAddress];
    [dict setObject:deviceinfo.companyCode forKey:KEY_companyCode];
    [dict setObject:deviceinfo.deviceType forKey:KEY_deviceType];
    [dict setObject:deviceinfo.authCode forKey:KEY_authCode];
    [dict setObject:deviceinfo.devicename forKey:KEY_deviceName];
    [dict setObject:deviceinfo.logo forKey:KEY_imageName];
    [dict setObject:[NSNumber numberWithInt:deviceinfo.orderNumber] forKey:KEY_orderNumber];
    [dict setValue:lastOperationtime forKey:KEY_lastOperation];
    NSLog(@"EditWifiURL = %@:dict = %@",EditWifiURL,dict);
    [self HttpPostToServerWith:EditWifiURL WithParameters:dict timeoutInterval:HTTPTimeout success:result errorresult:errorresult];
}

/**
 *  删除wifi设备
 *
 *  @param userName    用户名
 *  @param password    密码
 *  @param macstring   设备mac信息
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)DeleteDeviceinfoToHttpServerWithuserName:(NSString * )userName password:(NSString *)password macstring:(NSString *)macstring success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSString * md5pwd = [Util getPassWordWithmd5:password];
    NSString * lastOperationtime = [Util getcurrentOperationtime];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:userName forKey:KEY_username];
    [dict setObject:md5pwd forKey:KEY_password];
    [dict setObject:macstring forKey:KEY_macAddress];
    [dict setValue:lastOperationtime forKey:KEY_lastOperation];
    NSLog(@"DeleteWifiURL = %@:dict = %@",DeleteWifiURL,dict);
    [self HttpPostToServerWith:DeleteWifiURL WithParameters:dict timeoutInterval:HTTPTimeout success:result errorresult:errorresult];
}

/**
 *  获取反馈列表
 *
 *  @param userName    用户名
 *  @param password    密码
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)getFeedbackListToHttpServerWithuserName:(NSString *)userName password:(NSString *)password success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSString * md5pwd = [Util getPassWordWithmd5:password];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:userName forKey:KEY_username];
    [dict setObject:md5pwd forKey:KEY_password];
    NSLog(@"GetFeedbackURL = %@:dict = %@",GetFeedbackURL,dict);
    [self HttpGetToServerWith:GetFeedbackURL WithParameters:dict timeoutInterval:HTTPTimeout success:result errorresult:errorresult];
}

/**
 *  删除反馈
 *
 *  @param userName    用户名
 *  @param password    密码
 *  @param feedbackID  反馈id
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)deleteFeedbackToHttpServerWithuserName:(NSString *)userName password:(NSString *)password feedbackID:(NSString *)feedbackID success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSString * md5pwd = [Util getPassWordWithmd5:password];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:userName forKey:KEY_username];
    [dict setObject:md5pwd forKey:KEY_password];
    [dict setObject:feedbackID forKey:KEY_feedbackID];
    NSLog(@"DeleteFeedbackURL = %@:dict = %@",DeleteFeedbackURL,dict);
    [self HttpPostToServerWith:DeleteFeedbackURL WithParameters:dict timeoutInterval:HTTPTimeout success:result errorresult:errorresult];
}

/**
 *  新增反馈
 *
 *  @param userName   用户名
 *  @param password   密码
 *  @param msgcontext 消息内容
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)AddFeedbackToHttpServerWithuserName:(NSString *)userName password:(NSString *)password msgcontext:(NSString *)msgcontext success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSString * md5pwd = [Util getPassWordWithmd5:password];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:userName forKey:KEY_username];
    [dict setObject:md5pwd forKey:KEY_password];
    [dict setObject:msgcontext forKey:KEY_content];
    NSLog(@"AddFeedbackURL = %@:dict = %@",AddFeedbackURL,dict);
    [self HttpPostToServerWith:AddFeedbackURL WithParameters:dict timeoutInterval:HTTPTimeout success:result errorresult:errorresult];
}

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
- (void)UploadImageToServerWithuserName:(NSString *)userName password:(NSString *)password imageName:(NSString *)name andImageFile:(UIImage *)image success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSString * md5pwd = [Util getPassWordWithmd5:password];
    NSData * imageData = UIImageJPEGRepresentation(image, 0.00001);
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:AccessKey forKey:KEY_Accesskey];
    [dict setObject:userName forKey:KEY_username];
    [dict setObject:md5pwd forKey:KEY_password];
    [dict setObject:name forKey:KEY_imageName];
    [dict setObject:imageData forKey:KEY_file];
    NSLog(@"UploadImageURL = %@:dict = %@",UploadImageURL,dict);
    [self HttpPostImageToServerWith:UploadImageURL WithParameters:dict imageName:name andImageFile:image success:result errorresult:errorresult];
}

/**
 *  下载图片
 *
 *  @param fileanme      图片名称
 *  @param saveDirectory 图片保存路径
 *  @param filepathblock 文件下载完成
 *  @param errorresult   返回错误信息
 */
- (void)downloadFileWithfilename:(NSString *)fileanme savefilepath:(NSString *)savefilepath filepathblock:(downBlock)filepathblock errorresult:(errorBlock)errorresult
{
    NSString * url = [NSString stringWithFormat:@"%@/%@",DownloadImageURL,fileanme];
    NSLog(@"downloadFileWithfilename:url = %@",url);
    __block BOOL isSuccess = NO;
    dispatch_group_async(group, Queue, ^{
        isSuccess = [self HttpdownFileWithurl:url savefilepath:savefilepath filepathblock:filepathblock errorresult:errorresult];
    });
    //队列任务执行完成
    dispatch_group_notify(group, Queue, ^{
        //
        if (isSuccess) {
            filepathblock(savefilepath);
        } else {
            NSError * error = [NSError errorWithDomain:@"downloadFileWithfilename" code:XDefultFailed userInfo:@{NSLocalizedDescriptionKey:savefilepath}];
            errorresult(error);
        }
    });
}

/**
 *  http get访问
 *
 *  @param url             访问地址
 *  @param dict            访问参数
 *  @param timeoutInterval 超时时间
 *  @param result          返回访问成功信息
 *  @param errorresult     返回错误信息
 */
- (void)HttpGetToServerWith:(NSString *)url WithParameters:(NSDictionary *)dict timeoutInterval:(NSTimeInterval)timeoutInterval success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = timeoutInterval;
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        result(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        errorresult(error);
        
    }];
}

/**
 *  http post访问
 *
 *  @param url             访问地址
 *  @param dict            访问参数
 *  @param timeoutInterval 超时时间
 *  @param result          返回访问成功信息
 *  @param errorresult     返回错误信息
 */
- (void)HttpPostToServerWith:(NSString *)url WithParameters:(NSDictionary *)dict timeoutInterval:(NSTimeInterval)timeoutInterval success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = timeoutInterval;
    
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        result(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        errorresult(error);
    
    }];
}

/**
 *  上传图片
 *
 *  @param url         上传url
 *  @param dict        访问参数
 *  @param name        图片名称
 *  @param image       图片数据
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)HttpPostImageToServerWith:(NSString *)url WithParameters:(NSDictionary *)dict imageName:(NSString *)name andImageFile:(UIImage *)image success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:KEY_file fileName:name mimeType:imageType];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        result(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        errorresult(error);
        
    }];
}

/**
 *  下载图片
 *
 *  @param url            url
 *  @param filepathblock  返回下载地址
 *  @param errorresult    返回错误信息
 */
- (BOOL)HttpdownFileWithurl:(NSString *)url savefilepath:(NSString *)savefilepath filepathblock:(downBlock)filepathblock errorresult:(errorBlock)errorresult
{
    NSString * resultDataString = nil;
    NSMutableURLRequest * url_request = [[NSMutableURLRequest alloc] init];
    [url_request setURL:[NSURL URLWithString:url]];
    [url_request setHTTPMethod:@"GET"];
    [url_request setTimeoutInterval:20];
    NSHTTPURLResponse * Response = nil;
    NSError * error = nil;
    NSData * resultData = [NSURLConnection sendSynchronousRequest:url_request returningResponse:&Response error:&error];
    NSInteger statuscode = Response.statusCode;
    if (statuscode == 200) {
        if (!error) {
            resultDataString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
            NSLog(@"resultDataString=%@",resultDataString);
            [resultData writeToFile:savefilepath atomically:YES];
            return YES;
            
        } else {
            NSLog(@"error=%@",error);
            return NO;
        }
        
    } else {
        return NO;
    }
}

//下载文件(暂未使用)
- (void)IOS7_downloadFileWith:(NSString *)url filepathblock:(downBlock)filepathblock errorresult:(errorBlock)errorresult
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //对urlString转成UTF8编码
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, NULL,  kCFStringEncodingUTF8));
    NSURL *URL = [NSURL URLWithString:encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask * downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
         
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        NSString * strfilepath = [NSString stringWithFormat:@"%@",filePath];
        NSLog(@">>>>>>>>completionHandler:strfilepath = %@",strfilepath);
        filepathblock(strfilepath);
        errorresult(error);
        
    }];
    [downloadTask resume];
}

/**
 *  上传文件(暂未使用)
 *
 *  @param url         上传url
 *  @param path        文件路径
 *  @param result      返回访问成功信息
 *  @param errorresult 返回错误信息
 */
- (void)uploadToServerWithurl:(NSString *)url filePath:(NSString *)path success:(succeeBlock)result errorresult:(errorBlock)errorresult
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURL *filePath = [NSURL fileURLWithPath:path];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            errorresult(error);
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            result(dic);
        }
    }];
    [uploadTask resume];
}

//Https网上代码
/*
第一步，导入AFNetWorking 库
第二步，在pch文件中加入
 
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES

第三步
- (void)inithttps
{
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    _manager.securityPolicy = securityPolicy;
}
*/
/*
 友情提示：本文使用的AFNetworking是最新git pull的2.3.1版本，如果想确认你机器上的AFNetworking版本，请打git tag命令查看。
 
 　　绝大部分iOS程序的后台服务都是基于RESTful或者WebService的，不论在任何时候，你都应该将服务置于HTTPS上，因为它可以避免中间人攻击的问题，还自带了基于非对称密钥的加密通道！现实是这些年涌现了大量速成的移动端开发人员，这些人往往基础很差，完全不了解加解密为何物，使用HTTPS后，可以省去教育他们各种加解密技术，生活轻松多了。
 
 　　使用HTTPS有个问题，就是CA证书。缺省情况下，iOS要求连接的HTTPS站点必须为CA签名过的合法证书，AFNetworking是个iOS上常用的HTTP访问库，由于它是基于iOS的HTTP网络通讯库，自然证书方面的要求和系统是一致的，也就是你需要有一张合法的站点证书。
 
 　　正式的CA证书非常昂贵，很多人都知道，AFNetworking2只要通过下面的代码，你就可以使用自签证书来访问HTTPS
 AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
 securityPolicy.allowInvalidCertificates = YES;
 
 　　这么做有个问题，就是你无法验证证书是否是你的服务器后端的证书，给中间人攻击，即通过重定向路由来分析伪造你的服务器端打开了大门。
 
 　　解决方法。AFNetworking2是允许内嵌证书的，通过内嵌证书，AFNetworking2就通过比对服务器端证书、内嵌的证书、站点域名是否一致来验证连接的服务器是否正确。由于CA证书验证是通过站点域名进行验证的，如果你的服务器后端有绑定的域名，这是最方便的。将你的服务器端证书，如果是pem格式的，用下面的命令转成cer格式

 openssl x509 -in <你的服务器证书>.pem -outform der -out server.cer
 
 然后将生成的server.cer文件，如果有自建ca，再加上ca的cer格式证书，引入到app的bundle里，AFNetworking2在
 AFSecurityPolicy *securityPolicy = [AFSecurityPolicy AFSSLPinningModeCertificate];
 或者
 AFSecurityPolicy *securityPolicy = [AFSecurityPolicy AFSSLPinningModePublicKey];
 securityPolicy.allowInvalidCertificates = YES; //还是必须设成YES
 情况下，会自动扫描bundle中.cer的文件，并引入，这样就可以通过自签证书来验证服务器唯一性了。
 　　我前面说过，验证站点证书，是通过域名的，如果服务器端站点没有绑定域名（万恶的备案），仅靠IP地址上面的方法是绝对不行的。怎么办？答案是想通过设置是不可以的，你只能修改AFNetworking的源代码！打开AFSecurityPolicy.m文件，找到方法:
 - (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
 forDomain:(NSString *)domain
 将下面这部分注释掉
 //            SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);
 //
 //            if (!AFServerTrustIsValid(serverTrust)) {
 //                return NO;
 //            }
 //
 //            if (!self.validatesCertificateChain) {
 //                return YES;
 //            }
 这样，AFSecurityPolicy就只会比对服务器证书和内嵌证书是否一致，不会再验证证书是否和站点域名一致了。
 
 　　这么做为什么是安全的？了解HTTPS的人都知道，整个验证体系中，最核心的实际上是服务器的私钥。私钥永远，永远也不会离开服务器，或者以任何形式向外传输。私钥和公钥是配对的，如果事先在客户端预留了公钥，只要服务器端的公钥和预留的公钥一致，实际上就已经可以排除中间人攻击了。
 */

@end
