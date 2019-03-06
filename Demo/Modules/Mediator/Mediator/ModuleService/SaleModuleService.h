//
//  SaleModuleService.h
//  Sale
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#ifndef SaleModuleService_h
#define SaleModuleService_h

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
static NSString *const kRouteSaleShoppingCart = @"//sale/shopping_chart";


#pragma mark - Model Protocols


#pragma mark - Module Protocol
/**
 The services provided by Sale module to other modules
 */
@protocol SaleModuleService <NSObject>
    
//add goods to shopping cart
- (void)addShoppingCartGoods:(NSString*)goodsId;
- (NSUInteger)shoppinCartGoodsNum;
    
@end

NS_ASSUME_NONNULL_END
#endif /* SaleModuleService_h */
