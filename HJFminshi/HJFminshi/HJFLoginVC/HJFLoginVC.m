//
//  HJFLoginVC.m
//  HJFminshi
//
//  Created by 胡江峰 on 16/3/7.
//  Copyright © 2016年 胡江峰. All rights reserved.
//dfgdfg

#import "HJFLoginVC.h"
#import "comMethod.h"
#import "HTTPService.h"
#import "RemoteService.h"
#import "UDPMethod.h"
#import "MBProgressHUD+NJ.h"
//登入界面下滑高度
#define loginViewScrollViewContentSize              548

@interface HJFLoginVC ()<UIScrollViewDelegate,UITextFieldDelegate>
@property (nonatomic,strong) UIScrollView * scrollView;
@property (nonatomic,strong) UIImageView * backgroundImage;
@property (nonatomic,strong) UITextField * userTextField;
@property (nonatomic,strong) UITextField * passTextField;
@property (nonatomic,strong) NSString * userName;
@property (nonatomic,strong) NSString * userPassWord;
@property (nonatomic,assign) CGFloat scrollMove;
@property (nonatomic,assign) BOOL isShowKeyBroad;
@end

@implementation HJFLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addlayoutUI];
    [self addGesture];
    ////    调试专用
    _userTextField.text =@"111111@qq.com";
    _passTextField.text = @"123456";
}

- (void)addlayoutUI{
    //隐藏navigationBar
    self.navigationController.navigationBarHidden = YES;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, kScreen_Width, kScreen_Height)];
//    if (iOS7) {
//        //需要去掉状态栏
//        _scrollView.frame = CGRectMake(0, 20, kScreen_Width, kScreen_Height);
//    }
    _scrollView.contentSize = CGSizeMake(kScreen_Width, loginViewScrollViewContentSize);
    _scrollView.scrollEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    //加载背景图片
    _backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.contentSize.height)];
    
    [_backgroundImage setImage:[UIImage imageNamed:@"login_back.jpg"]];
    [_scrollView addSubview:_backgroundImage];
    
    //加载logo
    UIImageView * logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 160, 120, 44)];
    logoImage.center = CGPointMake(_scrollView.center.x, logoImage.center.y);
    [logoImage setImage:[UIImage imageNamed:@"login_logo"]];
    [_scrollView addSubview:logoImage];
    
    //用户名输入框
    UIFont * inputfont = [UIFont systemFontOfSize:16];
    
    _userTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoImage.frame) + 60, 250, 30)];
    _userTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _userTextField.autocapitalizationType =UITextAutocapitalizationTypeNone;
    
    _userTextField.placeholder = NSLocalizedString(@"login_email", @"邮箱");
    _userTextField.textAlignment = NSTextAlignmentLeft;
    _userTextField.returnKeyType = UIReturnKeyNext;
    _userTextField.delegate = self;
    _userTextField.center = CGPointMake(_scrollView.center.x, _userTextField.center.y);
    _userTextField.font = inputfont;
    _userTextField.textColor = RGBA(0x55, 0x55, 0x55, 1);
    [_userTextField setBackground:[UIImage imageNamed:@"input_normal"]];
    //设置TextField左侧空视图,右移输入
    _userTextField.leftView = [comMethod gettextRectLeftView];
    _userTextField.leftViewMode = UITextFieldViewModeAlways;
    _userTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _userTextField.borderStyle = UITextBorderStyleNone;
    //
    
    [self.scrollView addSubview:_userTextField];
    //passText
    
    _passTextField = [[UITextField alloc] initWithFrame:CGRectMake(_userTextField.frame.origin.x, CGRectGetMaxY(_userTextField.frame) + 44, _userTextField.frame.size.width, _userTextField.frame.size.height)];
    
    _passTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _passTextField.placeholder = NSLocalizedString(@"login_password", @"密码");
    _passTextField.textAlignment = NSTextAlignmentLeft;
    _passTextField.returnKeyType = UIReturnKeyDone;
    _passTextField.secureTextEntry = YES;
    _passTextField.delegate = self;
    _passTextField.font = inputfont;
    _passTextField.textColor = RGBA(0x55, 0x55, 0x55, 1);
    [_passTextField setBackground:[UIImage imageNamed:@"input_normal"]];
    //设置TextField左侧空视图,右移输入
    _passTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passTextField.borderStyle = UITextBorderStyleNone;
    _passTextField.leftView = [comMethod gettextRectLeftView];
    _passTextField.leftViewMode = UITextFieldViewModeAlways;
    //
    [self.scrollView addSubview:_passTextField];
    
    //忘记密码
    //点击这里按钮大小
    UIFont * font = [UIFont systemFontOfSize:14];
    NSString * strclickhere = NSLocalizedString(@"login_clickhere",@"点击这里");
    CGSize tempSize =[comMethod titleSizeWithTitle:strclickhere size:14];
    CGFloat forgetBtn_x = CGRectGetMaxX(_passTextField.frame) - tempSize.width;
    CGFloat forgetBtn_y = CGRectGetMaxY(_passTextField.frame) + 16;
    CGFloat forgetBtn_width = tempSize.width;
    CGFloat forgetBtn_height = tempSize.height;
    UIButton * forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetBtn.frame = CGRectMake(forgetBtn_x, forgetBtn_y, forgetBtn_width, forgetBtn_height);
    [forgetBtn setTitle:strclickhere forState:UIControlStateNormal];
    forgetBtn.titleLabel.font = font;
    [forgetBtn setTitleColor:RGBA(0xc8, 0xa0, 0x63, 1) forState:UIControlStateNormal];
    [forgetBtn setTitleColor:RGBA(0xbe, 0x98, 0x5e, 1) forState:UIControlStateHighlighted];
    [forgetBtn addTarget:self action:@selector(forgetpwdClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:forgetBtn];
    
    UIImageView * forget_line = [[UIImageView alloc] initWithFrame:CGRectMake(forgetBtn.frame.origin.x, CGRectGetMaxY(forgetBtn.frame), forgetBtn.frame.size.width, 1)];
    [forget_line setImage:[UIImage imageNamed:@"yellow_line"]];
    [self.scrollView addSubview:forget_line];
    
    //忘记密码提示
    NSString * strforgetpwd = NSLocalizedString(@"login_forgetpassword", @"忘记密码?");
    CGSize forgetpwdSize = [comMethod titleSizeWithTitle:strforgetpwd size:14];
    UILabel * forgetLabel = [[UILabel alloc] init];
    CGFloat forgetLabel_x = CGRectGetMinX(forgetBtn.frame) - forgetpwdSize.width;
    CGFloat forgetLabel_y = forgetBtn.frame.origin.y;
    CGFloat forgetLable_width = forgetpwdSize.width;
    CGFloat forgetLabel_height = forgetpwdSize.height;
    forgetLabel.frame = CGRectMake(forgetLabel_x, forgetLabel_y, forgetLable_width, forgetLabel_height);
    [forgetLabel setFont:font];
    [forgetLabel setTextColor:RGBA(0x99, 0x99, 0x99, 1)];
    forgetLabel.backgroundColor = [UIColor clearColor];
    forgetLabel.text = strforgetpwd;
    [self.scrollView addSubview:forgetLabel];
    
    //登录按钮
    UIButton * loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(0, CGRectGetMaxY(forgetLabel.frame) + 32, 250, 40);
    loginBtn.center = CGPointMake(_scrollView.center.x,loginBtn.center.y);
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"login_button_normal.png"] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"login_button_click.png"] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.titleLabel.font =inputfont;
    [loginBtn setTitle:NSLocalizedString(@"login_login", @"登录") forState:UIControlStateNormal];
    [loginBtn setTitleColor:RGBA(0x55, 0x55, 0x55, 1) forState:UIControlStateNormal];
    [self.scrollView addSubview:loginBtn];
    
    //没有账号,注册
    NSString * strsignin = NSLocalizedString(@"login_register", @"注册");
    
    CGSize signinSize = [comMethod titleSizeWithTitle:strsignin size:14];
    UIButton * signinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat signinBtn_x = CGRectGetMaxX(_passTextField.frame) - signinSize.width;
    CGFloat signinBtn_y = CGRectGetMaxY(loginBtn.frame) + 40;
    //kScreen_Height - 16 - 20 - signinSize.height
    CGFloat signinBtn_width = signinSize.width;
    CGFloat signinBtn_height = signinSize.height;
    signinBtn.frame = CGRectMake(signinBtn_x, signinBtn_y, signinBtn_width, signinBtn_height);
    [signinBtn setTitle:strsignin forState:UIControlStateNormal];
    [signinBtn setTitleColor:RGBA(0xc8, 0xa0, 0x63, 1) forState:UIControlStateNormal];
    [signinBtn setTitleColor:RGBA(0xbe, 0x98, 0x5e, 1) forState:UIControlStateHighlighted];
    signinBtn.titleLabel.font = font;
    [signinBtn addTarget:self action:@selector(signinClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:signinBtn];
    
    UIImageView * signin_line = [[UIImageView alloc] initWithFrame:CGRectMake(signinBtn.frame.origin.x, CGRectGetMaxY(signinBtn.frame), signinBtn.frame.size.width, 1)];
    [signin_line setImage:[UIImage imageNamed:@"yellow_line"]];
    [self.scrollView addSubview:signin_line];
    
    //没有账号
    NSString * strnoaccount = NSLocalizedString(@"login_noaccount", @"没有账号?");
    CGSize noaccountSize = [comMethod titleSizeWithTitle:strnoaccount size:14];
    CGFloat noaccountlabel_x = CGRectGetMinX(signinBtn.frame) - noaccountSize.width;
    CGFloat noaccountlabel_y = signinBtn.frame.origin.y;
    CGFloat noaccountlabel_width = noaccountSize.width;
    CGFloat noaccountlabel_height = noaccountSize.height;
    UILabel * noaccountlabel = [[UILabel alloc] init];
    noaccountlabel.frame = CGRectMake(noaccountlabel_x, noaccountlabel_y, noaccountlabel_width, noaccountlabel_height);
    [noaccountlabel setFont:font];
    [noaccountlabel setText:strnoaccount];
    [noaccountlabel setTextColor:RGBA(0x99, 0x99, 0x99, 1)];
    noaccountlabel.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:noaccountlabel];
    
}

-(void)loginClick{
    _userName = _userTextField.text;
    _userPassWord = _passTextField.text;
    if ([comMethod JudgeUserName:_userName userPassword:_userPassWord]) {
        if (!IS_AVAILABLE_EMAIL(_userName)) {
            [comMethod showAlertWithTitle:nil msg:@"请输入正确的邮箱"];
            return;
        }
        if (_userPassWord.length<6) {
            [comMethod showAlertWithTitle:nil msg:@"密码不能小于6位"];
            return;
        }
        [self loginServerWithUserName:_userName passWord:_userPassWord];
    }
    else{
        [comMethod showAlertWithTitle:nil msg:@"账户或密码不能为空"];
    }
}


//登录
- (void)loginServerWithUserName:(NSString *)userName passWord:(NSString *)passWord
{
    [MBProgressHUD showMessage:@"正在登录"];
    NSString * deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_deviceToken];
    BOOL isRecvMsg = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_IsRecvMsg_B] boolValue];
    if (!isRecvMsg) {
        deviceToken = nil;
    }
//        __weak loginViewController * _loginvc = self;
    [HTTPServiceInstance loginServerWithUserName:userName passWord:passWord deviceToken:deviceToken success:^(NSDictionary *dic) {
        NSString * successValue = [dic objectForKey:KEY_success];
        NSString * failedMsg = [dic objectForKey:KEY_msg];
        BOOL successboolValue = [successValue boolValue];
        
         HJFHTTPLog(@"%@",[NSString stringWithFormat:@"http登录：successValue = %@，failedMsg＝%@",successValue,failedMsg]);
        
        if (successboolValue) {
            [[NSUserDefaults standardUserDefaults] setObject:userName forKey:KEY_StoreageUSERNAME];
            [[NSUserDefaults standardUserDefaults] setObject:passWord forKey:KEY_StoreageUSERPASSWORD];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //            获取wifi设备列表
            [self getWifiListWithuserName:userName password:passWord];

            
        }
        else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"登录失败,请确认邮箱和密码"];
        }
        
    } errorresult:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"登录失败,请检查网络设置"];
    }];
}

//获取wifi设备列表
- (void)getWifiListWithuserName:(NSString * )userName password:(NSString *)password
{
    [HTTPServiceInstance getWifiListWithuserName:userName password:password success:^(NSDictionary *dic) {
        BOOL issuccessful = [[dic objectForKey:KEY_success] boolValue];
        NSString * failmsg = [dic objectForKey:KEY_msg];
        NSArray * devicelist = [dic objectForKey:KEY_list];
        HJFHTTPLog(@"%@",[NSString stringWithFormat:@"getWifiList结果： issuccessful = %d,failmsg = %@,devicelist = %@",issuccessful,failmsg,devicelist]);

        if (issuccessful) {
            //deviceinfo
            for (NSDictionary * devicedict in devicelist)
            {
                NSString * macAddress = [devicedict objectForKey:KEY_macAddress];
                NSString * companyCode = [devicedict objectForKey:KEY_companyCode];
                NSString * deviceType = [devicedict objectForKey:KEY_deviceType];
                NSString * authCode = [devicedict objectForKey:KEY_authCode];
                NSString * deviceName = [devicedict objectForKey:KEY_deviceName];
                NSString * imageName = [devicedict objectForKey:KEY_imageName];
                int orderNumber = [[devicedict objectForKey:KEY_orderNumber] intValue];
                //得到用户名
                NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_StoreageUSERNAME];
                //判断设备在数据库中是否存在,不存在添加到数据库
                DevicePreF * deviceAllinfo = [DeviceDataManagerInstance getdeviceInfo:macAddress username:userName];
                if (deviceAllinfo == nil) {
                    //添加设备到数据库
                    deviceAllinfo = [[DevicePreF alloc] init];
                    deviceAllinfo.macAddress = macAddress;
                    deviceAllinfo.companyCode = companyCode;
                    deviceAllinfo.deviceType = deviceType;
                    deviceAllinfo.authCode = authCode;
                    deviceAllinfo.deviceName = deviceName;
                    deviceAllinfo.imageName = imageName;
                    deviceAllinfo.orderNumber = orderNumber;
                    deviceAllinfo.username = username;
                    [DeviceDataManagerInstance insertIntoDataBase:deviceAllinfo];
                    deviceAllinfo.DB_id = [DeviceDataManagerInstance getDetailRowDB_idWithmac:deviceAllinfo.macAddress username:username];
                    
                    //end
                }
                deviceAllinfo.deviceName = deviceName;
                //判断单例中是否存在此设备
                BOOL isExistsInAllInfo = [DeviceManageInstance IsExistsWithmacstr:deviceAllinfo.macAddress];
                if (!isExistsInAllInfo) {
                    //添加到设备单例
                    [DeviceManageInstance.device_array addObject:deviceAllinfo];
                    
                }
                //转化数据
                [DeviceManageInstance convertDeviceinfo:deviceAllinfo];
                
                //end
            }
//          开始建立Tcp长连接(需得到用户名和密码后才能建立TCP长连接)
            [RemoteServiceInstance JudgeConnect];
            //UDP绑定
            [UDPMethodInstance udpBindConnect];

            
            //发送局域网发现设备命令,判断设备单例中所有设备,udp是否在线
            [UDPMethodInstance JugeAllDeviceudpOnline];
//            HJFmainviewController *vc = [[HJFmainviewController alloc] init];
//            [comMethod getAppDelegate].window.rootViewController =vc;
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"登录成功"];
//
            
        }
        else {
            //            NSLog(@"getWifiListWithuserName:failmsg = %@",failmsg);
            //            [MMProgressHUD dismissWithError:NSLocalizedString(@"login_getaccountfailed", @"获取账号信息失败")];
        }
        
    }errorresult:^(NSError *error) {
        //        //
        //        NSLog(@"getWifiListWithuserName:error = %@",[error localizedDescription]);
        //        [MMProgressHUD dismissWithError:NSLocalizedString(@"login_getaccountfailed", @"获取账号信息失败")];
    }];
}

-(void)addGesture{
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [_scrollView addGestureRecognizer:tap];
}

-(void)tap{
    [self endEditing];
}

-(void)endEditing{
    [self.view endEditing:YES];
    if (kScreen_Height+_scrollMove>loginViewScrollViewContentSize) {
        [UIView animateWithDuration:0.5 animations:^{
            _scrollMove = loginViewScrollViewContentSize-kScreen_Height;
            _scrollView.contentOffset= CGPointMake(0, _scrollMove);
        }];
    }
}

//开始编辑
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [textField setBackground:[UIImage imageNamed:@"input_current"]];
    [UIView animateWithDuration:0.5 animations:^{
        if (textField == _userTextField) {
            _scrollMove=[self scrollViewMoveWhenKeyBoardOutBasedontextFieldHeigh:CGRectGetMaxY(_userTextField.frame)];
            _scrollView.contentOffset = CGPointMake(0, _scrollMove);
            
            
        } else {
            _scrollMove=[self scrollViewMoveWhenKeyBoardOutBasedontextFieldHeigh:CGRectGetMaxY(_passTextField.frame)];
            _scrollView.contentOffset = CGPointMake(0, _scrollMove);
        }
    }];
    
    return YES;
    
}

//结束编辑
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField setBackground:[UIImage imageNamed:@"input_normal"]];
}

//完成键
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField setBackground:[UIImage imageNamed:@"input_normal"]];
    if (textField ==_userTextField) {
        [_passTextField becomeFirstResponder];
    }
    else
        [self endEditing];
    return YES;
}

//键盘弹出上移高度
-(CGFloat)scrollViewMoveWhenKeyBoardOutBasedontextFieldHeigh:(CGFloat)textFieldHeigh{
    CGFloat heigh = keyboard_Height-(kScreen_Height - textFieldHeigh);
    
    if (heigh>0) {
        heigh = heigh +40;
    }
    else if (heigh<40)
    {
        heigh =0;
    }
    else{
        heigh = 40-heigh;
    }
    return heigh;
}


@end
