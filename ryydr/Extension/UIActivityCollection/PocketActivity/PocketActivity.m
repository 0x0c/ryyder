//
//  PocketActivity.m
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/02.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import "PocketActivity.h"

@interface PocketActivity ()
{
	void (^savedBlocks_)(BOOL completion, PocketAPI *api, NSURL *url, NSError *error);
}

@end

@implementation PocketActivity

- (id)initWithScheme:(NSString *)urlScheme consumerKey:(NSString *)consumerKey
{
	self = [super init];
	if (self) {
		[[PocketAPI sharedAPI] setURLScheme:urlScheme];
		[[PocketAPI sharedAPI] setConsumerKey:consumerKey];
	}
	
	return self;
}

- (void)setSaveURLHanderBlocks:(void (^)(BOOL completion, PocketAPI *api, NSURL *url, NSError *error))savedBlocks
{
	savedBlocks_ = [savedBlocks copy];
}

- (NSString *)activityType
{
    return @"com.uiactivity.pocket";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"PocketActivity.png"];
}

- (NSString *)activityTitle
{
    return @"Pocket";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	[super prepareWithActivityItems:activityItems];

	NSURL *url = nil;
	for (id obj in activityItems) {
		if ([obj isKindOfClass:[NSURL class]]) {
			url = obj;
			break;
		}
	}
	savedBlocks_(NO, [PocketAPI sharedAPI], url, nil);
	[[PocketAPI sharedAPI] saveURL:url handler: ^(PocketAPI *API, NSURL *URL, NSError *error){
		if (savedBlocks_) {
			savedBlocks_(YES, API, URL, error);
		}
	}];
}

- (UIViewController *)activityViewController
{
	return nil;
}

- (void)performActivity
{
	[super activityDidFinish:YES];
	
}

- (void)activityDidFinish:(BOOL)completed
{
	[super activityDidFinish:completed];
}

+ (BOOL)canPerformActivity
{
	return [PocketAPI hasPocketAppInstalled];
}

@end
