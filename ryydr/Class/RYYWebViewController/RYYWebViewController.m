//
//  RYYWebViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 8/20/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYWebViewController.h"
#import "UIActivityCollection.h"
#import "SVProgressHUD.h"

@interface RYYWebViewController () <SFSafariViewControllerDelegate>

@end

@implementation RYYWebViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:MarkAsReadImmediatelyKey]) {
		self.article.read = YES;
	}
}

#pragma mark - 

- (NSArray<UIActivity *> *)safariViewController:(SFSafariViewController *)controller activityItemsForURL:(NSURL *)URL title:(NSString *)title
{
	LDRPinActiviry *addToList = [[LDRPinActiviry alloc] initWithTitle:title url:URL];
	LDRMarkAsReadActivity *markAsRead = [LDRMarkAsReadActivity new];
	LDRGatekeeper *gatekeeper = [LDRGatekeeper new];
	LDRGatekeeper *sharedGatekeeper = [LDRGatekeeper sharedInstance];
	[[[gatekeeper parseBlock:sharedGatekeeper.parseBlock] resultConditionBlock:sharedGatekeeper.resultConditionBlock] initializeBlock:sharedGatekeeper.initializeBlock];
	gatekeeper.finalizeBlock = nil;
	
	void (^handler)(NSError *) = ^(NSError *error) {
		[SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Added", nil)];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
	};
	
	addToList.gatekeeper = gatekeeper;
	addToList.completionHandler = handler;
	markAsRead.gatekeeper = gatekeeper;
	markAsRead.completionHandler = handler;
	markAsRead.article = self.article;
	
	return @[addToList, markAsRead];
}

@end
