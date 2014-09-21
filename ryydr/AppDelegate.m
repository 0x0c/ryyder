//
//  AppDelegate.m
//  ryydr
//
//  Created by Akira Matsuda on 8/19/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "AppDelegate.h"
#import "LDRGatekeeper.h"
#import "UICKeyChainStore.h"
#import "SVProgressHUD.h"
#import "MTMigration.h"
#import "TSMessage.h"
#import <Crashlytics/Crashlytics.h>
#import "PocketAPI.h"
#import "HTBHatenaBookmarkManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[MTMigration applicationUpdateBlock:^{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:FirstLaunchKey];
		NSString *versionNum = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
		NSString *buildNum = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
		if (![versionNum isEqualToString:@"1.0.0"]) {
			[TSMessage showNotificationInViewController:self.window.rootViewController title:@"ryyder is updated" subtitle:[NSString stringWithFormat:@"New version %@", [NSString stringWithFormat:@"Version %@.%@", versionNum, buildNum]] type:TSMessageNotificationTypeSuccess duration:10 canBeDismissedByUser:YES];
		}
	}];
	[MTMigration migrateToVersion:@"1.0.0" block:^{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:SyncAtLaunchKey];
	}];
	
	[Crashlytics startWithAPIKey:(NSString *)CrashlyticsAPIKey];
#ifdef DEBUG
	[[Crashlytics sharedInstance] setDebugMode:YES];
#endif
	
	[[HTBHatenaBookmarkManager sharedManager] setConsumerKey:HatenaOAuthConsumerKey consumerSecret:HatenaOAuthConsumerSecret];
	[[PocketAPI sharedAPI] setURLScheme:URLScheme];
	[[PocketAPI sharedAPI] setConsumerKey:PocketConsumerKey];
	
	[SVProgressHUD setBackgroundColor:[UIColor darkGrayColor]];
	[SVProgressHUD setForegroundColor:[UIColor whiteColor]];
	
	LDRGatekeeper *gatekeeper = [LDRGatekeeper sharedInstance];
#ifdef DEBUG
	gatekeeper.debugMode = YES;
#endif
	[gatekeeper initializeBlock:^(M2DAPIRequest *request, NSDictionary *params) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
		});
	}];
	[gatekeeper finalizeBlock:^(M2DAPIRequest *request) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
	}];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self updateBadgeNumber:^(NSInteger count) {
		}];
	});
	
	[[NSNotificationCenter defaultCenter] addObserverForName:LDRArticleItemReadFlagNotificationYES object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:ShowBadgeKey]) {
			[UIApplication sharedApplication].applicationIconBadgeNumber--;
		}
	}];
	[[NSNotificationCenter defaultCenter] addObserverForName:LDRArticleItemReadFlagNotificationNO object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:ShowBadgeKey]) {
			[UIApplication sharedApplication].applicationIconBadgeNumber++;
		}
	}];
	
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL*)url
{
	if([[PocketAPI sharedAPI] handleOpenURL:url]) {
		return YES;
	}
	
	return NO;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
	[self updateBadgeNumber:^(NSInteger count) {
	}];
	completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - 

- (void)updateBadgeNumber:(void (^)(NSInteger count))completionHandler
{
	LDRGatekeeper *g = [LDRGatekeeper new];
	[g getUnreadCountWithCompletionHandler:^(NSString *result, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSInteger count = [result integerValue];
			if ([[NSUserDefaults standardUserDefaults] boolForKey:ShowBadgeKey]) {
				[UIApplication sharedApplication].applicationIconBadgeNumber = count;
			}
			if ([[NSUserDefaults standardUserDefaults] boolForKey:ShowNotificationKey] && count > 0) {
				UILocalNotification *localNotification = [[UILocalNotification alloc] init];
				NSString *body = [NSString stringWithFormat:(count == 1 ? @"There is %ld unread content available." : @"There are %ld unread contents available."), (long)count];
				localNotification.alertBody = body;
				localNotification.soundName = UILocalNotificationDefaultSoundName;
				localNotification.alertAction = @"Open";
				[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
			}
			completionHandler(count);
		});
	}];
}

@end
