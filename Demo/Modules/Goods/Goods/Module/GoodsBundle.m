//
//  GoodsBundle.m
//  Goods
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "GoodsBundle.h"

@implementation GoodsBundle

+ (NSBundle *)bundle{
    return [self.class bundleWithName:NSStringFromClass(self.class)];
}

@end
