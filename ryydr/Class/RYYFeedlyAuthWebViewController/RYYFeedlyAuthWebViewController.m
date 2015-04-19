//
//  RYYAuthWebViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 10/7/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYFeedlyAuthWebViewController.h"
#import "TSMessage.h"

@interface RYYFeedlyAuthWebViewController ()

@end

@implementation RYYFeedlyAuthWebViewController

- (instancetype)init
{
	self = [super initWithURL:[NSURL URLWithString:@""] type:M2DWebViewTypeUIKit];
	if (self) {
		
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification object:[NXOAuth2AccountStore sharedStore] queue:nil usingBlock:^(NSNotification *notification) {
		NSDictionary *dict = notification.userInfo;
		NXOAuth2Account *account = [dict valueForKey:NXOAuth2AccountStoreNewAccountUserInfoKey];
		if (self.successBlocks) {
			self.successBlocks(self, account);
		}
	}];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification object:[NXOAuth2AccountStore sharedStore] queue:nil usingBlock:^(NSNotification *note) {
		if (self.failuerBlocks) {
			self.failuerBlocks(self);
		}
	}];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	UIWebView *webView = self.webView;
	[[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:kOauth2ClientAccountType withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
		[webView loadRequest:[NSURLRequest requestWithURL:preparedURL]];
	}];
}

#pragma mark - UIWebViewDelegate

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if ([[NXOAuth2AccountStore sharedStore] handleRedirectURL:[request URL]]) {
		return NO;
	}
	return YES;
}

#pragma mark -

- (void)cancel
{
	[self dismissViewControllerAnimated:YES completion:^{
	}];
}

@end
