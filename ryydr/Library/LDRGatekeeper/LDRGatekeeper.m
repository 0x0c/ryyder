//
//  LDRGatekeeper.m
//  LDRAPIGatekeeper
//
//  Created by Akira Matsuda on 8/18/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "LDRGatekeeper.h"
#import "UICKeyChainStore.h"
#import "M2DAPIGatekeeper.h"
#import "M2DNSURLConnectionExtension.h"
#import "M2DNSURLConnectionExtensionConstant.h"

#define LDRBaseURL @"http://reader.livedoor.com"

static NSString *const GetMemberIdAPI = @"https://member.livedoor.com/login/";
static NSString *const LoginAPI = @"https://member.livedoor.com/login/index";
static NSString *const LogoutAPI = @"https://member.livedoor.com/logout";

static NSString *const GetAPIKeyAPI = LDRBaseURL@"/reader/";
static NSString *const GetFeedsAPI = LDRBaseURL@"/api/subs";
static NSString *const GetUnreadArticlesAPI = LDRBaseURL@"/api/unread";
static NSString *const GetPinnedArticlesAPI = LDRBaseURL@"/api/pin/all";
static NSString *const TouchArticleAPI = LDRBaseURL@"/api/touch_all";
static NSString *const AddPinnedArticleAPI = LDRBaseURL@"/api/pin/add";
static NSString *const DeletePinnedArticleAPI = LDRBaseURL@"/api/pin/remove";
static NSString *const NotifyAPI = @"http://rpc.reader.livedoor.com/notify";

static NSString *const LDRAPIKey = @"ApiKey";
static NSString *const LDRServiceIdentifier = @"LDRGatekeeper";
static NSString *const LDRUsername = @"Username";
static NSString *const LDRPassword = @"Password";

@interface NSHTTPCookieStorage (Helper)

- (id)m2d_valueForName:(NSString *)name domain:(NSString *)domain;

@end

@implementation NSHTTPCookieStorage (Helper)

- (id)m2d_valueForName:(NSString *)name domain:(NSString *)domain
{
	NSHTTPCookieStorage *storage = self;
	for (NSHTTPCookie *cookie in [storage cookies]) {
		if ([[cookie name] isEqualToString:name] == NO) {
			continue;
		}
		if ([[cookie domain] isEqualToString:domain]) {
			return [cookie value];
		}
	}
	
	return nil;
}

@end

@interface LDRGatekeeper ()

@end

@implementation LDRGatekeeper

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.preparedSubscribeIdentifier = [NSMutableArray new];
		[self parseBlock:^id(NSData *data, NSError *__autoreleasing *error) {
			return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
		}];
		[self resultConditionBlock:^BOOL(M2DAPIRequest *request, NSURLResponse *response, id parsedObject, NSError *__autoreleasing *error) {
			if ([[response.URL path] containsString:@"login"]) {
				return YES;
			}
			return [(NSHTTPURLResponse *)response statusCode] == 200;
		}];
	}
	
	return self;
}

- (void)setUsername:(NSString *)username
{
	[UICKeyChainStore setString:username forKey:LDRUsername service:LDRServiceIdentifier];
}

- (NSString *)username
{
	return 	[UICKeyChainStore stringForKey:LDRUsername service:LDRServiceIdentifier];
}

- (void)setPassword:(NSString *)password
{
	[UICKeyChainStore setString:password forKey:LDRPassword service:LDRServiceIdentifier];
}

- (NSString *)password
{
	return [UICKeyChainStore stringForKey:LDRPassword service:LDRServiceIdentifier];
}

- (void)clearAccountInfo
{
	[UICKeyChainStore removeItemForKey:LDRUsername service:LDRServiceIdentifier];
	[UICKeyChainStore removeItemForKey:LDRPassword service:LDRServiceIdentifier];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password competionHandler:(void (^)(NSError *error))handler
{
	[self setUsername:username];
	[self setPassword:password];
	__weak typeof(self) bself = self;
	M2DAPIRequest *r = [[M2DAPIRequest POSTRequest:[NSURL URLWithString:LoginAPI]] parametors:@{@"livedoor_id":username,@"password":password}];
	
	[[[r whenSucceeded:^(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject) {
		M2DAPIRequest *r2 = [[M2DAPIRequest POSTRequest:[NSURL URLWithString:(NSString *)GetAPIKeyAPI]] parametors:@{}];
		[[r2 whenSucceeded:^(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject) {
			NSHTTPCookieStorage *s = [NSHTTPCookieStorage sharedHTTPCookieStorage];
			NSString *apiKey = [s m2d_valueForName:@"ucd" domain:@".livedoor.com"];
			NSString *ldsuid = [s m2d_valueForName:@"ldsuid" domain:@"member.livedoor.com"];
			NSString *LRC = [s m2d_valueForName:@".LRC" domain:@".livedoor.com"];
			NSString *LH = [s m2d_valueForName:@".LH" domain:@".livedoor.com"];
			NSString *LL = [s m2d_valueForName:@".LL" domain:@".livedoor.com"];
			if (ldsuid && LRC && LH && LL && apiKey) {
				[bself setBaseParameterBlock:^(M2DAPIRequest *r, NSMutableDictionary *param) {
					param[LDRAPIKey] = apiKey;
				}];
				handler(nil);
			}
			else {
				NSError *error = [[NSError alloc] initWithDomain:@"Login failed." code:-1 userInfo:nil];
				handler(error);
			}
		}] asynchronousRequest];
		[self sendRequest:r2];
	}] whenFailed:^(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject, NSError *error) {
		
	}] asynchronousRequest];
	[r setResultConditionBlock:^BOOL(M2DAPIRequest *r, NSURLResponse *response, id parsedObject, NSError *__autoreleasing *e) {
		return YES;
	}];
	[self sendRequest:r];
}

- (void)loginWithCompetionHandler:(void (^)(NSError *error))handler
{
	NSString *username = [UICKeyChainStore stringForKey:LDRUsername service:LDRServiceIdentifier];
	NSString *password = [UICKeyChainStore stringForKey:LDRPassword service:LDRServiceIdentifier];
	if (username && password) {
		[self loginWithUsername:username password:password competionHandler:handler];
	}
	else {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler([NSError errorWithDomain:@"Account infomation validation error" code:-1 userInfo:@{}]);
		});
	}
}

- (void)logout
{
	NSHTTPCookieStorage *s = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (NSHTTPCookie *c in [s cookies]) {
		[s deleteCookie:c];
	}
	NSURLResponse *response = nil;
	NSError *error = nil;
	[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:(NSString *)LogoutAPI]] returningResponse:&response error:&error];
}

- (void)getFeedsWithUnreadArticle:(BOOL)unread completionHandler:(void (^)(id result, NSError *error))completionHandler
{
	M2DAPIRequest *r = [[M2DAPIRequest POSTRequest:[NSURL URLWithString:GetFeedsAPI]] parametors:@{@"unread":@(unread)}];
	[[r whenSucceeded:^(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject) {
		NSMutableArray *array = [NSMutableArray new];
		LDRFeed *p = nil;
		for (NSDictionary *f in parsedObject) {
			LDRFeed *feed = [[LDRFeed alloc] initWithDictionary:f];
			feed.previousFeed = p;
			feed.previousFeed.nextFeed = feed;
			[array addObject:feed];
			p = feed;
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			completionHandler(array, nil);
		});
	}] asynchronousRequest];
	[self sendRequest:r completionHandler:completionHandler];
}

- (void)getUnreadArticlesWithSubsucribeId:(NSString *)subscribeIdentifier completionHandler:(void (^)(id result, NSError *error))completionHandler
{
	M2DAPIRequest *r = [[M2DAPIRequest POSTRequest:[NSURL URLWithString:GetUnreadArticlesAPI]] parametors:@{@"subscribe_id":subscribeIdentifier}];
	[[r whenSucceeded:^(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			LDRArticleData *articles = [LDRArticleData modelObjectWithDictionary:parsedObject];
			completionHandler(articles, nil);
		});
	}] asynchronousRequest];
	[self sendRequest:r completionHandler:completionHandler];
}

- (void)getPinnedArticlesWithCompletionHandler:(void (^)(id result, NSError *error))completionHandler
{
	M2DAPIRequest *r = [[M2DAPIRequest POSTRequest:[NSURL URLWithString:GetPinnedArticlesAPI]] parametors:@{}];
	[[r whenSucceeded:^(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject) {
		NSMutableArray *result = [NSMutableArray new];
		[parsedObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[result addObject:[LDRPinnedArticle modelObjectWithDictionary:obj]];
		}];
		dispatch_async(dispatch_get_main_queue(), ^{
			completionHandler([result copy], nil);
		});
	}] asynchronousRequest];
	[self sendRequest:r completionHandler:completionHandler];
}

- (void)touchAllFeed
{
	M2DAPIRequest *r = [[[M2DAPIRequest POSTRequest:[NSURL URLWithString:TouchArticleAPI]] parametors:@{}] asynchronousRequest];
	[self sendRequest:r completionHandler:^(id result, NSError *error) {
	}];
}

- (void)touchFeedWithSubsucribeIdentifier:(NSString *)subscribeIdentifier
{
	M2DAPIRequest *r = [[[M2DAPIRequest POSTRequest:[NSURL URLWithString:TouchArticleAPI]] parametors:@{@"subscribe_id":subscribeIdentifier}] asynchronousRequest];
	[self sendRequest:r completionHandler:^(id result, NSError *error) {
	}];
}

- (void)touchPreparedFeed
{
	[_preparedSubscribeIdentifier enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self touchFeedWithSubsucribeIdentifier:obj];
	}];
	[_preparedSubscribeIdentifier removeAllObjects];
}

- (void)addPreparedSubscribeIdentifier:(NSString *)subscribeIdentifier
{
	[_preparedSubscribeIdentifier addObject:subscribeIdentifier];
}

- (void)addPinnedArticle:(LDRPinnedArticle *)article completionHandler:(void (^)(NSError *error))handler
{
	M2DAPIRequest *r = [[M2DAPIRequest POSTRequest:[NSURL URLWithString:AddPinnedArticleAPI]] parametors:@{@"title":article.title, @"link":article.link}];
	[[r whenSucceeded:^(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(nil);
		});
	}] asynchronousRequest];
	[self sendRequest:r completionHandler:^(id result, NSError *error) {
		handler(error);
	}];
}

- (void)deletePinnedArticle:(LDRPinnedArticle *)article completionHandler:(void (^)(NSError *error))handler
{
	M2DAPIRequest *r = [[M2DAPIRequest POSTRequest:[NSURL URLWithString:DeletePinnedArticleAPI]] parametors:@{@"link":article.link}];
	[[r whenSucceeded:^(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject) {
		handler(nil);
	}] asynchronousRequest];
	[self sendRequest:r completionHandler:^(id result, NSError *error) {
		handler(error);
	}];
}

- (void)getUnreadCountWithCompletionHandler:(void (^)(NSString *result, NSError *error))handler
{
	NSString *username = [UICKeyChainStore stringForKey:LDRUsername service:LDRServiceIdentifier];
	if (username) {
		M2DAPIRequest *r = [[[M2DAPIRequest POSTRequest:[NSURL URLWithString:NotifyAPI]] parametors:@{@"user":username}] asynchronousRequest];
		[r whenSucceeded:^(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject) {
			handler(parsedObject, nil);
		}];
		[r parseAlgorithm:^id(NSData *data, NSError *__autoreleasing *error) {
			NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			return [result stringByReplacingOccurrencesOfString:@"|" withString:@""];
		}];
		[r setResultConditionBlock:^BOOL(M2DAPIRequest *r, NSURLResponse *response, id parsedObject, NSError *__autoreleasing *e) {
			return [(NSHTTPURLResponse *)response statusCode] == 200;
		}];
		[self sendRequest:r completionHandler:^(id result, NSError *error) {
			handler(result, error);
		}];
	}
}

#pragma mark -

- (void)sendRequest:(M2DAPIRequest *)request completionHandler:(void (^)(id result, NSError *error))completionHandler
{
	[request whenFailed:^(M2DAPIRequest *request, NSDictionary *httpHeaderFields, id parsedObject, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self loginWithCompetionHandler:^(NSError *error) {
			}];
			completionHandler(nil, error);
		});
	}];
	[self sendRequest:request];
}

@end
