//
//  JSPluginConfig.h
//  DCTestUniPlugin
//
//  Created by JS on 12/18/23.
//  Copyright © 2023 DCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MarkerUtilPluginConfig : NSObject

@property (nonatomic, copy)  void (^clickBtnBlock)(NSDictionary* handler);


+ (MarkerUtilPluginConfig *)sharedPluginConfig;

+ (NSString *)convertToJsonData:(NSDictionary *)dict;
- (UIViewController *)topViewController;
@end

NS_ASSUME_NONNULL_END
