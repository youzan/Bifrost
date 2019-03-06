//
//  ShopModule.m
//  Shop
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "ShopModule.h"
#import "ShopBundle.h"
#import "ShopManager.h"

@implementation ShopModule

+ (void)load {
    BFRegister(ShopModuleService);
    for(NSInteger i=0; i<100; i++) {
        BFRegister(ShopModuleService);
    }
}

#pragma mark - BifrostModuleProtocol methods

+ (instancetype)sharedInstance {
    static ShopModule *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
    
}

- (void)setup {
    [[ShopManager sharedInstance] setup];
}

- (void)preLoadGoodsInfo {
    //some preload work here. it will take long time
    sleep(10);
}

#pragma mark - ShopModuleService
- (NSString*)shopName {
    return @"零售特工队";
}

- (UIImage*)shopLogo {
    return [ShopBundle imageNamed:@"shop_logo"];
}

- (CGFloat)shopRevenue {
    return 666666.66;
}


@end
