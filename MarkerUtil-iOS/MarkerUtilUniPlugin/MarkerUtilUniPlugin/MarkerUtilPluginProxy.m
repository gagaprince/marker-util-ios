//
//  DCTestPluginProxy.m
//  DCTestUniPlugin
//
//  Created by XHY on 2020/5/19.L
//  Copyright © 2020 DCloud. All rights reserved.
//

#import "MarkerUtilPluginProxy.h"


@implementation MarkerUtilPluginProxy

- (void)onCreateUniPlugin {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

- (BOOL)application:(UIApplication *_Nullable)application didFinishLaunchingWithOptions:(NSDictionary *_Nullable)launchOptions {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
    return YES;
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *_Nullable)deviceToken{
    NSLog(@"weboey......");
    NSLog(@"token:%@", deviceToken);
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"deviceToken:%@",hexToken);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:hexToken forKey:@"mt_deviceToken"];
    [defaults synchronize];
}

- (void)didReceiveRemoteNotification:(NSDictionary *_Nullable)userInfo{
    NSLog(@"didReceiveRemoteNotification Func: %@",userInfo);
    MarkerUtilNativeModule * nativeM = [MarkerUtilNativeModule sharedSingleton];
    [nativeM jumpToPages:userInfo];
}

- (BOOL)application:(UIApplication *_Nullable)application handleOpenURL:(NSURL *_Nullable)url{
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
    return YES;
}

- (BOOL)application:(UIApplication *_Nullable)app openURL:(NSURL *_Nonnull)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *_Nullable)options NS_AVAILABLE_IOS(9_0)
{
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
    NSString * scheme = [url scheme];
    NSLog(@"%@",scheme);
    if ([scheme isEqual:@"marker"]) {
        NSArray * arr = [[url absoluteString] componentsSeparatedByString:@"="];
        if(arr[1]){
            NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:arr[1],@"path",nil];
            NSString * eventName = @"schemeEvent";
            return YES;
        }
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication * _Nullable)application {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

- (void)applicationDidBecomeActive:(UIApplication *_Nullable)application {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

- (void)applicationDidEnterBackground:(UIApplication *_Nullable)application {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

- (void)applicationWillEnterForeground:(UIApplication *_Nullable)application {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

- (void)applicationWillTerminate:(UIApplication *_Nullable)application {
    NSLog(@"UniPluginProtocol Func: %@,%s",self,__func__);
}

@end
