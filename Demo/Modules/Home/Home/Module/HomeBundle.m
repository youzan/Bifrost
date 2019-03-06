//
//  HomeBundle.m
//  Home
//
//  Created by yangke on 2017/9/16.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "HomeBundle.h"

@implementation HomeBundle

+ (NSBundle *)bundle{
    return [self.class bundleWithName:NSStringFromClass(self.class)];
}

@end
