//
//  TemplateModule.m
//  TemplateModule
//
//  Created by youzan on 2017/2/28.
//  Copyright (c) 2017年 youzan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TemplateModule.h"

@interface TemplateModule()

@end

@implementation TemplateModule

+ (void)load {
//如果只使用TemplateModule，而没有相应的phoneModule或者padModule的话，需要在基类里注册模块，需要把下面的注释放开，否则因为phoneModule或者padModule已经注册了模块，所以基类无须再注册
//    BFRegister(TemplateModuleService);
}

#pragma mark - BifrostModuleProtocol methods

+ (instancetype)sharedInstance {
    static TemplateModule *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setup {
    
}

#pragma mark - TemplateModuleService


@end
