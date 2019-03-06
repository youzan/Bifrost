//
//  ShopBundle.m
//  Shop
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "ShopBundle.h"

@implementation ShopBundle

+ (NSBundle *)bundle{
    return [self.class bundleWithName:NSStringFromClass(self.class)];
}

@end
