//
//  Bifrost.h
//  Bifrost
//
//  Created by yangke on 2017/9/15.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BifrostProtocol.h"

#define BFRegister(service_protocol) [Bifrost registerService:@protocol(service_protocol) withModule:self.class];
#define BFModule(service_protocol) ((id<service_protocol>)[Bifrost moduleByService:@protocol(service_protocol)])
#define BFStr(fmt, ...) [NSString stringWithFormat:fmt, ##__VA_ARGS__]

typedef NS_ENUM(NSInteger, BifrostExceptionCode)
{
    BFExceptionDefaultCode = -20001,
    BFExceptionUrlHandlerNotFound = -20002,
    BFExceptionModuleNotFoundException = -20003,
    BFExceptionAPINotFoundException = -20004,
    BFExceptionFailedToRegisterModule = -20005,
    BFExceptionFailedToSetupModule = -20006,
    BFExceptionFailedToFindModuleByService = -20007,

};
// BifrostException exception name
extern NSExceptionName _Nonnull BifrostExceptionName;
// Bifrost Exception userInfo keys
extern NSString *const _Nonnull kBifrostExceptionCode;
extern NSString *const _Nonnull kBifrostExceptionURLStr;
extern NSString *const _Nonnull kBifrostExceptionURLParams;
extern NSString *const _Nonnull kBifrostExceptionServiceProtocolStr;
extern NSString *const _Nonnull kBifrostExceptionModuleClassStr;
extern NSString *const _Nonnull kBifrostExceptionAPIStr;
extern NSString *const _Nonnull kBifrostExceptionAPIArguments;

@interface NSException (Bifrost)
- (BifrostExceptionCode)bf_exceptionCode;
@end

/**
 The handler for exceptions, like url not found, api not support, ...

 @param exception exceptions when handling route URLs or module APIs
 @return The substitute return object
 */
typedef _Nullable id (^BifrostExceptionHandler)(NSException * _Nonnull exception);

@interface Bifrost : NSObject

/**
 Method to set exception handler

 @param handler the handler block
 */
+ (void)setExceptionHandler:(BifrostExceptionHandler _Nullable )handler;

+ (BifrostExceptionHandler _Nullable )getExceptionHandler;

/**
 Method to register the module srevice with module class.
 Each Module do the registeration before app launch event, like in the +load method.

 @param serviceProtocol the protocol for the module's service
 @param moduleClass The class of the module
 */
+ (void)registerService:(Protocol*_Nonnull)serviceProtocol
             withModule:(Class<BifrostModuleProtocol> _Nonnull)moduleClass;

/**
 Method to unregister service

 @param serviceProtocol the protocol for the module's service
 */
+ (void)unregisterService:(Protocol*_Nonnull)serviceProtocol;

/**
 Method to setup all registered modules.
 It's recommended to invoke this method in AppDelegate's willFinishLaunchingWithOptions method.
 */
+ (void)setupAllModules;

/**
 Get module instance by service protocol. 
 It's recomended to use macro BFModule for convenient

 @param serviceProtocol the service protocol used to register the module
 @return module instance
 */
+ (id<BifrostModuleProtocol> _Nullable)moduleByService:(Protocol*_Nonnull)serviceProtocol;

//+ (NSArray<Protocol*>*_Nonnull)allRegisteredServices;
//

/**
 Method to get all registered module classes, sorted by module priority.

 @return module class array, not module instances
 */
+ (NSArray<Class<BifrostModuleProtocol>>*_Nonnull)allRegisteredModules;

/**
 Method to enumarate all modules for methods in UIApplicationDelegate.
 
 @param selector app delegate selector
 @param arguments argument array
 @return the return value of the method implementation in those modules
 */
+ (BOOL)checkAllModulesWithSelector:(nonnull SEL)selector
                          arguments:(nullable NSArray*)arguments;

@end
