//
//  AppDelegate.m
//  SSBackgroundMode
//
//  Created by mac on 15/11/20.
//  Copyright (c) 2015年 treebear. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

typedef void(^CompletionHandlerType)();

@interface AppDelegate () <NSURLSessionDelegate,NSURLSessionDownloadDelegate>
{
    NSMutableDictionary *completionHandlerDic;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //iOS默认不进行后台获取，所以需要手动设置一个时间间隔
    //code for background fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    completionHandlerDic = [NSMutableDictionary dictionary];
    
    return YES;
}
//系统唤醒app后将会执行这个方法，可以在此做数据的刷新请求
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([vc isKindOfClass:[ViewController class]]) {
        
        [(ViewController *)vc backgroudFetch:^{
            [(ViewController *)vc updateUI];
            completionHandler(UIBackgroundFetchResultNewData);   // this code is important
        }];
    }
}

// 收到带有content-available键值的推送消息时  会调用此方法
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSNumber *contentId = userInfo[@"content-available"];
    NSString *downloadString = @"http://s1.music.126.net/download/osx/NeteaseMusic_1.3.1_366_web.dmg";
    NSURL *downloadURL = [NSURL URLWithString:downloadString];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NSURLSessionDownloadTask *downloadTask = [[self backgroundURLSession] downloadTaskWithRequest:request];
    downloadTask.taskDescription = [NSString stringWithFormat:@"Podcast Episode %d", [contentId intValue]];
    [downloadTask resume];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

// 下面代码是示范  接收到通知之后下载文件
- (NSURLSession *)backgroundURLSession{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identfier = @"io.obj.com";
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identfier];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}

// 后台请求 处理接口   在接收到background fetch 请求后出发
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    NSURLSession *backgroundSession = [self backgroundURLSession];
    NSLog(@" rejoining session with identfier %@  %@ ",identifier, backgroundSession);
    [self addCompletionHandler:completionHandler forSession:identifier];
}
#pragma mark - **************** NSURLSessionDownload delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@" downloadTask: %@ , URL : %@ ",downloadTask.taskDescription , location);
    //保存数据  更新UI
}

#pragma mark - **************** NSURLSession delegate
-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    //在任务完成后  才去处理handler
    NSLog(@"Background URL session %@ finished events.\n", session);
    if (session.configuration.identifier) {
        [self callCompletionHandlerForSession:session.configuration.identifier];
    }
}
#pragma MARK
- (void)addCompletionHandler:(void(^)())completionHandler forSession:(NSString *)identifier{
    if ([completionHandlerDic objectForKey:identifier]) {
        NSLog(@" single session identifier ERROR");
    }
    [completionHandlerDic setObject:completionHandler forKey:identifier];
}
- (void)callCompletionHandlerForSession:(NSString *)identifier{
    CompletionHandlerType handler = [completionHandlerDic objectForKey:identifier];
    if (handler) {
        [completionHandlerDic removeObjectForKey:identifier];
        handler();
        
    }
}


#pragma TODO  background fetch 流程
/*
 1. 接收到带特定标示推送通知
 2. 在接口中执行任务请求
 3. 请求数据返回时会最先调用 -downloadTask didFinishDownloadingToURL 方法，这里我们将保存下载下来的文件
 4. 接着 -handleEventsForBackgroundURLSession 会被调用，这里我们将对应identifier的处理handler保存在一个字典中，用作多任务的区分。
 5. 最后是 -URLSessionDidFinishEventsForBackgroundURLSession 被响应，这里我们最后才去处理handler
 让 completion handler 为应用程序更新界面快照。
 
 在后台请求会话中  dataTask是无法使用的   只针对下载或者上传
 */


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
