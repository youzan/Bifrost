//
//  ModuleBundle.h
//  Common
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ModuleBundle : NSObject

/*
 * 根据bundle的名称获取bundle
 */
+ (NSBundle *)bundleWithName:(NSString *)bundleName;

//获取bundle 每次只要重写这个方法就可以在指定的bundle中获取对应资源
+ (NSBundle *)bundle;

//根据xib文件名称获取xib文件
+ (__kindof UIView *)viewWithXibFileName:(NSString *)fileName;

//根据图片名称获取图片
+ (UIImage *)imageNamed:(NSString *)imageName;

//根据sb文件名称获取对应sb文件
+ (UIStoryboard *)storyboardWithName:(NSString *)storyboardName;

//获取nib文件
+ (UINib *)nibWithName:(NSString *)nibName;

@end
