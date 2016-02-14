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
#import "PocketAPI.h"
#import "HTBHatenaBookmarkManager.h"
#import <Crashlytics/Crashlytics.h>
#import "NXOAuth2.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.
	
	[self registerForRemoteNotification];
	[MTMigration applicationUpdateBlock:^{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:FirstLaunchKey];
		NSString *versionNum = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
		NSString *buildNum = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
		if (![versionNum isEqualToString:@"1.0.0"]) {
			[TSMessage showNotificationInViewController:self.window.rootViewController title:NSLocalizedString(@"ryyder is updated", nil) subtitle:[NSString stringWithFormat:@"New version %@", [NSString stringWithFormat:@"Version %@(%@)", versionNum, buildNum]] type:TSMessageNotificationTypeSuccess duration:10 canBeDismissedByUser:YES];
		}
	}];
	[MTMigration migrateToVersion:@"1.0.0" block:^{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:SyncAtLaunchKey];
	}];
	[MTMigration migrateToVersion:@"1.0.4" block:^{
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:UserInterfaceAlignmentKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];
	application.applicationIconBadgeNumber = 0;

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
			[SVProgressHUD show];
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

	//	NSString *authUrl = [kOauth2ClientBaseUrl stringByAppendingString:kOauth2ClientAuthUrl];
	//	NSString *tokenUrl = [kOauth2ClientBaseUrl stringByAppendingString:kOauth2ClientTokenUrl];
	//	[[NXOAuth2AccountStore sharedStore] setClientID:kOauth2ClientClientId secret:kOauth2ClientClientSecret
	//											  scope:[NSSet setWithObjects:kOauth2ClientScopeUrl, nil]
	//								   authorizationURL:[NSURL URLWithString:authUrl]
	//										   tokenURL:[NSURL URLWithString:tokenUrl]
	//										redirectURL:[NSURL URLWithString:kOauth2ClientRedirectUrl]
	//									  keyChainGroup:@"com.akira.matsuda.ryyder"
	//									 forAccountType:kOauth2ClientAccountType];

	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	if ([[PocketAPI sharedAPI] handleOpenURL:url]) {
		return YES;
	}

	return NO;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
	[self updateBadgeNumber:^(NSInteger count){
	}];
	completionHandler(UIBackgroundFetchResultNewData);
}

- (void)registerForRemoteNotification
{
	UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
	UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
	[[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
	[application registerForRemoteNotifications];
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
			else {
				[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
			}
			if ([[NSUserDefaults standardUserDefaults] boolForKey:ShowNotificationKey] && count > 0) {
				UILocalNotification *localNotification = [[UILocalNotification alloc] init];
				NSString *body = [NSString stringWithFormat:(count == 1 ? NSLocalizedString(@"There is %ld unread content available.", nil) : NSLocalizedString(@"There are %ld unread contents available.", nil)), (long)count];
				localNotification.alertBody = body;
				localNotification.soundName = UILocalNotificationDefaultSoundName;
				localNotification.alertAction = NSLocalizedString(@"Open", nil);
				[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
			}
			completionHandler(count);
		});
	}];
}

@end
