//
//  Bifrost.m
//  Bifrost
//
//  Created by yangke on 2017/9/15.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "Bifrost.h"
#import <objc/message.h>
#import <objc/runtime.h>

#define BFLog(msg) NSLog(@"[Bifrost] %@", (msg))
#define BFInstance [Bifrost sharedInstance]

NSExceptionName BifrostExceptionName = @"BifrostExceptionName";
NSString * const kBifrostExceptionCode = @"BifrostExceptionCode";
NSString * const kBifrostExceptionURLStr = @"kBifrostExceptionURLStr";
NSString * const kBifrostExceptionURLParams = @"kBifrostExceptionURLParams";
NSString * const kBifrostExceptionServiceProtocolStr = @"kBifrostExceptionServiceProtocolStr";
NSString * const kBifrostExceptionModuleClassStr = @"kBifrostExceptionModuleClassStr";
NSString * const kBifrostExceptionAPIStr = @"kBifrostExceptionAPIStr";
NSString * const kBifrostExceptionAPIArguments = @"kBifrostExceptionAPIArguments";

@implementation NSException (Bifrost)
- (BifrostExceptionCode)bf_exceptionCode {
    return [self.userInfo[kBifrostExceptionCode] integerValue];
}
@end

@interface NSObject (Bifrost)
- (void)bf_doesNotRecognizeSelector:(SEL)aSelector;
@end

@interface Bifrost() {
    
}
@property (nonatomic, copy) BifrostExceptionHandler _Nullable exceptionHandler;
@property (nonatomic, strong) NSMutableDictionary *moduleDict; // <moduleName, moduleClass>
@property (nonatomic, strong) NSMutableDictionary *moduleInvokeDict;
+ (instancetype _Nonnull )sharedInstance;
@end

@implementation Bifrost

+ (instancetype _Nonnull )sharedInstance
{
    static Bifrost *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.moduleDict = [NSMutableDictionary dictionary];
        instance.moduleInvokeDict = [NSMutableDictionary dictionary];
    });
    return instance;
}

+ (void)setExceptionHandler:(BifrostExceptionHandler _Nullable )handler {
    BFInstance.exceptionHandler = handler;
}

+ (BifrostExceptionHandler _Nullable )getExceptionHandler {
    return BFInstance.exceptionHandler;
}

+ (void)registerService:(Protocol*_Nonnull)serviceProtocol
             withModule:(Class<BifrostModuleProtocol> _Nonnull)moduleClass {
    NSString *protocolStr = NSStringFromProtocol(serviceProtocol);
    NSString *moduleStr = NSStringFromClass(moduleClass);
    Class class = moduleClass; // to avoid warning
    NSString *exReason = nil;
    if (protocolStr.length == 0) {
        exReason =  BFStr(@"Needs a valid protocol for module %@", moduleStr);
    } else if (moduleStr.length == 0) {
        exReason =  BFStr(@"Needs a valid module for protocol %@", protocolStr);
    } else if (![class conformsToProtocol:serviceProtocol]) {
        exReason =  BFStr(@"Module %@ should confirm to protocol %@", moduleStr, protocolStr);
    } else {
        [self hackUnrecognizedSelecotorExceptionForModule:moduleClass];
        [BFInstance.moduleDict setObject:moduleClass forKey:protocolStr];
    }
    if (exReason.length > 0)  {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:@(BFExceptionFailedToRegisterModule) forKey:kBifrostExceptionCode];
        [userInfo setValue:protocolStr forKey:kBifrostExceptionServiceProtocolStr];
        NSException *exception = [[NSException alloc] initWithName:BifrostExceptionName
                                                            reason:exReason
                                                          userInfo:userInfo];
        BifrostExceptionHandler handler = [self getExceptionHandler];
        if (handler) {
            handler(exception);
        }
        BFLog(exReason);
    }
}

+ (void)unregisterService:(Protocol*_Nonnull)serviceProtocol {
    NSString *str = NSStringFromProtocol(serviceProtocol);
    if (str.length > 0) {
        [BFInstance.moduleDict removeObjectForKey:str];
    } else {
        BFLog(@"Failed to unregister service, protocol is empty");
    }
}

+ (NSArray<Class<BifrostModuleProtocol>>*_Nonnull)allRegisteredModules {
    NSArray *modules = BFInstance.moduleDict.allValues;
    NSArray *sortedModules = [modules sortedArrayUsingComparator:^NSComparisonResult(Class class1, Class class2) {
        NSUInteger priority1 = BifrostModuleDefaultPriority;
        NSUInteger priority2 = BifrostModuleDefaultPriority;
        if ([class1 respondsToSelector:@selector(priority)]) {
            priority1 = [class1 priority];
        }
        if ([class2 respondsToSelector:@selector(priority)]) {
            priority2 = [class2 priority];
        }
        if(priority1 == priority2) {
            return NSOrderedSame;
        } else if(priority1 < priority2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    return sortedModules;
}

+ (void)setupAllModules {
    NSArray *modules = [self allRegisteredModules];
    for (Class<BifrostModuleProtocol> moduleClass in modules) {
        @try {
            BOOL setupSync = NO;
            if ([moduleClass respondsToSelector:@selector(setupModuleSynchronously)]) {
                setupSync = [moduleClass setupModuleSynchronously];
            }
            if (setupSync) {
                [[moduleClass sharedInstance] setup];
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[moduleClass sharedInstance] setup];
                });
            }
        } @catch (NSException *exception) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
            [userInfo setValue:@(BFExceptionFailedToSetupModule) forKey:kBifrostExceptionCode];
            [userInfo setValue:NSStringFromClass(moduleClass) forKey:kBifrostExceptionModuleClassStr];
            NSException *ex = [[NSException alloc] initWithName:exception.name
                                                         reason:exception.reason
                                                       userInfo:userInfo];
            BifrostExceptionHandler handler = [self getExceptionHandler];
            if (handler) {
                 handler(ex);
            }
            BFLog(exception.reason);
        }
    }
}

+ (id<BifrostModuleProtocol> _Nullable)moduleByService:(Protocol*_Nonnull)serviceProtocol {
    NSString *protocolStr = NSStringFromProtocol(serviceProtocol);
    NSString *exReason = nil;
    NSException *exception = nil;
    if (protocolStr.length == 0) {
        exReason = BFStr(@"Invalid service protocol");
    } else {
        Class class = BFInstance.moduleDict[protocolStr];
        NSString *classStr = NSStringFromClass(class);
        if (!class) {
            exReason = BFStr(@"Failed to find module by protocol %@", protocolStr);
        } else if (![class conformsToProtocol:@protocol(BifrostModuleProtocol)]) {
            exReason = BFStr(@"Found %@ by protocol %@, but the module doesn't confirm to protocol BifrostModuleProtocol",
                            classStr, protocolStr);
        } else {
            @try {
                id instance = [class sharedInstance];
                return instance;
            } @catch (NSException *ex) {
                exception = ex;
            }
        }
    }
    if (exReason.length > 0) {
        NSExceptionName name = BifrostExceptionName;
        NSMutableDictionary *userInfo = nil;
        if (exception != nil) {
            userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
            name = exception.name;
        } else {
            userInfo = [NSMutableDictionary dictionary];
        }
        [userInfo setValue:@(BFExceptionFailedToFindModuleByService) forKey:kBifrostExceptionCode];
        [userInfo setValue:NSStringFromProtocol(serviceProtocol) forKey:kBifrostExceptionServiceProtocolStr];
        NSException *ex = [[NSException alloc] initWithName:name
                                                            reason:exReason
                                                          userInfo:userInfo];
        BifrostExceptionHandler handler = [self getExceptionHandler];
        if (handler) {
            handler(ex);
        }
        BFLog(exReason);
        return nil;
    }
    
}

+ (BOOL)checkAllModulesWithSelector:(SEL)selector arguments:(NSArray*)arguments {
    BOOL result = NO;
    NSArray *modules = [self allRegisteredModules];
    for (Class<BifrostModuleProtocol> class in modules) {
        id<BifrostModuleProtocol> moduleItem = [class sharedInstance];
        if ([moduleItem respondsToSelector:selector]) {
            
            __block BOOL shouldInvoke = YES;
            if (![BFInstance.moduleInvokeDict objectForKey:NSStringFromClass([moduleItem class])]) {
                // 如果 modules 里面有 moduleItem 的子类，不 invoke target
                [modules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([NSStringFromClass([obj superclass]) isEqualToString:NSStringFromClass([moduleItem class])]) {
                        shouldInvoke = NO;
                        *stop = YES;
                    }
                }];
            }
            
            if (shouldInvoke) {
                if (![BFInstance.moduleInvokeDict objectForKey:NSStringFromClass([moduleItem class])]) { //cache it
                    [BFInstance.moduleInvokeDict setObject:moduleItem forKey:NSStringFromClass([moduleItem class])];
                }
                
                BOOL ret = NO;
                [self invokeTarget:moduleItem action:selector arguments:arguments returnValue:&ret];
                if (!result) {
                    result = ret;
                }
            }
        }
    }
    return result;
}


+ (BOOL)invokeTarget:(id)target
              action:(_Nonnull SEL)selector
           arguments:(NSArray* _Nullable )arguments
         returnValue:(void* _Nullable)result; {
    if (target && [target respondsToSelector:selector]) {
        NSMethodSignature *sig = [target methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:target];
        [invocation setSelector:selector];
        for (NSUInteger i = 0; i<[arguments count]; i++) {
            NSUInteger argIndex = i+2;
            id argument = arguments[i];
            if ([argument isKindOfClass:NSNumber.class]) {
                //convert number object to basic num type if needs
                BOOL shouldContinue = NO;
                NSNumber *num = (NSNumber*)argument;
                const char *type = [sig getArgumentTypeAtIndex:argIndex];
                if (strcmp(type, @encode(BOOL)) == 0) {
                    BOOL rawNum = [num boolValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if (strcmp(type, @encode(int)) == 0
                           || strcmp(type, @encode(short)) == 0
                           || strcmp(type, @encode(long)) == 0) {
                    NSInteger rawNum = [num integerValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if(strcmp(type, @encode(long long)) == 0) {
                    long long rawNum = [num longLongValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if (strcmp(type, @encode(unsigned int)) == 0
                           || strcmp(type, @encode(unsigned short)) == 0
                           || strcmp(type, @encode(unsigned long)) == 0) {
                    NSUInteger rawNum = [num unsignedIntegerValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if(strcmp(type, @encode(unsigned long long)) == 0) {
                    unsigned long long rawNum = [num unsignedLongLongValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if (strcmp(type, @encode(float)) == 0) {
                    float rawNum = [num floatValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                } else if (strcmp(type, @encode(double)) == 0) { // double
                    double rawNum = [num doubleValue];
                    [invocation setArgument:&rawNum atIndex:argIndex];
                    shouldContinue = YES;
                }
                if (shouldContinue) {
                    continue;
                }
            }
            if ([argument isKindOfClass:[NSNull class]]) {
                argument = nil;
            }
            [invocation setArgument:&argument atIndex:argIndex];
        }
        [invocation invoke];
        NSString *methodReturnType = [NSString stringWithUTF8String:sig.methodReturnType];
        if (result && ![methodReturnType isEqualToString:@"v"]) { //if return type is not void
            if([methodReturnType isEqualToString:@"@"]) { //if it's kind of NSObject
                CFTypeRef cfResult = nil;
                [invocation getReturnValue:&cfResult]; //this operation won't retain the result
                if (cfResult) {
                    CFRetain(cfResult); //we need to retain it manually
                    *(void**)result = (__bridge_retained void *)((__bridge_transfer id)cfResult);
                }
            } else {
                [invocation getReturnValue:result];
            }
        }
        return YES;
    }
    return NO;
}

+ (void)hackUnrecognizedSelecotorExceptionForModule:(Class)class {
    SEL originSEL = @selector(doesNotRecognizeSelector:);
    SEL newSEL = @selector(bf_doesNotRecognizeSelector:);
    [self swizzleOrginSEL:originSEL withNewSEL:newSEL inClass:class];
}

+ (void)swizzleOrginSEL:(SEL)originSEL withNewSEL:(SEL)newSEL inClass:(Class)class {
    Method origMethod = class_getInstanceMethod(class, originSEL);
    Method overrideMethod = class_getInstanceMethod(class, newSEL);
    if (class_addMethod(class, originSEL, method_getImplementation(overrideMethod),
                        method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(class, newSEL, method_getImplementation(origMethod),
                            method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}

@end

@implementation NSObject (Bifrost)

- (void)bf_doesNotRecognizeSelector:(SEL)aSelector {
    @try {
        [self bf_doesNotRecognizeSelector:aSelector];
    } @catch (NSException *ex) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:@(BFExceptionAPINotFoundException) forKey:kBifrostExceptionCode];
        NSException *exception = [[NSException alloc] initWithName:ex.name
                                                            reason:ex.reason
                                                          userInfo:userInfo];
        if (BFInstance.exceptionHandler) {
            BFInstance.exceptionHandler(exception);
        } else {
#ifdef DEBUG
            @throw exception;
#endif
        }
    } @finally {
    }
}

@end
