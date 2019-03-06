//
//  SaleManager.h
//  Sale
//
//  Created by yangke on 2019/3/5.
//  Copyright © 2019 yangke. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SaleManager : NSObject

+ (instancetype)sharedInstance;
- (void)setup;

@end

NS_ASSUME_NONNULL_END
