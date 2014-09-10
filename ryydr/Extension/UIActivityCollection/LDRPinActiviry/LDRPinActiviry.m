//
//  LDRPinActiviry.m
//  ryyder
//
//  Created by Akira Matsuda on 8/21/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "LDRPinActiviry.h"
#import "FAKFontAwesome.h"

@implementation LDRPinActiviry

+ (UIActivityCategory)activityCategory
{
	return UIActivityCategoryAction;
}

+ (BOOL)canPerformActivity
{
	return YES;
}

+ (NSString *)activityType
{
	return @"com.akira.matsuda.activity.ldr.list";
}

- (NSString *)activityType
{
	return [[self class] activityType];
}

- (UIImage *)activityImage
{
	CGFloat size = 43;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		size = 55;
	}
	return [[FAKFontAwesome dotCircleOIconWithSize:size] imageWithSize:CGSizeMake(size, size)];
}

- (NSString *)activityTitle
{
	return @"Add to list";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	LDRPinnedArticle *article = [LDRPinnedArticle new];
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			article.link = [activityItem absoluteString];
		}
		else if ([activityItem isKindOfClass:[NSString class]]) {
			article.title = activityItem;
		}
		else {
			continue;
		}
	}
	__weak typeof(self) bself = self;
	[self.gatekeeper addPinnedArticle:article completionHandler:^(NSError *error) {
		if (bself.completionHandler) {
			bself.completionHandler(error);
		}
	}];
}

@end
