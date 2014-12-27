//
//  RYYFeedlyAPIGatekeeper.h
//  ryyder
//
//  Created by Akira Matsuda on 10/7/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOAuth2.h"

@interface RYYFeedlyAPIGatekeeper : NSObject

@property (nonatomic, assign) BOOL sandboxMode;
@property (nonatomic, strong) NXOAuth2Account *account;

+ (instancetype)sharedInstance;
- (void)getProfile:(void (^)(id result, NSError *error))completionHandler;
- (void)getMarks:(void (^)(id result, NSError *error))completionHandler;
- (void)getSubscriptions:(void (^)(id result, NSError *error))completionHandler;
- (void)getEntry:(NSString *)identifer completionHandler:(void (^)(id result, NSError *error))completionHandler;
- (void)getCategory:(void (^)(id result, NSError *error))completionHandler;
- (void)postOPML:(NSData *)opmlData completionHandler:(void (^)(id result, NSError *error))completionHandler;

@end
