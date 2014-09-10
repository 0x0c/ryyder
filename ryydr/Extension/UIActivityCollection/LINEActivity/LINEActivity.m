//
//  LINEActivity.m
//
//  Created by Noda Shimpei on 2012/12/04.
//  Copyright (c) 2012年 @noda_sin. All rights reserved.
//

#import "LINEActivity.h"

@implementation LINEActivity

+ (UIActivityCategory)activityCategory
{
	return UIActivityCategoryAction;
}

+ (BOOL)canPerformActivity
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]];
}

+ (NSString *)activityType {
    return @"jp.naver.LINEActivity";
}

- (NSString *)activityType {
    return [LINEActivity activityType];
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"LINEActivityIcon.png"];
}

- (NSString *)activityTitle
{
    return @"LINE";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSString class]] || [activityItem isKindOfClass:[UIImage class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
	NSMutableString *text = [NSMutableString new];
    for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			[text appendString:[activityItem absoluteString]];
		}
		else if ([activityItem isKindOfClass:[NSString class]]) {
			[text appendString:activityItem];
		}
		else {
			continue;
		}
    }
	if ([text length]) {
		[self openLINEWithItem:text];
	}
}

- (BOOL)isUsableLINE
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]];
}

- (void)openLINEOnITunes
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/jp/app/line/id443904275?ls=1&mt=8"]];
}

- (BOOL)openLINEWithItem:(id)item
{
    if (![self isUsableLINE]) {
        [self openLINEOnITunes];
        return NO;
    }
    
    NSString *LINEURLString = nil;
    if ([item isKindOfClass:[NSString class]]) {
        LINEURLString = [NSString stringWithFormat:@"line://msg/text/%@", (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)item, NULL, CFSTR (";,/?:@&=+$#"), kCFStringEncodingUTF8))];
    } else if ([item isKindOfClass:[UIImage class]]) {
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithUniqueName];
        [pasteboard setData:UIImagePNGRepresentation(item) forPasteboardType:@"public.png"];
        LINEURLString = [NSString stringWithFormat:@"line://msg/image/%@", pasteboard.name];
    } else {
        return NO;
    }
    
    NSURL *LINEURL = [NSURL URLWithString:LINEURLString];
    [[UIApplication sharedApplication] openURL:LINEURL];
    return YES;
}

@end
