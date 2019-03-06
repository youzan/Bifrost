//
//  ShoppingCartManager.h
//  Sale
//
//  Created by yangke on 2019/2/28.
//  Copyright © 2019 yangke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShoppingCartManager : NSObject

@property (nonatomic, readonly) NSMutableDictionary* cartItemDict;

+ (instancetype)sharedInstance;

- (void)addGoods:(nonnull NSString*)goodsId withNum:(NSUInteger)num;
- (NSUInteger)shoppinCartGoodsNum;

@end

@interface ShoppingCartItem : NSObject
@property (nonatomic, strong) NSString *goodsId;
@property (nonatomic, assign) NSUInteger num;
@end

NS_ASSUME_NONNULL_END
