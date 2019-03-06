//
//  Bifrost+Router.m
//  Bifrost
//
//  Created by yangke on 2017/9/15.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "Bifrost+Router.h"

#define BFLog(msg) NSLog(@"[Bifrost] %@", (msg))
#define BFKey(URL) [Bifrost keyForURL:URL]

NSString *const kBifrostRouteURL = @"kBifrostRouteURL";
NSString *const kBifrostRouteCompletion = @"kBifrostRouteCompletion";

@implementation Bifrost (Router)

+ (nonnull NSString*)keyForURL:(nonnull NSString*)urlStr {
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSString *key = [NSString stringWithFormat:@"%@%@", URL.host, URL.path];
    return key;
}

+ (nullable NSDictionary*)parametersInURL:(nonnull NSString*)urlStr {
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSMutableDictionary *params = nil;
    NSString *query = URL.query;
    if(query.length > 0) {
        params = [NSMutableDictionary dictionary];
        NSArray *list = [query componentsSeparatedByString:@"&"];
        for (NSString *param in list) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            NSString *decodedStr = [[elts lastObject] stringByRemovingPercentEncoding];
            [params setObject:decodedStr forKey:[elts firstObject]];
        }
    }
    return params;
}

+ (NSMutableDictionary*)routes {
    @synchronized (self) {
        static NSMutableDictionary *_routes = nil;
        if (!_routes) {
            _routes = [NSMutableDictionary dictionary];
        }
        return _routes;
    }
}

+ (void)bindURL:(nonnull NSString *)urlStr toHandler:(nonnull BifrostRouteHandler)handler {
    [self.routes setObject:handler forKey:BFKey(urlStr)];
}

+ (void)unbindURL:(nonnull NSString *)urlStr {
    [self.routes removeObjectForKey:BFKey(urlStr)];
}

+ (void)unbindAllURLs {
    [self.routes removeAllObjects];
}

+ (nullable BifrostRouteHandler)handlerForURL:(nonnull NSString *)urlStr {
    return [self.routes objectForKey:BFKey(urlStr)];
}

+ (BOOL)canHandleURL:(nonnull NSString *)urlStr {
    if (urlStr.length == 0) {
        return NO;
    }
    if ([self handlerForURL:urlStr]) {
        return YES;
    } else {
        return NO;
    }
}

+ (nullable id)handleURL:(nonnull NSString *)urlStr {
    return [self handleURL:urlStr complexParams:nil completion:nil];
}

+ (nullable id)handleURL:(nonnull NSString *)urlStr
              completion:(nullable BifrostRouteCompletion)completion {
    return [self handleURL:urlStr complexParams:nil completion:completion];
}

+ (nullable id)handleURL:(nonnull NSString *)urlStr
           complexParams:(nullable NSDictionary*)complexParams
              completion:(nullable BifrostRouteCompletion)completion {
    id obj = nil;
    @try {
        BifrostRouteHandler handler = [self handlerForURL:urlStr];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:complexParams];
        [params addEntriesFromDictionary:[self.class parametersInURL:urlStr]];
        [params setObject:urlStr forKey:kBifrostRouteURL];
        if (completion) {
            [params setObject:completion forKey:kBifrostRouteCompletion];
        }
        if (!handler) {
            NSString *reason = [NSString stringWithFormat:@"Cannot find handler for route url %@", urlStr];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:@(BFExceptionUrlHandlerNotFound) forKey:kBifrostExceptionCode];
            [userInfo setValue:urlStr forKey:kBifrostExceptionURLStr];
            [userInfo setValue:params forKey:kBifrostExceptionURLParams];
            NSException *exception = [[NSException alloc] initWithName:BifrostExceptionName
                                                                reason:reason
                                                              userInfo:userInfo];
            BifrostExceptionHandler handler = [self getExceptionHandler];
            if (handler) {
                obj = handler(exception);
            }
            BFLog(reason);
        } else {
            obj = handler(params);
        }
    } @catch (NSException *exception) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
        [userInfo setValue:@(BFExceptionDefaultCode) forKey:kBifrostExceptionCode];
        [userInfo setValue:urlStr forKey:kBifrostExceptionURLStr];
        [userInfo setValue:complexParams forKey:kBifrostExceptionURLParams];
        NSException *ex = [[NSException alloc] initWithName:exception.name
                                                     reason:exception.reason
                                                   userInfo:userInfo];
        BifrostExceptionHandler handler = [self getExceptionHandler];
        if (handler) {
            obj = handler(ex);
        }
        BFLog(exception.reason);
    } @finally {
        return obj;
    }
}

+ (void)completeWithParameters:(nullable NSDictionary*)params result:(_Nullable id)result {
    BifrostRouteCompletion completion = params[kBifrostRouteCompletion];
    if (completion) {
        completion(result);
    }
}

@end
