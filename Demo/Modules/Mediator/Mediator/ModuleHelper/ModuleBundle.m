//
//  ModuleBundle.m
//  Common
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "ModuleBundle.h"

@implementation ModuleBundle

+ (NSBundle *)bundleWithName:(NSString *)bundleName {
    if(bundleName.length == 0) {
        return nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSAssert([NSBundle bundleWithPath:path], @"not found bundle");
    return  [NSBundle bundleWithPath:path];
}

+ (NSBundle *)bundle {
//    NSAssert([NSBundle mainBundle], @"not found bundle");
    return [NSBundle mainBundle];
}

+ (UIView *)viewWithXibFileName:(NSString *)fileName {
    NSAssert([self viewWithXibFileName:fileName inBundle:[self.class bundle]], @"not found view");
    return [self viewWithXibFileName:fileName inBundle:[self.class bundle]];
}

+ (UIImage *)imageNamed:(NSString *)imageName {
    NSAssert([self imageNamed:imageName inBundle:[self.class bundle]], @"not found image");
    return [self imageNamed:imageName inBundle:[self.class bundle]];
}

+ (UIStoryboard *)storyboardWithName:(NSString *)storyboardName {
    NSAssert([self storyboardWithName:storyboardName inBundle:[self.class bundle]], @"not found storyboard");
    return [self storyboardWithName:storyboardName inBundle:[self.class bundle]];
}

+ (UINib *)nibWithName:(NSString *)nibName {
    NSAssert([self nibWithNibName:nibName inBundle:[self.class bundle]], @"not found nib");
    return [self nibWithNibName:nibName inBundle:[self.class bundle]];
}

#pragma mark - private
+ (UIImage *)imageNamed:(NSString *)imageName inBundle:(NSBundle *)bundle {
    if(imageName.length == 0 || !bundle) {
        return nil;
    }
    return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
}

+ (UIImage *)imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName {
    return [self imageNamed:imageName inBundle:[self bundleWithName:bundleName]];
}

+ (UIView *)viewWithXibFileName:(NSString *)fileName inBundle:(NSBundle *)bundle {
    if(fileName.length == 0 || !bundle) {
        return nil;
    }
    //如果没有国际化，则直接去相应内容下的文件
    UIView *xibView = [[bundle loadNibNamed:fileName owner:nil options:nil] lastObject];
    if(!xibView) {
        //文件国际化之后，所有的bundle的文件资源都在base的目录下
        xibView = [[[NSBundle bundleWithPath:[bundle pathForResource:@"Base" ofType:@"lproj"]] loadNibNamed:fileName owner:nil options:nil] lastObject];
    }
    return xibView;
}

+ (UIView *)viewWithXibFileName:(NSString *)fileName bundleName:(NSString *)bundleName {
    return [self viewWithXibFileName:fileName inBundle:[self bundleWithName:bundleName]];
}

+ (UIStoryboard *)storyboardWithName:(NSString *)storyboardName inBundle:(NSBundle *)bundle {
    if(storyboardName.length == 0 || !bundle) {
        return nil;
    }
    return [UIStoryboard storyboardWithName:storyboardName bundle:bundle];
}

+ (UIStoryboard *)storyboardWithName:(NSString *)storyboardName bundleName:(NSString *)bundleName {
    return [self storyboardWithName:storyboardName inBundle:[self bundleWithName:bundleName]];
}

+ (UINib *)nibWithNibName:(NSString *)nibName inBundle:(NSBundle *)bundle {
    if(nibName.length == 0 || !bundle ) {
        return nil;
    }
    return [UINib nibWithNibName:nibName bundle:bundle];
}


@end
