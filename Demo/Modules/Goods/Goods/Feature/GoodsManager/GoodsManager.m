//
//  GoodsManager.m
//  Goods
//
//  Created by yangke on 2019/3/5.
//  Copyright © 2019 jackie@youzan. All rights reserved.
//

#import "GoodsManager.h"
#import "HomeModuleService.h"

@implementation GoodsManager

+ (instancetype)sharedInstance {
    static GoodsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setup {
    //observe Home Page Did Appear event to preload data
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGoodsData)
                                                 name:kNotificationHomePageDidAppear
                                               object:nil];
}

- (void)updateGoodsData {
    NSLog(@"Start to update goods data...");
}

@end
