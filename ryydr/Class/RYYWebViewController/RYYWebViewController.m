//
//  RYYWebViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 8/20/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYWebViewController.h"
#import "TSMessage.h"
#import "FAKFontAwesome.h"
#import "UIActivityCollection.h"
#import "SVProgressHUD.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

static NSString *const JS_GET_TITLE= @"var elements=document.getElementsByTagName(\'title\');elements[0].innerText";

@interface RYYWebViewController () <NJKWebViewProgressDelegate>
{
	NJKWebViewProgress *progressProxy_;
	NJKWebViewProgressView *progressView_;
}

@end

@implementation RYYWebViewController

- (void)dealloc
{
	[progressView_ removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	((WKWebView *)webView_).scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
	
	CGFloat progressBarHeight = 3.0f;
	CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
	progressView_ = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight)];
	[progressView_ setProgress:0];
	
	if ([webView_ isKindOfClass:[UIWebView class]]) {
		progressProxy_ = [[NJKWebViewProgress alloc] init];
		((UIWebView *)webView_).delegate = progressProxy_;
		progressProxy_.webViewProxyDelegate = self;
		progressProxy_.progressDelegate = self;
	}
	
	__weak typeof(self) bself = self;
	self.actionButtonPressedHandler = ^(NSString *pageTitle, NSURL *url) {
		void (^f)(NSError *e) = ^(NSError *error) {
			if(error) {
				[TSMessage showNotificationWithTitle:@"Error" subtitle:error.localizedDescription type:TSMessageNotificationTypeError];
			}
			else {
				[TSMessage showNotificationWithTitle:@"Success" subtitle:@"Operation succeeded." type:TSMessageNotificationTypeSuccess];
			}
		};
		NSMutableArray *activities = [[NSMutableArray alloc] init];
		
		LDRPinActiviry *addToList = [[LDRPinActiviry alloc] initWithTitle:pageTitle url:url];
		LDRMarkAsReadActivity *markAsRead = [LDRMarkAsReadActivity new];
		LDRGatekeeper *gatekeeper = [LDRGatekeeper new];
		LDRGatekeeper *sharedGatekeeper = [LDRGatekeeper sharedInstance];
		[[[gatekeeper parseBlock:sharedGatekeeper.parseBlock] resultConditionBlock:sharedGatekeeper.resultConditionBlock] initializeBlock:sharedGatekeeper.initializeBlock];
		gatekeeper.finalizeBlock = nil;
		
		void (^handler)(NSError *) = ^(NSError *error) {
			[SVProgressHUD showSuccessWithStatus:@"Added"];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[SVProgressHUD dismiss];
			});
		};
		
		addToList.gatekeeper = gatekeeper;
		addToList.completionHandler = handler;
		markAsRead.gatekeeper = gatekeeper;
		markAsRead.completionHandler = handler;
		markAsRead.article = bself.article;
		
		[activities addObject:addToList];
		[activities addObject:markAsRead];
		
		if ([ReadabilityActivity canPerformActivity]) {
			ReadabilityActivity *rdb = [[ReadabilityActivity alloc] init];
			[activities addObject:rdb];
		}
		if ([LINEActivity canPerformActivity]) {
			LINEActivity *line = [[LINEActivity alloc] init];
			[activities addObject:line];
		}
		if ([PocketActivity canPerformActivity]) {
			PocketActivity *pocket = [[PocketActivity alloc] initWithScheme:URLScheme consumerKey:(NSString *)PocketConsumerKey];
			[pocket setSaveURLHanderBlocks:^(BOOL completion, PocketAPI *api, NSURL *url, NSError *error) {
				if (completion) {
					f(error);
				}
			}];
			[activities addObject:pocket];
		}
		if ([InstapaperActivity canPerformActivity]) {
			InstapaperActivity *instapaper = [[InstapaperActivity alloc] init];
			[activities addObject:instapaper];
		}
		
		HTBHatenaBookmarkActivity *hateaBookmarkActivity = [[HTBHatenaBookmarkActivity alloc] init];
		[activities addObject:hateaBookmarkActivity];
		
		FacebookMessengerActivity *messengerActivity = [[FacebookMessengerActivity alloc] initWithCompletionHandler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
			f(error);
		}];
		[activities addObject:messengerActivity];
		
		//	EvernoteActivity *evernote = [[EvernoteActivity alloc] initWithHost:EVERNOTE_HOST consumerKey:EVERNOTE_CONSUMER_KEY secret:EVERNOTE_CONSUMER_SECRET];
		//	[evernote setCreateNoteHanderBlocks:^(BOOL completion, EDAMNote *note, NSError *error) {
		//		if (completion) {
		//			f(error);
		//		}
		//	}];
		//	evernote.delegate = self;
		//	[activities addObject:evernote];
		
		[activities addObject:[TUSafariActivity new]];
		UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[pageTitle, url] applicationActivities:activities];
		if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
			activityViewController.popoverPresentationController.barButtonItem = bself.toolbarItems[bself.toolbarItems.count - 2];
		}
		[bself presentViewController:activityViewController animated:YES completion:^{
		}];
	};
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO animated:YES];
	[self.navigationController.navigationBar addSubview:progressView_];
	
	static NSInteger FlexibleSpaceTag = 200;
	NSInteger alignment = [[NSUserDefaults standardUserDefaults] integerForKey:UserInterfaceAlignmentKey];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	flexibleSpace.tag = FlexibleSpaceTag;
	NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
	UIBarButtonItem *firstButtonItem = [toolbarItems firstObject];
	UIBarButtonItem *lastButtonItem = [toolbarItems lastObject];
	if (firstButtonItem.tag == FlexibleSpaceTag) {
		[toolbarItems removeObject:firstButtonItem];
	}
	if (lastButtonItem.tag == FlexibleSpaceTag) {
		[toolbarItems removeObject:lastButtonItem];
	}
	if (alignment == 0) {
		[toolbarItems insertObject:flexibleSpace atIndex:toolbarItems.count];
	}
	else if (alignment == 2) {
		[toolbarItems insertObject:flexibleSpace atIndex:0];
	}
	self.toolbarItems = toolbarItems;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.navigationController setToolbarHidden:NO animated:YES];
}

#pragma mark - WKWebViewDelegate

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
	[progressView_ setProgress:webView.estimatedProgress animated:YES];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
	[super webView:webView didStartProvisionalNavigation:navigation];
	[progressView_ setProgress:webView.estimatedProgress animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
	[super webView:webView didFinishNavigation:navigation];
	self.title = webView.title;
	[progressView_ setProgress:webView.estimatedProgress animated:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[super webViewDidFinishLoad:webView];
	
	self.title = [webView stringByEvaluatingJavaScriptFromString:JS_GET_TITLE];
}

#pragma mark - NJKWebViewProgressDelegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
	[progressView_ setProgress:progress animated:YES];
}

- (void)updateToolbarItemsWithType:(UIBarButtonSystemItem)type
{
	NSInteger alignment = [[NSUserDefaults standardUserDefaults] integerForKey:UserInterfaceAlignmentKey];
	NSInteger itemIndex = 5;
	if (alignment == 2) {
		itemIndex = 6;
	}
	if (type == UIBarButtonSystemItemRefresh) {
		NSMutableArray *items = [[self.navigationController.toolbar items] mutableCopy];
		UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
		[items replaceObjectAtIndex:itemIndex withObject:refreshButton];
		[self.navigationController.toolbar setItems:items];
	}
	else if (type == UIBarButtonSystemItemStop) {
		NSMutableArray *items = [[self.navigationController.toolbar items] mutableCopy];
		UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)];
		[items replaceObjectAtIndex:itemIndex withObject:refreshButton];
		[self.navigationController.toolbar setItems:items];
	}
}

@end
