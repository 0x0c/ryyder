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

static const NSString *JS_GET_TITLE= @"var elements=document.getElementsByTagName(\'title\');elements[0].innerText";

@interface RYYWebViewController () <M2DWebViewControllerDelegate, NJKWebViewProgressDelegate>
{
	NJKWebViewProgressView *progressView_;
	NJKWebViewProgress *progressProxy_;
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
	
	self.delegate = self;
	
	webView_.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
	
	FAKFontAwesome *back = [FAKFontAwesome angleLeftIconWithSize:25];
	[goBackButton_ setImage:[back imageWithSize:CGSizeMake(25, 25)]];
	FAKFontAwesome *forward = [FAKFontAwesome angleRightIconWithSize:25];
	[goForwardButton_ setImage:[forward imageWithSize:CGSizeMake(25, 25)]];
	
	progressProxy_ = [[NJKWebViewProgress alloc] init];
	webView_.delegate = progressProxy_;
    progressProxy_.webViewProxyDelegate = self;
    progressProxy_.progressDelegate = self;
    CGFloat progressBarHeight = 3.0f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    progressView_ = [[NJKWebViewProgressView alloc] initWithFrame:CGRectMake(0, navigaitonBarBounds.size.height - 1.5, navigaitonBarBounds.size.width, progressBarHeight)];
	[progressView_ setProgress:0];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController.navigationBar addSubview:progressView_];
	[self.navigationController setToolbarHidden:NO animated:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[super webViewDidFinishLoad:webView];
	
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"var elements=document.getElementsByTagName(\'title\');elements[0].innerText"];
}

#pragma mark - M2DWebViewControllerDelegate

- (void)webViewControllerActionButtonPressed:(M2DWebViewController *)webViewController
{
	NSString *title = [webView_ stringByEvaluatingJavaScriptFromString:(NSString *)JS_GET_TITLE];

	void (^f)(NSError *e) = ^(NSError *error) {
		if(error) {
			[TSMessage showNotificationWithTitle:@"Error" subtitle:error.localizedDescription type:TSMessageNotificationTypeError];
		}
		else {
			[TSMessage showNotificationWithTitle:@"Success" subtitle:@"Operation succeeded." type:TSMessageNotificationTypeSuccess];
		}
	};
	NSMutableArray *activities = [[NSMutableArray alloc] init];
	
	LDRPinActiviry *addToList = [LDRPinActiviry new];
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
	markAsRead.article = self.article;

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
	
	FacebookMessengerActivity *messengerActivity = [[FacebookMessengerActivity alloc] initWithHandler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
		f(error);
	}];
	[activities addObject:messengerActivity];
	
	EvernoteActivity *evernote = [[EvernoteActivity alloc] initWithHost:EVERNOTE_HOST consumerKey:EVERNOTE_CONSUMER_KEY secret:EVERNOTE_CONSUMER_SECRET];
	[evernote setCreateNoteHanderBlocks:^(BOOL completion, EDAMNote *note, NSError *error) {
		if (completion) {
			f(error);
		}
	}];
	evernote.delegate = self;
	[activities addObject:evernote];
	
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[title, url_] applicationActivities:activities];
	[self presentViewController:activityViewController animated:YES completion:^{
	}];
}

#pragma mark - NJKWebViewProgressDelegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [progressView_ setProgress:progress animated:YES];
}

@end
