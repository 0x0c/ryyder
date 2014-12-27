//
//  RYYFeedlyTestViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 10/7/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYFeedlyTestViewController.h"
#import "TSMessage.h"
#import "RYYFeedlyAuthWebViewController.h"
#import "RYYFeedlyAPIGatekeeper.h"

@implementation RYYFeedlyTestViewController

- (IBAction)clearAccount:(id)sender
{
	NSArray *array = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"Feedly"];
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[[NXOAuth2AccountStore sharedStore] removeAccount:obj];
	}];
}

- (IBAction)login:(id)sender
{
	[RYYFeedlyAPIGatekeeper sharedInstance].sandboxMode = YES;
	NSArray *array = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"Feedly"];
	if (array.count) {
		NXOAuth2Account *account = array.firstObject;
		NSLog(@"%@", [account description]);
		[RYYFeedlyAPIGatekeeper sharedInstance].account = account;
	}
	else {
		RYYFeedlyAuthWebViewController *viewController = [[RYYFeedlyAuthWebViewController alloc] init];
		viewController.successBlocks = ^(RYYFeedlyAuthWebViewController *webView, NXOAuth2Account *account) {
			[TSMessage showNotificationInViewController:self title:@"Login Success" subtitle:@"Application will automatically sync at launch." type:TSMessageNotificationTypeSuccess];
			[RYYFeedlyAPIGatekeeper sharedInstance].account = account;
			[webView dismissViewControllerAnimated:YES completion:^{
			}];
		};
		viewController.failuerBlocks = ^(RYYFeedlyAuthWebViewController *webView) {
			[TSMessage showNotificationInViewController:self title:@"Login failed" subtitle:@"Please check your username or password." type:TSMessageNotificationTypeError];
			[webView dismissViewControllerAnimated:YES completion:^{
			}];
		};
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:navigationController animated:YES completion:^{
		}];
	}
}

- (IBAction)getProfile:(id)sender
{
	[[RYYFeedlyAPIGatekeeper sharedInstance] getProfile:^(id result, NSError *error) {
		NSLog(@"%@:%@", [result description], [error localizedDescription]);
	}];
}

- (IBAction)getMarks:(id)sender
{
	[[RYYFeedlyAPIGatekeeper sharedInstance] getMarks:^(id result, NSError *error) {
		NSLog(@"%@:%@", [result description], [error localizedDescription]);
	}];
}

- (IBAction)getSubscriptions:(id)sender
{
	[[RYYFeedlyAPIGatekeeper sharedInstance] getSubscriptions:^(id result, NSError *error) {
		NSLog(@"%@:%@", [result description], [error localizedDescription]);
	}];
}

- (IBAction)getEntry:(id)sender
{
	[[RYYFeedlyAPIGatekeeper sharedInstance] getEntry:self.entryIdentifer.text completionHandler:^(id result, NSError *error) {
		NSLog(@"%@:%@", [result description], [error localizedDescription]);
	}];
}

- (IBAction)getCategory:(id)sender
{
	[[RYYFeedlyAPIGatekeeper sharedInstance] getCategory:^(id result, NSError *error) {
		NSLog(@"%@:%@", [result description], [error localizedDescription]);
	}];
}

- (IBAction)postOPML:(id)sender
{
	NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"feedly" ofType:@"opml"]];
	[[RYYFeedlyAPIGatekeeper sharedInstance] postOPML:data completionHandler:^(id result, NSError *error) {
		NSLog(@"%@:%@", [result description], [error localizedDescription]);
	}];
}

@end
