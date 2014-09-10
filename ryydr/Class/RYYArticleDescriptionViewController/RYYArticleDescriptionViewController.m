//
//  RYYArticleDescriptionViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 8/20/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYArticleDescriptionViewController.h"
#import "RYYArticleTableViewController.h"
#import "RYYWebViewController.h"
#import "FAKFontAwesome.h"
#import "LDRGatekeeper.h"
#import "SVProgressHUD.h"

#define RYYArticleDescriptionHTMLFormat @"<!DOCTYPE HTML PUBLIC\"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\"><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=Shift_JIS\"><meta http-equiv=\"Content-Style-Type\" content=\"text/css\"><title>%@</title><style type=\"text/css\">html{-webkit-text-size-adjust: none;}img{max-width: 100%%; height:auto;}h1{margin-top: 0px; font-size: 18px; text-decoration: none; color: #000000;font-weight:900;font-family:HiraKakuProN-W6;}h3{margin-top: -5px; font-size: 13px; text-decoration: none; color: #8E8E93;font-weight:300;font-family: HiraKakuProN-W3;}body{font-family:HiraKakuProN-W3; font-size: 15px}a{text-decoration: none;color: #007AFF}.content{margin: 7px;}</style></head><div class=\"content\"><body><h3 style=\"margin-top:3px;margin-bottom:-3px;\">%@</h3><a href=\"%@\"><h1>%@</h1></a><h3 style=\"margin-bottom: -3px;\">created by %@ - %@</h3><hr>%@<br><br><a href=\"%@\">[ Read ]</a><hr><h3><script type=\"text/javascript\" charset=\"utf-8\">document.writeln(new Date(%@ * 1000));</script></h3></body></div></html>"

@interface RYYArticleDescriptionViewController () <UIWebViewDelegate>
{
	IBOutlet UIWebView *webView;
	UIBarButtonItem *upButtonItem;
	UIBarButtonItem *downButtonItem;
	
	UIBarButtonItem *doubleUpButtonItem;
	UIBarButtonItem *doubleDownButtonItem;
}

@end

@implementation RYYArticleDescriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
	webView.delegate = self;
	[self loadHTML];
	
	FAKFontAwesome *pin = [FAKFontAwesome dotCircleOIconWithSize:25];
	UIBarButtonItem *pinButtonItem = [[UIBarButtonItem alloc] initWithImage:[pin imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[pin imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(pin)];
	FAKFontAwesome *link = [FAKFontAwesome linkIconWithSize:25];
	UIBarButtonItem *linkButtonItem = [[UIBarButtonItem alloc] initWithImage:[link imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[link imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(openLink)];
	
	FAKFontAwesome *up = [FAKFontAwesome angleUpIconWithSize:25];
	FAKFontAwesome *down = [FAKFontAwesome angleDownIconWithSize:25];
	upButtonItem = [[UIBarButtonItem alloc] initWithImage:[up imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[up imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(up)];
	downButtonItem = [[UIBarButtonItem alloc] initWithImage:[down imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[down imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(down)];
	upButtonItem.enabled = (_article.previous != nil);
	downButtonItem.enabled = (_article.next != nil);
	
	up = [FAKFontAwesome angleDoubleUpIconWithSize:25];
	down = [FAKFontAwesome angleDoubleDownIconWithSize:25];
	doubleUpButtonItem = [[UIBarButtonItem alloc] initWithImage:[up imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[up imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(doubleUp)];
	doubleDownButtonItem = [[UIBarButtonItem alloc] initWithImage:[down imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[down imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(doubleDown)];
	doubleUpButtonItem.enabled = (self.article.parent.parent.previousFeed != nil);
	doubleDownButtonItem.enabled = (self.article.parent.parent.nextFeed != nil);
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[self setToolbarItems:@[pinButtonItem, linkButtonItem, flexibleSpace, doubleUpButtonItem, doubleDownButtonItem, upButtonItem, downButtonItem] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:MarkAsReadImmediatelyKey]) {
		self.article.read = YES;
	}
}

- (void)setArticle:(LDRArticleItem *)article
{
	_article = article;
	self.title = [NSString stringWithFormat:@"%ld / %ld", (long)_article.index + 1, (long)[_article.parent.items count]];
	
	upButtonItem.enabled = (_article.previous != nil);
	downButtonItem.enabled = (_article.next != nil);
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:MarkAsReadImmediatelyKey]) {
		self.article.read = YES;
	}
	
	[self loadHTML];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		RYYWebViewController *viewController = [[RYYWebViewController alloc] initWithURL:request.URL];
		viewController.article = self.article;
		[self.navigationController pushViewController:viewController animated:YES];
		return NO;
	}
	
	return YES;
}

#pragma mark -

- (void)pin
{
	LDRPinnedArticle *article = [LDRPinnedArticle new];
	article.title = self.article.title;
	article.link = self.article.link;
	
	LDRGatekeeper *gatekeeper = [LDRGatekeeper new];
	LDRGatekeeper *sharedGatekeeper = [LDRGatekeeper sharedInstance];
	[[[gatekeeper parseBlock:sharedGatekeeper.parseBlock] resultConditionBlock:sharedGatekeeper.resultConditionBlock] initializeBlock:sharedGatekeeper.initializeBlock];
	gatekeeper.finalizeBlock = nil;
	[gatekeeper addPinnedArticle:article completionHandler:^(NSError *error) {
		[SVProgressHUD showSuccessWithStatus:@"Added"];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
	}];
}

- (void)openLink
{
	RYYWebViewController *viewController = [[RYYWebViewController alloc] initWithURL:[NSURL URLWithString:self.article.link]];
	viewController.article = self.article;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)up
{
	if (self.article.previous) {
		self.article = self.article.previous;
	}
}

- (void)down
{
	if (self.article.next) {
		self.article = self.article.next;
	}
}

- (void)doubleUp
{
	self.article = self.article.parent.parent.previousFeed.data.items.lastObject;
	doubleUpButtonItem.enabled = (self.article.parent.parent.previousFeed != nil);
	doubleDownButtonItem.enabled = (self.article.parent.parent.nextFeed != nil);
	[(RYYArticleTableViewController *)self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2] performSelector:@selector(up) withObject:nil];
}

- (void)doubleDown
{
	self.article = self.article.parent.parent.nextFeed.data.items[0];
	doubleUpButtonItem.enabled = (self.article.parent.parent.previousFeed != nil);
	doubleDownButtonItem.enabled = (self.article.parent.parent.nextFeed != nil);
	[(RYYArticleTableViewController *)self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2] performSelector:@selector(down) withObject:nil];
}

- (void)loadHTML
{
	NSString *htmlString = [NSString stringWithFormat:RYYArticleDescriptionHTMLFormat, self.article.title, self.article.parent.parent.title, self.article.link, self.article.title, self.article.author, self.article.category, self.article.body, self.article.link, [@(self.article.createdOn) stringValue]];
	[webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:self.article.link]];
}

@end
