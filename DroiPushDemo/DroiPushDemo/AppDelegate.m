//
//  AppDelegate.m
//  DroiPushDemo
//
//  Created by Jon on 16/7/13.
//  Copyright © 2016年 Droi. All rights reserved.
//

#import "AppDelegate.h"
#import "DroiPushViewController.h"
#import <DroiPush/DroiPush.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@interface DroiLogInternal : NSObject
+ (void) setLevelPrint : (NSInteger) level;
@end

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [DroiLogInternal setLevelPrint:4];
    
    [DroiPush registerForRemoteNotifications];
    
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
    //监听透传消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSilentNotification:) name:kDroiPushReceiveSilentNotification object:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    DroiPushViewController *rootVC = [[DroiPushViewController alloc] init];
    self.window.rootViewController =rootVC;
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

//收到透传消息执行
- (void)receiveSilentNotification:(NSNotification *)notification{
    
    NSDictionary *userInfo = notification.userInfo;
    [self alertString:[NSString stringWithFormat:@"receiveSilentNotification %@",userInfo]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    [DroiPush registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    [self alertString:[NSString stringWithFormat:@"didFailToRegisterForRemoteNotificationsWithError %@",error]];
}


//iOS 7 ~ iOS 9 系统收到远程推送会调用这个方法,且点击状态栏进入app 也会走这个方法(无论后台,还是杀死状态)
//iOS 10的系统如果消息中不含有content-available不走这个方法,且点击状态栏进入app会走新增加的代理方法
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    //    [self alertString:[NSString stringWithFormat:@"didReceiveRemoteNotification:%@",userInfo]];
    [DroiPush handleRemoteNotification:userInfo];
    [self log:[NSString stringWithFormat:@"didReceiveRemoteNotification %@",userInfo]];
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark iOS 10 UNUserNotificationCenterDelegate

/// App在前台PresentNotification时候回调 可以又Alert,Sound,Badge 也可以不做处理
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    completionHandler(UNNotificationPresentationOptionAlert);
    [self log:[NSString stringWithFormat:@"willPresentNotification %@",userInfo]];
}

// iOS 10系统在点击状态栏进入app 会走这个方法(无论后台,还是杀死状态) state = Inactive
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [self log:[NSString stringWithFormat:@"didReceiveNotificationResponse %@",userInfo]];
    completionHandler();
}



- (void)alertString:(NSString *)String{
    
    DroiPushViewController *rootVC = (DroiPushViewController *)self.window.rootViewController;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:String preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancle];
    [rootVC presentViewController:alert animated:YES completion:nil];
}

- (void)log:(NSString *)string{
    
    NSString *tempStr1 = [string stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [NSPropertyListSerialization propertyListFromData:tempData
                                                     mutabilityOption:NSPropertyListImmutable
                                                               format:NULL
                                                     errorDescription:NULL];
    NSLog(@"%@",str);
    DroiPushViewController *rootVC = (DroiPushViewController *)self.window.rootViewController;
    [rootVC LogString:string];
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
