//
//  InstapaperActivity.m
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/02.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import "InstapaperActivity.h"

@implementation InstapaperActivity

- (NSString *)activityType
{
    return @"com.uiactivity.instapaper";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"InstapaperActivity.png"];
}

- (NSString *)activityTitle
{
    return @"Instapaper";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	[super prepareWithActivityItems:activityItems];
	
	for (id obj in activityItems) {
		if ([obj isKindOfClass:[NSURL class]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"i%@", [(NSURL *)obj absoluteString]]]];
			break;
		}
	}
}

+ (BOOL)canPerformActivity
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ihttp://"]];
}

@end
