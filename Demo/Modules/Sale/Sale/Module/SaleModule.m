//
//  SaleModule.m
//  SaleModule
//
//  Created by youzan on 2017/2/28.
//  Copyright (c) 2017年 youzan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SaleModule.h"
#import "ShoppingCartManager.h"
#import "SaleManager.h"

@interface SaleModule()

@end

@implementation SaleModule

+ (void)load {
    BFRegister(SaleModuleService);
}

#pragma mark - BifrostModuleProtocol methods

+ (instancetype)sharedInstance {
    static SaleModule *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setup {
    [[SaleManager sharedInstance] setup];
}

#pragma mark - SaleModuleService

- (void)addGoods:(NSString*)goodsId withNum:(NSUInteger)num {
    [[ShoppingCartManager sharedInstance] addGoods:goodsId withNum:num];
}

- (void)addShoppingCartGoods:(NSString*)goodsId {
    [[ShoppingCartManager sharedInstance] addGoods:goodsId withNum:1];
}
- (NSUInteger)shoppinCartGoodsNum {
    return [[ShoppingCartManager sharedInstance] shoppinCartGoodsNum];
}

@end
