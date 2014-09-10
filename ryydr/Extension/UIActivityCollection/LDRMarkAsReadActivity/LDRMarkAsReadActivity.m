//
//  LDRMarkAsReadActivity.m
//  ryyder
//
//  Created by Akira Matsuda on 8/21/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "LDRMarkAsReadActivity.h"
#import "FAKFontAwesome.h"

@implementation LDRMarkAsReadActivity

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
	return @"com.akira.matsuda.activity.ldr.mark";
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
	return [[FAKFontAwesome checkCircleOIconWithSize:size] imageWithSize:CGSizeMake(size, size)];
}

- (NSString *)activityTitle
{
	return @"Mark as read";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	self.article.read = YES;
}

@end
