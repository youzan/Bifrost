//
//  ShopManager.h
//  Shop
//
//  Created by yangke on 2019/3/5.
//  Copyright © 2019 jackie@youzan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShopManager : NSObject

+ (instancetype)sharedInstance;
- (void)setup;

@end

NS_ASSUME_NONNULL_END
