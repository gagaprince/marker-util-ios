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
#import <JavaScriptCore/JavaScriptCore.h>
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

UNI_EXPORT_METHOD(@selector(sendRequest:callback:))

- (void)sendRequest:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSLog(@"%@",options);
    NSString *url = options[@"url"];
    NSString *method = options[@"method"] ? options[@"method"] : @"GET";
    NSDictionary *headers = options[@"headers"];
    NSString *data = options[@"data"];
    NSNumber *timeout = options[@"timeout"];
    self.followRedirects = options[@"followRedirects"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[timeout doubleValue]];
    [request setHTTPMethod:method];
    for (NSString *headerField in headers) {
        [request setValue:headers[headerField] forHTTPHeaderField:headerField];
    }
    
    if ([method isEqualToString:@"POST"]) {
        [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (callback) {
                callback(@{@"error": error.localizedDescription}, NO);
            }
        } else {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *headerFields = [httpResponse allHeaderFields];
            if (callback) {
                callback(@{@"data": dataString, @"headers": headerFields}, NO);
            }
        }
    }];
    
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if ([response statusCode] == 302 && ![self.followRedirects boolValue]) {
        completionHandler(nil);
    } else {
        completionHandler(request);
    }
}


UNI_EXPORT_METHOD(@selector(sign:callback:))

- (void)sign:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback  {
    NSString *url = options[@"url"];
    NSString *userAgent = options[@"user_agent"];
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    NSString *query = components.query;
    
    NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"X-Bogus" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript:jsCode];
    JSValue *signFunction = context[@"sign"];
    JSValue *xbogus = [signFunction callWithArguments:@[query, userAgent]];
    
    NSString *newUrl = [NSString stringWithFormat:@"%@&X-Bogus=%@", url, xbogus.toString];
    NSDictionary *responseData = @{
        @"newUrl": newUrl,
        @"X-Bogus": xbogus.toString
    };
    
    if (callback) {
        // 第一个参数为回传给js端的数据，第二个参数为标识，表示该回调方法是否支持多次调用，如果原生端需要多次回调js端则第二个参数传 YES;
        callback(@{@"data": responseData},NO);
    }
}


@end
