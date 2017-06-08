//
//  AppDelegate.m
//  DroiPushSDK
//
//  Created by Jon on 16/9/19.
//  Copyright © 2016年 Droi. All rights reserved.
//

#import <DroiCoreSDK/DroiCoreSDK.h>
#import "AppDelegate.h"
#import "DroiPushViewController.h"
#import <DroiPush/DroiPush.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#if DEBUG
#define DROI_PUSH_API_KEY  @"YOUR DEBUG API KEY"
#else
#define DROI_PUSH_API_KEY  @"YOUR RELEASE API KEY"
#endif


@interface DroiLogInternal : NSObject
+ (void) setLevelPrint : (NSInteger) level;
@end

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DroiPush registerForRemoteNotificationWithAPIKey:DROI_PUSH_API_KEY];
    //iOS10必须加下面这段代码。
    if (IOS_VERSION >= 10.0) {
    #ifdef NSFoundationVersionNumber_iOS_9_x_Max
        UNAuthorizationOptions types=UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:types completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
                //这里可以添加一些自己的逻辑
            }
            else{
                //点击不允许
                //这里可以添加一些自己的逻辑
            }
        }];
#endif
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    DroiPushViewController *rootVC = [[DroiPushViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootVC];
    self.window.rootViewController =nav;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [DroiPush registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [self log:[NSString stringWithFormat:@"didFailToRegisterForRemoteNotificationsWithError %@",error]];
}

//iOS 7 ~ iOS 9 系统收到远程推送会调用这个方法,且点击状态栏进入app 也会走这个方法(无论后台,还是杀死状态)
//iOS 10的系统如果消息中不含有content-available不走这个方法,且点击状态栏进入app会走新增加的代理方法
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [DroiPush handleRemoteNotification:userInfo];
    [self log:[NSString stringWithFormat:@"didReceiveRemoteNotification %@",userInfo]];
    completionHandler(UIBackgroundFetchResultNewData);
}


#pragma mark iOS 10 UNUserNotificationCenterDelegate

/// App在前台PresentNotification时候回调 可以又Alert,Sound,Badge 也可以不做处理
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary *userInfo = notification.request.content.userInfo;
    completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
    [self log:[NSString stringWithFormat:@"willPresentNotification %@",userInfo]];

}

// iOS 10系统在点击状态栏进入app 会走这个方法(无论后台,还是杀死状态) state = Inactive
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [self log:[NSString stringWithFormat:@"didReceiveNotificationResponse %@",userInfo]];
    completionHandler();
}

- (void)log:(NSString *)string{
    NSLog(@"%@",string);
    UINavigationController *rootVC = (UINavigationController *)self.window.rootViewController;
    for (UIViewController *vc in rootVC.viewControllers) {
        if ([vc isKindOfClass:[DroiPushViewController class]]) {
            [vc performSelector:@selector(LogString:) withObject:string];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
