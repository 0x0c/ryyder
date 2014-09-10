//
//  LDRGatekeeper.h
//  LDRAPIGatekeeper
//
//  Created by Akira Matsuda on 8/18/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M2DAPIGatekeeper.h"
#import "LDRDataModels.h"

@interface LDRGatekeeper : M2DAPIGatekeeper

@property (nonatomic, strong) NSMutableArray *preparedSubscribeIdentifier;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (void)clearAccountInfo;
- (void)loginWithUsername:(NSString *)identifier password:(NSString *)password competionHandler:(void (^)(NSError *error))handler;
- (void)loginWithCompetionHandler:(void (^)(NSError *error))handler;
- (void)logout;
- (void)getFeedsWithUnreadArticle:(BOOL)unread completionHandler:(void (^)(id result, NSError *error))completionHandler;
- (void)getUnreadArticlesWithSubsucribeId:(NSString *)subscribeIdentifier completionHandler:(void (^)(id result, NSError *error))completionHandler;
- (void)getPinnedArticlesWithCompletionHandler:(void (^)(id result, NSError *error))completionHandler;
- (void)touchAllFeed;
- (void)touchFeedWithSubsucribeIdentifier:(NSString *)subscribeIdentifier;
- (void)touchPreparedFeed;
- (void)addPreparedSubscribeIdentifier:(NSString *)subscribeIdentifier;
- (void)addPinnedArticle:(LDRPinnedArticle *)article completionHandler:(void (^)(NSError *error))handler;
- (void)deletePinnedArticle:(LDRPinnedArticle *)article completionHandler:(void (^)(NSError *error))handler;
- (void)getUnreadCountWithCompletionHandler:(void (^)(NSString *result, NSError *error))handler;

@end
