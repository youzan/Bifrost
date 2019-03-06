//
//  SaleBundle.m
//  SaleModule
//
//  Created by youzan on 2017/2/28.
//  Copyright (c) 2017年 youzan. All rights reserved.
//

#import "SaleBundle.h"

@implementation SaleBundle

+ (NSBundle *)bundle{
    return [self.class bundleWithName:NSStringFromClass(self.class)];
}

@end
