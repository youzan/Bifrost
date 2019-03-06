//
//  ShopManager.m
//  Shop
//
//  Created by yangke on 2019/3/5.
//  Copyright © 2019 jackie@youzan. All rights reserved.
//

#import "ShopManager.h"
#import "HomeModuleService.h"

@implementation ShopManager

+ (instancetype)sharedInstance {
    static ShopManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setup {
    //observe Home Page Did Appear event to preload data
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateShopData)
                                                 name:kNotificationHomePageDidAppear
                                               object:nil];
}

- (void)updateShopData {
    NSLog(@"Start to update shop data...");
}



@end
