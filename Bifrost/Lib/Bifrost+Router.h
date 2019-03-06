//
//  Bifrost+Router.h
//  Bifrost
//
//  Created by yangke on 2017/9/15.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "Bifrost.h"

#define BFComplete(Params, Result) [Bifrost completeWithParameters:Params result:Result]

// default keys in the parameters of BifrostRouteHandler
extern NSString * _Nonnull const kBifrostRouteURL; //the key for the raw url
extern NSString * _Nonnull const kBifrostRouteCompletion; //the key for the completion block.

/**
 The handler for a binded url
 
 @param parameters containers above 2 keys and parameters from the query string and complexParams
 @return the obj returned by the handler
 */
typedef _Nullable id (^BifrostRouteHandler)( NSDictionary * _Nullable parameters);

/**
 The completion block to be invoked at the end of the router handler block
 
 @param result completion result. defaultly it is the returned object of the BifrostRouteHandler.
 */
typedef void (^BifrostRouteCompletion)(_Nullable id result);

@interface Bifrost (Router)

/**
 The method to bind a URL to handler
 
 @param urlStr The URL string. Only scheme, host and api path will be used here.
 Its query string will be ignore here.
 @param handler the handler block.
 The BifrostRouteCompletion should be invoked at the end of the block
 */
+ (void)bindURL:(nonnull NSString *)urlStr toHandler:(nonnull BifrostRouteHandler)handler;

/**
 The method to unbind a URL
 
 @param urlStr The URL string. Only scheme, host and api path will be used here.
 Its query string will be ignore here.
 */
+ (void)unbindURL:(nonnull NSString *)urlStr;

/**
 Method to unbind all URLs
 */
+ (void)unbindAllURLs;

/**
 The method to check whether a url can be handled
 
 @param urlStr The URL string. Only scheme, host and api path will be used here.
 Its query string will be ignore here.
 */
+ (BOOL)canHandleURL:(nonnull NSString *)urlStr;

/**
 Method to handle the URL
 
 @param urlStr URL string
 @return the returned object of the url's BifrostRouteHandler
 */
+ (nullable id)handleURL:(nonnull NSString *)urlStr;

/**
 Method to handle the url with completion block
 
 @param urlStr URL string
 @param completion The completion block
 @return the returned object of the url's BifrostRouteHandler
 */
+ (nullable id)handleURL:(nonnull NSString *)urlStr
              completion:(nullable BifrostRouteCompletion)completion;

/**
 The method to handle URL with complex parameters and completion block
 
 @param urlStr URL string
 @param complexParams complex parameters that can't be put in the url query strings
 @param completion The completion block
 @return the returned object of the url's BifrostRouteHandler
 */
+ (nullable id)handleURL:(nonnull NSString *)urlStr
           complexParams:(nullable NSDictionary*)complexParams
              completion:(nullable BifrostRouteCompletion)completion;

/**
 Invoke the completion block in the parameters of BifrostRouteHandler.
 Recommend to use macro BFComplete for convenient.
 
 @param params parameters of BifrostRouteHandler
 @param result the result for the BifrostRouteCompletion
 */
+ (void)completeWithParameters:(nullable NSDictionary*)params result:(_Nullable id)result;

@end
