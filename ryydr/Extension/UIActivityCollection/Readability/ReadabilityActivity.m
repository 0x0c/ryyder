//
//  ReadabilityActivity.m
//
//  Created by Brendan Lynch on 12-09-20.
//  Copyright (c) 2012 Readability LLC. All rights reserved.
//

#import "ReadabilityActivity.h"

NSString * const ReadabilityActivityURI = @"readability://";
NSString * const ReadabilityActivityAdd = @"add";

@implementation ReadabilityActivity

- (NSString *)activityType
{
    return @"UIActivityReadability";
}

- (NSString *)activityTitle
{
    return @"Readability";
}

- (UIImage *)activityImage
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIImage imageNamed:@"Readability-activity-iPad"];
    }
    
    return [UIImage imageNamed:@"Readability-activity-iPhone"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    _activityItems = activityItems;
}

- (void)performActivity
{
    if ([ReadabilityActivity canPerformActivity])
    {
        NSString *activityAction = ReadabilityActivityAdd;//_activityItems[0];
        NSURL *activityURL = nil;
		for (id obj in _activityItems) {
			if ([obj isKindOfClass:[NSURL class]]) {
				activityURL = obj;
				break;
			}
		}
        
        NSString *readabilityURLString = [NSString stringWithFormat:@"%@%@/%@", ReadabilityActivityURI, activityAction, [activityURL absoluteString]];
        NSURL *readabilityURL = [NSURL URLWithString:readabilityURLString];
        
        [[UIApplication sharedApplication] openURL:readabilityURL];
        
        [self activityDidFinish:YES];
    }
    else
    {
        [self activityDidFinish:NO];
    }
}

+ (BOOL)canPerformActivity
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:ReadabilityActivityURI]];
}

@end