//
//  HomeModule.m
//  Home
//
//  Created by yangke on 2017/9/16.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "HomeModule.h"
#import "HomeViewController.h"

@implementation HomeModule

+ (void)load {
    BFRegister(HomeModuleService);
}

#pragma mark - BifrostModuleProtocol
+ (instancetype)sharedInstance {
    static HomeModule *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setup {
    
}

+ (NSUInteger)priority {
    return BifrostModuleDefaultPriority+100; //higher priority than other modules
}

+ (BOOL)setupModuleSynchronously {
    return YES;
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = application.delegate.window;
    UIViewController *homeVC = [Bifrost handleURL:kRouteHomePage];
    UINavigationController *rootNavContoller = [[UINavigationController alloc] initWithRootViewController:homeVC];
    rootNavContoller.navigationItem.backBarButtonItem.title = @"";
    window.rootViewController = rootNavContoller;
    [window makeKeyAndVisible];
    return YES;
}

#pragma mark - HomeModuleService


@end
