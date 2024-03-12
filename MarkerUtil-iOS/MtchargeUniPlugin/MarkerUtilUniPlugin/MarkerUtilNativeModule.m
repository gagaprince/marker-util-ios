//
//  TestModule.m
//  DCTestUniPlugin
//
//  Created by XHY on 2020/4/22.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import "MarkerUtilNativeModule.h"
#import <MarkerUtilUniPlugin/MarkerUtilPluginConfig.h>
#import <UserNotifications/UserNotifications.h>
#import "WeexSDK.h"

@implementation MarkerUtilNativeModule

static MarkerUtilNativeModule *_sharedSingleton = nil;

//初始化
+ (instancetype)sharedSingleton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 不能再使用 alloc 方法
        // 因为已经重写了 allocWithZone 方法，所以这里要调用父类的分配空间的方法
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}
 
// ②、防止 [[A alloc] init] 和 new 引起的错误。因为 [[A alloc] init] 和 new 实际是一样的工作原理，都是执行了下面方法
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [MarkerUtilNativeModule sharedSingleton];
}
 
// ③、NSCopying 防止 copy 引起的错误。当你的单例类不遵循 NSCopying 协议，外部调用本身就会出错.
- (id)copyWithZone:(nullable NSZone *)zone
{
    return [MarkerUtilNativeModule sharedSingleton];
}
 
// ④、防止 mutableCopy 引起的错误，当你的单例类不遵循 NSMutableCopying 协议，外部调用本身就会出错.
- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return [MarkerUtilNativeModule sharedSingleton];
}

-(void)jumpToPages:(NSDictionary*)userInfo{
    NSDictionary * apsDic = [userInfo objectForKey:@"aps"];
    NSDictionary * alertDic = [apsDic objectForKey:@"alert"];
    if (alertDic.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DCUniSDKInstance * instance = (DCUniSDKInstance*)[self weexInstance];
            if (instance) {
                [instance fireGlobalEvent:@"pushEvent" params:alertDic];
            }
        });
      
    }
}

//向uniapp发送获取到的设备信息
-(void)sendDeviceToken:(NSString*)deviceToken{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:deviceToken,@"deviceToken",nil];
    if (deviceToken.length > 0) {
        DCUniSDKInstance * instance = (DCUniSDKInstance*)[self weexInstance];
        if (instance) {
            [instance fireGlobalEvent:@"deviceTokenEvent" params:params];
        }
    }
}

UNI_EXPORT_METHOD(@selector(justBindInstance))
-(void)justBindInstance{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * deviceToken = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"mt_deviceToken"]];
        [self sendDeviceToken:deviceToken];
    });
  
}

-(DCUniSDKInstance *)js_uniInstance{
    if (!_js_uniInstance) {
        _js_uniInstance = [[DCUniSDKInstance alloc]init];
    }
    return _js_uniInstance;
}


// 通过宏 UNI_EXPORT_METHOD 将异步方法暴露给 js 端
UNI_EXPORT_METHOD(@selector(testAsyncFunc:callback:))
/// 异步方法（注：异步方法会在主线程（UI线程）执行）
/// @param options js 端调用方法时传递的参数
/// @param callback 回调方法，回传参数给 js 端
- (void)testAsyncFunc:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    // options 为 js 端调用此方法时传递的参数
    NSLog(@"%@",options);
    
    // 可以在该方法中实现原生能力，然后通过 callback 回调到 js

    // 回调方法，传递参数给 js 端 注：只支持返回 String 或 NSDictionary (map) 类型
    if (callback) {
        // 第一个参数为回传给js端的数据，第二个参数为标识，表示该回调方法是否支持多次调用，如果原生端需要多次回调js端则第二个参数传 YES;
        callback(@"success",NO);
    }
}

// 通过宏 UNI_EXPORT_METHOD_SYNC 将同步方法暴露给 js 端
UNI_EXPORT_METHOD_SYNC(@selector(testSyncFunc:))

/// 同步方法（注：同步方法会在 js 线程执行）
/// @param options js 端调用方法时传递的参数
- (NSString *)testSyncFunc:(NSDictionary *)options {
    // options 为 js 端调用此方法时传递的参数
    NSLog(@"%@",options);

    /*
     可以在该方法中实现原生功能，然后直接通过 return 返回参数给 js
     */

    // 同步返回参数给 js 端 注：只支持返回 String 或 NSDictionary (map) 类型
    return @"success";
}

@end
