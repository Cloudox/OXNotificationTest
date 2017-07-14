//
//  ViewController.m
//  OXNotificationTest
//
//  Created by Cloudox on 2017/7/13.
//  Copyright © 2017年 Tencare. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

//设备的宽高
#define SCREENWIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT      [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataArray = [[NSMutableArray alloc] init];
    self.timeArray = [[NSMutableArray alloc] init];
    
    // 列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, SCREENWIDTH, SCREENHEIGHT-30)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    // 判断系统版本
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 10.0) {// iOS 10以上版本，通过UNUserNotificationCenter来管理通知
        // 定时发送本地通知
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(addlocalNotificationForNewVersion) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
}

/**
 iOS 10以后的本地通知
 */
- (void)addlocalNotificationForNewVersion {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Hello" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"Agent-%d",arc4random()%100] arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    
    //    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alertTime repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"OXNotification" content:content trigger:nil];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        NSLog(@"成功添加推送");
    }];
}

/**
 日期转字符串
 
 @param date 日期
 @return 日期字符串
 */
- (NSString *)convertNSDateToNSString:(NSDate *)date
{
    if (!date)
        date = [NSDate date];
    
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    [formatter setTimeZone:zone];
    return [formatter stringFromDate:date];
}

#pragma mark - UNUserNotificationCenterDelegate
// iOS 10收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知:%@", body);
        
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
        [self.dataArray addObject:content];
        [self.timeArray addObject:[self convertNSDateToNSString:[NSDate date]]];
        [self.tableView reloadData];
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *SimpleCell = @"SimpleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: SimpleCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SimpleCell];
    }
    
    UNNotificationContent *content = self.dataArray[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", content.title, content.body];
    cell.detailTextLabel.text = self.timeArray[indexPath.row];
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 选中后取消选中的颜色
    
    // 添加到剪切板
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    UNNotificationContent *content = self.dataArray[indexPath.row];
    [pasteboard setString:[NSString stringWithFormat:@"%@ %@", content.title, content.body]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"复制成功" message:[NSString stringWithFormat:@"%@ %@", content.title, content.body] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
