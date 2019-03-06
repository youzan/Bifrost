//
//  ShoppingCartManager.m
//  Sale
//
//  Created by yangke on 2019/2/28.
//  Copyright © 2019 yangke. All rights reserved.
//

#import "ShoppingCartManager.h"
#import "SaleBundle.h"

@interface ShoppingCartManager()
@property (nonatomic, strong) NSMutableDictionary* cartItemDict;
@end
@implementation ShoppingCartManager
    
+ (instancetype)sharedInstance {
    static ShoppingCartManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
        instance.cartItemDict = [NSMutableDictionary dictionary];
    });
    return instance;
}
    
- (void)addGoods:(nonnull NSString*)goodsId
         withNum:(NSUInteger)num {
    ShoppingCartItem *item = [self.cartItemDict objectForKey:goodsId];
    if (!item) {
        item = [[ShoppingCartItem alloc] init];
        item.goodsId = goodsId;
        [self.cartItemDict setObject:item forKey:goodsId];
    }
    item.num += num;
}

- (NSUInteger)shoppinCartGoodsNum {
    NSUInteger sum = 0;
    for (ShoppingCartItem *item in self.cartItemDict.allValues) {
        sum += item.num;
    }
    return sum;
}

@end

@implementation ShoppingCartItem
@end
