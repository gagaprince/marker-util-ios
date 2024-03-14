//
//  TestModule.h
//  DCTestUniPlugin
//
//  Created by XHY on 2020/4/22.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniModule.h"
#import "WXModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MarkerUtilNativeModule : DCUniModule <WXModuleProtocol, NSURLSessionDelegate>

@property (nonatomic, strong) DCUniSDKInstance * js_uniInstance;
@property (nonatomic, strong) NSNumber *followRedirects;

+ (MarkerUtilNativeModule *)sharedSingleton;

//根据推送内容跳转到uniapp的某一页面
-(void)jumpToPages:(NSDictionary*)userInfo;

//向uniapp发送获取到的设备信息
-(void)sendDeviceToken:(NSString*)deviceToken;

@end

NS_ASSUME_NONNULL_END
