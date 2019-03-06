//
//  HomeModuleService.h
//  Home
//
//  Created by yangke on 2017/9/16.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#ifndef HomeModuleService_h
#define HomeModuleService_h

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
static NSNotificationName kNotificationHomePageDidAppear = @"kNotificationHomePageDidAppear";

#pragma mark - URL routers
static NSString *const kRouteHomePage = @"//home/home_page";


#pragma mark - Model Protocols


#pragma mark - Module Protocol
/**
 The services provided by home module to other modules
 */
@protocol HomeModuleService <NSObject>

@end

NS_ASSUME_NONNULL_END
#endif /* HomeModuleService_h */
