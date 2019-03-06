//
//  SaleManager.m
//  Sale
//
//  Created by yangke on 2019/3/5.
//  Copyright © 2019 yangke. All rights reserved.
//

#import "SaleManager.h"
#import "HomeModuleService.h"

@implementation SaleManager

+ (instancetype)sharedInstance {
    static SaleManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setup {
    //observe Home Page Did Appear event to preload data
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSaleSettings)
                                                 name:kNotificationHomePageDidAppear
                                               object:nil];
}

- (void)updateSaleSettings {
    NSLog(@"Start to update sale settings...");
}

@end
