//
//  AppDelegate.m
//  Pandora
//
//  Created by Mac Pro_C on 12-12-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PDRCore.h"
#import "PDRCommonString.h"
#import "ViewController.h"
#import "PDRCoreApp.h"
#import "PDRCoreAppManager.h"

#import <MarkerUtilUniPlugin/MarkerUtilPluginConfig.h>
#import <MarkerUtilUniPlugin/MarkerUtilNativeModule.h>

#import <UserNotifications/UserNotifications.h>


@interface AppDelegate()<PDRCoreDelegate,UNUserNotificationCenterDelegate>
@property (strong, nonatomic) ViewController *h5ViewContoller;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize rootViewController;
#pragma mark -
#pragma mark app lifecycle
/*
 * @Summary:程序启动时收到push消息
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    BOOL ret = [PDRCore initEngineWihtOptions:launchOptions
                                  withRunMode:PDRCoreRunModeNormal withDelegate:self];

    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    
    [self initPluginSDK];
    
    ViewController *viewController = [[ViewController alloc] init];
    self.h5ViewContoller = viewController;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.rootViewController = navigationController;
    navigationController.navigationBarHidden = YES;
    {
        [self startMainApp];
        self.h5ViewContoller.showLoadingView = YES;
    }
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    [self registerPushNotificationAuthorization:application];

    return ret;
}

//初始化SDK
-(void)initPluginSDK{
    NSLog(@"app 启动了....");
}

#pragma mark ==========请求用户给权限==========
- (void)registerPushNotificationAuthorization:(UIApplication *)application{
    if (@available(iOS 10.0, *)) {
        //iOS 10 later
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //必须写代理，不然无法监听通知的接收与点击事件
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                //用户点击允许
                NSLog(@"注册成功");
            }else{
                //用户点击不允许
                NSLog(@"注册失败");
            }
        }];
        // 可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
        //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"========%@",settings);
        }];
    }
    //注册远端消息通知获取device token
    [application registerForRemoteNotifications];
}

#pragma mark ==========YES有权限  NO无权限==========
-(void)seeCurrentNotificationStatus{
    if (@available(iOS 10 , *)){
         [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusDenied){
                // 没权限
                NSLog(@"无推送权限，弹窗处理");
                [self pushNotifcationView];
            }
        }];
    }
}

#pragma mark ==========弹窗出推送权限==========
-(void)pushNotifcationView{
    //一天之内只提示一次
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //拿到当前时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //当前时间
    NSDate *nowDate = [NSDate date];
    NSString *nowDateStr= [dateFormatter stringFromDate:nowDate];
    //之前时间
    NSString *agoDateStr = [userDefault objectForKey:@"saveNowDate"];
    //判断时间差
    if ([agoDateStr isEqualToString:nowDateStr]) {
        //是当天时间
    }else{
        //弹窗
        //主线程使用
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"弹窗显示获取推送权限");
        });
        //保存当前时间
        [userDefault setObject:nowDateStr forKey:@"saveNowDate"];
        [userDefault synchronize];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /**
     *  系统会估量App消耗的电量，并根据传递的UIBackgroundFetchResult 参数记录新数据是否可用
     *  调用完成的处理代码时，应用的界面缩略图会自动更新
     */
    NSLog(@"did Receive Remote Notification userInfo %@",userInfo);
    [PDRCore handleSysEvent:PDRCoreSysEventRevRemoteNotification withObject:userInfo];
    switch (application.applicationState) {
        case UIApplicationStateActive:
            completionHandler(UIBackgroundFetchResultNewData);
            break;
        case UIApplicationStateInactive:
            completionHandler(UIBackgroundFetchResultNewData);
            break;
        case UIApplicationStateBackground:
            completionHandler(UIBackgroundFetchResultNewData);
            break;
        default:
            break;
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"注册推送失败：%@",error);
}

//收到消息后处理通知
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSLog(@"收到推送内容");
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //TODO:处理远程推送内容
        NSLog(@"%@", userInfo);
    }
    [PDRCore handleSysEvent:PDRCoreSysEventRevRemoteNotification withObject:userInfo];
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//App被唤醒后清空通知栏消息
- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"app 被唤醒....");
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    [PDRCore handleSysEvent:PDRCoreSysEventBecomeActive withObject:nil];
}

-(BOOL)getStatusBarHidden {
    return [self.h5ViewContoller getStatusBarHidden];
}

-(UIStatusBarStyle)getStatusBarStyle {
    return [self.h5ViewContoller getStatusBarStyle];
}

-(void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [self.h5ViewContoller setStatusBarStyle:statusBarStyle];
}

-(void)wantsFullScreen:(BOOL)fullScreen
{
    [self.h5ViewContoller wantsFullScreen:fullScreen];
}

#pragma mark -
- (void)startMainApp {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[PDRCore Instance] start];
    });
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem
  completionHandler:(void(^)(BOOL succeeded))completionHandler{
    [PDRCore handleSysEvent:PDRCoreSysEventPeekQuickAction withObject:shortcutItem];
    completionHandler(true);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    [PDRCore handleSysEvent:PDRCoreSysEventResignActive withObject:nil];

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [PDRCore handleSysEvent:PDRCoreSysEventEnterBackground withObject:nil];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [PDRCore handleSysEvent:PDRCoreSysEventEnterForeGround withObject:nil];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [PDRCore destoryEngine];
}

#pragma mark -
#pragma mark URL

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return YES;
}


/*
 * @Summary:程序被第三方调用，传入参数启动
 *
 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [PDRCore handleSysEvent:PDRCoreSysEventOpenURL withObject:url];
    return YES;
}
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [PDRCore handleSysEvent:PDRCoreSysEventOpenURLWithOptions withObject:@[url,options]];
    return YES;
}

/*
 * @Summary:通用链接
 */
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    [PDRCore handleSysEvent:PDRCoreSysEventContinueUserActivity withObject:userActivity];
    restorationHandler(nil);
    return YES;
}
@end

@implementation UINavigationController(Orient)

-(BOOL)shouldAutorotate{
    return ![PDRCore Instance].lockScreen;
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if([self.topViewController isKindOfClass:[ViewController class]])
        return [self.topViewController supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskPortrait;
}

@end
