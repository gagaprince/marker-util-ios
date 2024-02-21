//
//  TestModule.m
//  DCTestUniPlugin
//
//  Created by XHY on 2020/4/22.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import "TestModule.h"

@implementation TestModule

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
    NSString *url = options[@"url"];
    NSString *method = options[@"method"];
    NSDictionary *headers = options[@"headers"];
    NSString *data = options[@"data"];
    NSNumber *timeout = options[@"timeout"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[timeout doubleValue]];
    [request setHTTPMethod:method];
    for (NSString *headerField in headers) {
        [request setValue:headers[headerField] forHTTPHeaderField:headerField];
    }
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (callback) {
                callback(@{@"error": error.localizedDescription}, NO);
            }
        } else {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (callback) {
                callback(@{@"data": dataString}, NO);
            }
        }
    }];

    [dataTask resume];
}

@end
