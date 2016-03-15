//
//  TCPUDPmethod.m
//  HJFminshi
//
//  Created by 胡江峰 on 16/3/9.
//  Copyright © 2016年 胡江峰. All rights reserved.
//

#import "TCPUDPmethod.h"
#import "GCDAsyncSocket.h"
@implementation TCPUDPmethod

+ (NSDictionary * )getsslSettingWithhost:(NSString *)host
{
    NSMutableDictionary *sslSettings = nil;
    //    NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zhengshu" ofType:@"p12"]];
    NSData *pkcs12data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sslcer" ofType:@"p12"]];
    
    CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(pkcs12data);
    CFStringRef password = CFSTR("123456");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    OSStatus securityError = SecPKCS12Import(inPKCS12Data, options, &items);
    CFRelease(options);
    CFRelease(password);
    
    /*
     @result errSecSuccess in case of success. errSecDecode means either the
     blob can't be read or it is malformed. errSecAuthFailed means an
     incorrect password was passed, or data in the container got damaged.
     */
    NSLog(@"securityError = %d",(int)securityError);
    
    if(securityError == errSecSuccess) {
        
        NSLog(@">>>>>Success opening p12 certificate.");
        sslSettings = [[NSMutableDictionary alloc] init];
        
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef myIdent = (SecIdentityRef)CFDictionaryGetValue(identityDict,kSecImportItemIdentity);
        
        SecIdentityRef  certArray[1] = { myIdent };
        CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
        
        [sslSettings setObject:(id)CFBridgingRelease(myCerts) forKey:(NSString *)kCFStreamSSLCertificates];
        [sslSettings setObject:[NSNumber numberWithInt:2] forKey:GCDAsyncSocketSSLProtocolVersionMin];
        [sslSettings setObject:[NSNumber numberWithInt:8] forKey:GCDAsyncSocketSSLProtocolVersionMax];
        //#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [sslSettings setObject:[NSNumber numberWithBool:YES] forKey:GCDAsyncSocketManuallyEvaluateTrust];
        [sslSettings setObject:host forKey:(NSString *)kCFStreamSSLPeerName];
        
    } else if (errSecDecode == securityError){
        NSLog(@">>>>>Failed opening p12 certificate.:---->>errSecDecode");
    } else if (errSecAuthFailed == securityError) {
        NSLog(@">>>>>Failed opening p12 certificate.:---->>errSecAuthFailed");
    } else {
        NSLog(@">>>>>Failed opening p12 certificate.");
    }
    return sslSettings;
}

@end
