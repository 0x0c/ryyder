//
//  RYYFeedlyAPIGatekeeper.m
//  ryyder
//
//  Created by Akira Matsuda on 10/7/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYFeedlyAPIGatekeeper.h"
#import "M2DNSURLConnectionExtension.h"
#import "M2DNSURLConnectionExtensionConstant.h"

static NSString *const FeedlyAPIAuthURL = @"/v3/auth/auth";
static NSString *const FeedlyAPITokenURL = @"/v3/auth/token";
static NSString *const FeedlyAPIProfile = @"/v3/profile";
static NSString *const FeedlyAPIEntries = @"/v3/entries/";
static NSString *const FeedlyAPIMarks = @"/v3/markers/counts";
static NSString *const FeedlyAPICategory = @"/v3/categories";
static NSString *const FeedlyAPISubscriptions = @"/v3/subscriptions";
static NSString *const FeedlyAPIOPML = @"/v3/opml";

@interface RYYFeedlyAPIBuilder : NSObject

+ (NSURL *)buildAPIWithString:(NSString *)url;
+ (NSURL *)buildAPIWithString:(NSString *)url sandbox:(BOOL)mode;

@end

@implementation RYYFeedlyAPIBuilder

static NSString *const kBaseURL = @"https://cloud.feedly.com";
static NSString *const kSandboxURL = @"https://sandbox.feedly.com";

+ (NSURL *)buildAPIWithString:(NSString *)url
{
	return [[self class] buildAPIWithString:url sandbox:NO];
}

+ (NSURL *)buildAPIWithString:(NSString *)url sandbox:(BOOL)mode
{
	NSString *baseURL = kBaseURL;
	if (mode) {
		baseURL = kSandboxURL;
	}
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", baseURL, url]];
}

@end

@implementation RYYFeedlyAPIGatekeeper

static RYYFeedlyAPIGatekeeper *sharedGatekeeper;

+ (instancetype)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedGatekeeper = [[[self class] alloc] init];
	});
	
	return sharedGatekeeper;
}

- (void)sendRequestWithMethod:(NSString *)httpMethod url:(NSURL *)url params:(NSDictionary *)params completionHandler:(void (^)(NSURLResponse *response, NSData *responseData, NSError *error))handler
{
	if (self.account) {
		[NXOAuth2Request performMethod:httpMethod onResource:url usingParameters:params withAccount:self.account sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
		} responseHandler:handler];
	}
	else {
		handler(nil, nil, [NSError errorWithDomain:@"No account" code:-1 userInfo:nil]);
	}
}

- (void)getProfile:(void (^)(id result, NSError *error))completionHandler
{
	[self sendRequestWithMethod:M2DHTTPMethodGET url:[RYYFeedlyAPIBuilder buildAPIWithString:FeedlyAPIProfile sandbox:self.sandboxMode] params:nil completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
		completionHandler(responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil] : nil, error);
	}];
}

- (void)getMarks:(void (^)(id result, NSError *error))completionHandler
{
	[self sendRequestWithMethod:M2DHTTPMethodGET url:[RYYFeedlyAPIBuilder buildAPIWithString:FeedlyAPIMarks sandbox:self.sandboxMode] params:nil completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
		completionHandler(responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil] : nil, error);
	}];
}

- (void)getSubscriptions:(void (^)(id result, NSError *error))completionHandler
{
	[self sendRequestWithMethod:M2DHTTPMethodGET url:[RYYFeedlyAPIBuilder buildAPIWithString:FeedlyAPISubscriptions sandbox:self.sandboxMode] params:nil completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
		completionHandler(responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil] : nil, error);
	}];
}

- (void)getEntry:(NSString *)identifer completionHandler:(void (^)(id result, NSError *error))completionHandler
{
	[self sendRequestWithMethod:M2DHTTPMethodGET url:[RYYFeedlyAPIBuilder buildAPIWithString:	FeedlyAPIEntries sandbox:self.sandboxMode] params:@{@"entryId":identifer} completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
		completionHandler(responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil] : nil, error);
	}];
}

- (void)getCategory:(void (^)(id result, NSError *error))completionHandler
{
	[self sendRequestWithMethod:M2DHTTPMethodGET url:[RYYFeedlyAPIBuilder buildAPIWithString:FeedlyAPICategory sandbox:self.sandboxMode] params:nil completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
		completionHandler(responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil] : nil, error);
	}];
}

- (void)postOPML:(NSData *)opmlData completionHandler:(void (^)(id result, NSError *error))completionHandler
{
	NXOAuth2Request *req = [[NXOAuth2Request alloc] initWithResource:[RYYFeedlyAPIBuilder buildAPIWithString:FeedlyAPIOPML sandbox:self.sandboxMode] method:M2DHTTPMethodPOST parameters:@{}];
	req.account = self.account;
	NSMutableURLRequest *signedRequest = [[req signedURLRequest] mutableCopy];
	[signedRequest setHTTPMethod:M2DHTTPMethodPOST];
	NSMutableData *data = [NSMutableData new];
	[data appendData:[[NSString stringWithFormat:@"--%@\r\n", @"aanjgsenajkfr"] dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; filename=\"%@\"\r\n", @""] dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", @"text/xml"] dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:data];
	[data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[[NSString stringWithFormat:@"--%@\r\n", @"njgsenajkfr"] dataUsingEncoding:NSUTF8StringEncoding]];
	NSString *header = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", @"njgsenajkfr"];
	[signedRequest addValue:header forHTTPHeaderField:@"Content-Type"];
	[signedRequest setHTTPBody:data];
	[NSURLConnection sendAsynchronousRequest:signedRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		completionHandler(data ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] : nil, connectionError);
	}];
}

@end
