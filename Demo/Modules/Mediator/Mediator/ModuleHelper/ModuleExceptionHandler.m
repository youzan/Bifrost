//
//  ModuleExceptionHandler.m
//  Common
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "ModuleExceptionHandler.h"
#import "BifrostHeader.h"

@implementation ModuleExceptionHandler

+ (void)load {
    [Bifrost setExceptionHandler:^id _Nullable(NSException * _Nonnull exception) {
        //record the error
        NSLog(@"[Module] Exception:%@", exception);
        //handle excpeitons
        switch (exception.bf_exceptionCode) {
            case BFExceptionUrlHandlerNotFound:
                //you can provide the default error VC for the route url here
//                ErrorViewController *errorVC = [[ErrorViewController alloc] init];
//                return errorVC;
                break;
            case BFExceptionModuleNotFoundException:
                break;
            case BFExceptionAPINotFoundException:
                break;
            case BFExceptionFailedToRegisterModule:
                break;
            default:
                break;
        }
#ifdef DEBUG
        @throw exception; //debug模式下抛出异常crash，以便及时处理问题
#endif
        return nil;
    }];
}

@end
