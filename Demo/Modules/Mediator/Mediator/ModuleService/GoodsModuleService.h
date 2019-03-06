//
//  GoodsModuleService.h
//  Goods
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#ifndef GoodsModuleService_h
#define GoodsModuleService_h

///<v1.0>
/**
 service protocol头文件版本号基于Semantic Versioning
 x(major).y(minor)
 major - 公共API改动或者删减
 minor - 新添加了公共API
 小于1.0的版本（如0.6），视为未稳定版本，不做上述限制。
 */

#import "BifrostHeader.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Notifications
//static NSNotificationName kNotification*** = @"kNotification***";

#pragma mark - URL routers
static NSString *const kRouteAllGoodsList = @"//goods/all_goods_list";
static NSString *const kRouteGoodsDetail = @"//goods/detail";
static NSString *const kRouteGoodsDetailParamId = @"id";

#pragma mark - Model Protocols
@protocol GoodsProtocol <NSObject>
- (NSString*)goodsId;
- (NSString*)name;
- (CGFloat)price;
- (NSInteger)inventory;
@end

#pragma mark - Module Protocol
/**
 The services provided by goods module to other modules
 */
@protocol GoodsModuleService <NSObject>

- (NSInteger)totalInventory;
- (NSArray<id<GoodsProtocol>>*)popularGoodsList; //热卖商品
- (NSArray<id<GoodsProtocol>>*)allGoodsList; //所有商品
- (id<GoodsProtocol>)goodsById:(nonnull NSString*)goodsId;

@end

NS_ASSUME_NONNULL_END

#endif /* GoodsModuleService_h */
