//
//  TestComponent.m
//  DCTestUniPlugin
//
//  Created by XHY on 2020/4/23.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import "TestComponent.h"
#import "DCUniConvert.h"

@interface TestComponent ()


@property (nonatomic, assign) BOOL schemeLoadedEvent;


@end

@implementation TestComponent

-(void)onCreateComponentWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events uniInstance:(DCUniSDKInstance *)uniInstance
{

}

- (UIView *)loadView {
    return [UIView new];
}

- (void)viewDidLoad {
  

}

/// 前端更新属性回调方法
/// @param attributes 更新的属性
- (void)updateAttributes:(NSDictionary *)attributes {

}

/// 前端注册的事件会调用此方法
/// @param eventName 事件名称
- (void)addEvent:(NSString *)eventName {
    if([eventName isEqualToString:@"schemeLoaded"]) {
        _schemeLoadedEvent = YES;
    }
}

/// 对应的移除事件回调方法
/// @param eventName 事件名称
- (void)removeEvent:(NSString *)eventName {
    if([eventName isEqualToString:@"schemeLoaded"]) {
        _schemeLoadedEvent = NO;
    }
}

- (void)jumpToSchemePages:(NSString*) link{
    if (_schemeLoadedEvent) {
        // 向前端发送事件，params 为传给前端的数据 注：数据最外层为 NSDictionary 格式，需要以 "detail" 作为 key 值
        [self fireEvent:@"schemeLoaded" params:@{@"detail":@{@"schemeLoaded":@"success"}} domChanges:nil];
    }
}


// 通过 WX_EXPORT_METHOD 将方法暴露给前端
UNI_EXPORT_METHOD(@selector(focus:))

- (void)focus:(NSDictionary *)options {
    // options 为前端传递的参数
    NSLog(@"%@",options);
}

@end
