//
//  AppDelegate.m
//  Bifrost
//
//  Created by yangke on 2017/3/8.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "AppDelegate.h"
#import "BifrostHeader.h"

#define Safe(obj) obj ? obj : [NSNull null]

@interface AppDelegate ()
    
@end

@implementation AppDelegate
    
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   [Bifrost setupAllModules];
    [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application), Safe(launchOptions)]];
    return YES;
}
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application), Safe(launchOptions)]];
    return YES;
}
    
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application)]];
}
    
- (void)applicationDidEnterBackground:(UIApplication *)application{
    [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application)]];
}
    
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application)]];
}
    
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application),Safe(url),Safe(options)]];
}
    
#pragma mark - delegate
    
#pragma mark - Push Remote Notification
    
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application), Safe(userInfo), completionHandler]];
}
    
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application), Safe(notificationSettings)]];
}
    
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application),Safe(userInfo)]];
}
    
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application), Safe(deviceToken)]];
}
    
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [Bifrost checkAllModulesWithSelector:_cmd arguments:@[Safe(application), Safe(error)]];
}
    
    @end
