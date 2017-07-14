//
//  AppDelegate.m
//  OXNotificationTest
//
//  Created by Cloudox on 2017/7/13.
//  Copyright © 2017年 Tencare. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 判断系统版本
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 10.0) {// iOS 10以上版本，通过UNUserNotificationCenter来管理通知
        // 注册通知
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
    } else {// iOS 10以下的版本
        // 注册通知，如果已经获得发送通知的授权则创建本地通知，否则请求授权(注意：如果不请求授权在设置中是没有对应的通知设置项的，也就是说如果从来没有发送过请求，即使通过设置也打不开消息允许设置)
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
            [self addLocalNotificationForOldVersion];
        } else {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
        }
    }
    
    
    return YES;
}

/**
 应用注册通知后

 @param application 应用
 @param notificationSettings 通知设置
 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [self addLocalNotificationForOldVersion];
    }
}

/**
 应用进入前台时调用

 @param application 应用
 */
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];//进入前台取消应用消息图标
}

/**
 iOS 10以前版本添加本地通知
 */
- (void)addLocalNotificationForOldVersion {
    
    //定义本地通知对象
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //设置调用时间
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2.0];//通知触发的时间，10s以后
    notification.repeatInterval = 2;//通知重复次数
    notification.repeatCalendar=[NSCalendar currentCalendar];//当前日历，使用前最好设置时区等信息以便能够自动同步时间
    
    //设置通知属性
    notification.alertBody = [NSString stringWithFormat:@"Agent-%d",arc4random()%100]; //通知主体
    notification.applicationIconBadgeNumber += 1;//应用程序图标右上角显示的消息数
    notification.alertAction = @"打开应用"; //待机界面的滑动动作提示
    notification.alertLaunchImage = @"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
    notification.soundName = UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
//    notification.soundName=@"msg.caf";//通知声音（需要真机才能听到声音）
    
    //设置用户信息
    notification.userInfo = @{@"id": @1, @"user": @"cloudox"};//绑定到通知上的其他附加信息
    
    //调用通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

/**
 收到通知后回调

 @param application 应用
 @param notification 通知
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification {
    NSLog(@"%@", notification.alertBody);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
