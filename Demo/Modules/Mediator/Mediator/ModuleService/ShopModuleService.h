//
//  ShopModuleService.h
//  Shop
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#ifndef ShopModuleService_h
#define ShopModuleService_h
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
static NSString *const kRouteShopDetail = @"//shop/detail";


#pragma mark - Model Protocols


#pragma mark - Module Protocol
/**
 The services provided by shop module to other modules
 */
@protocol ShopModuleService <NSObject>

- (NSString*)shopName;
- (UIImage*)shopLogo;
- (CGFloat)shopRevenue;

@end

NS_ASSUME_NONNULL_END
#endif /* ShopModuleService_h */
