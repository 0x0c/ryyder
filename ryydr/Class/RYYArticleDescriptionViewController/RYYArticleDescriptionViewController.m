//
//  RYYArticleDescriptionViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 8/20/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYArticleDescriptionViewController.h"
#import "RYYArticleTableViewController.h"
#import "RYYFeedViewController.h"
#import "RYYWebViewController.h"
#import "RYYSplitViewController.h"
#import "FAKFontAwesome.h"
#import "LDRGatekeeper.h"
#import "SVProgressHUD.h"

#define RYYArticleDescriptionHTMLFormat                                             \
	@"<!DOCTYPE HTML PUBLIC\"-//W3C//DTD HTML 4.01 Transitional//EN\" "         \
	    @"\"http://www.w3.org/TR/html4/loose.dtd\"><html><head><meta "          \
	    @"http-equiv=\"Content-Type\" content=\"text/html; "                    \
	    @"charset=Shift_JIS\"><meta http-equiv=\"Content-Style-Type\" "         \
	    @"content=\"text/css\"><title>%@</title><style "                        \
	    @"type=\"text/css\">html{-webkit-text-size-adjust: "                    \
	    @"none;}img{max-width: "                                                \
	    @"100%%; height:auto;}h1{margin-top: 0px; font-size: 18px; "            \
	    @"text-decoration: none; color: "                                       \
	    @"#000000;font-weight:900;font-family:HiraKakuProN-W6;}h3{margin-top: " \
	    @"-5px; font-size: 13px; text-decoration: none; color: "                \
	    @"#8E8E93;font-weight:300;font-family: "                                \
	    @"HiraKakuProN-W3;}body{font-family:HiraKakuProN-W3; font-size: "       \
	    @"15px}a{text-decoration: none;color: #007AFF}.content{margin: "        \
	    @"7px;}</style></head><div class=\"content\"><body><h3 "                \
	    @"style=\"margin-top:3px;margin-bottom:-3px;\">%@</h3><a "              \
	    @"href=\"%@\"><h1>%@</h1></a><h3 style=\"margin-bottom: "               \
	    @"-3px;\">created " @"by %@ - %@</h3><hr>%@<br><br><a href=\"%@\">[ "   \
	    @"Read ]</a><hr><h3><script "                                           \
	    @"type=\"text/javascript\" charset=\"utf-8\">document.writeln(new "     \
	    @"Date(%@ " @"* 1000));</script></h3></body></div></html>"

@interface RYYArticleDescriptionViewController () <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	UIBarButtonItem *upButtonItem;
	UIBarButtonItem *downButtonItem;

	UIBarButtonItem *doubleUpButtonItem;
	UIBarButtonItem *doubleDownButtonItem;
	UIBarButtonItem *pinButtonItem;
	UIBarButtonItem *linkButtonItem;
}

@end

static CGFloat kIconButtonSize = 27;

@implementation RYYArticleDescriptionViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
	webView.delegate = self;
	[self loadHTML];

	FAKFontAwesome *pin = [FAKFontAwesome dotCircleOIconWithSize:kIconButtonSize - 2];
	pinButtonItem = [[UIBarButtonItem alloc] initWithImage:[pin imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[pin imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(pin)];
	FAKFontAwesome *link = [FAKFontAwesome linkIconWithSize:kIconButtonSize - 2];
	linkButtonItem = [[UIBarButtonItem alloc] initWithImage:[link imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[link imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(openLink)];

	FAKFontAwesome *up = [FAKFontAwesome angleUpIconWithSize:kIconButtonSize];
	FAKFontAwesome *down = [FAKFontAwesome angleDownIconWithSize:kIconButtonSize];
	upButtonItem = [[UIBarButtonItem alloc] initWithImage:[up imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[up imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(up)];
	downButtonItem = [[UIBarButtonItem alloc] initWithImage:[down imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[down imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(down)];
	upButtonItem.enabled = (_article.previous != nil);
	downButtonItem.enabled = (_article.next != nil);

	up = [FAKFontAwesome angleDoubleUpIconWithSize:kIconButtonSize];
	down = [FAKFontAwesome angleDoubleDownIconWithSize:kIconButtonSize];
	doubleUpButtonItem = [[UIBarButtonItem alloc] initWithImage:[up imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[up imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(doubleUp)];
	doubleDownButtonItem = [[UIBarButtonItem alloc] initWithImage:[down imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[down imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(doubleDown)];

	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *fixedSectionSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixedSectionSpace.width = 10;
	UIBarButtonItem *fixedButtonSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixedButtonSpace.width = 4;
	[self setToolbarItems:@[ fixedButtonSpace, pinButtonItem, fixedButtonSpace, linkButtonItem, flexibleSpace, doubleUpButtonItem, fixedButtonSpace, doubleDownButtonItem, fixedSectionSpace, upButtonItem, fixedButtonSpace, downButtonItem, fixedButtonSpace ] animated:YES];
	[self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
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

	upButtonItem.enabled = (_article.previous != nil);
	downButtonItem.enabled = (_article.next != nil);
	pinButtonItem.enabled = (_article.link != nil);
	linkButtonItem.enabled = (_article.link != nil);
	doubleUpButtonItem.enabled = (self.article.parent.parent.previousFeed != nil);
	doubleDownButtonItem.enabled = (self.article.parent.parent.nextFeed != nil);

	self.title = [NSString stringWithFormat:@"%ld / %ld", (long)_article.index + 1, (long)[_article.parent.items count]];
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
	pinButtonItem.enabled = (_article.link != nil);
	linkButtonItem.enabled = (_article.link != nil);
	doubleUpButtonItem.enabled = (self.article.parent.parent.previousFeed != nil);
	doubleDownButtonItem.enabled = (self.article.parent.parent.nextFeed != nil);

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
		[self presentViewController:viewController animated:YES completion:nil];
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
		[SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Added", nil)];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
	}];
}

- (void)openLink
{
	RYYWebViewController *viewController = [[RYYWebViewController alloc] initWithURL:[NSURL URLWithString:self.article.link]];
	viewController.article = self.article;
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)up
{
	if (self.article.previous) {
		self.article = self.article.previous;
	}
	
	RYYSplitViewController *splitViewController = (RYYSplitViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
	UINavigationController *masterViewController = [splitViewController performSelector:@selector(masterViewController)];
	if ([masterViewController.visibleViewController isKindOfClass:[RYYArticleTableViewController class]] || [masterViewController.visibleViewController isKindOfClass:[RYYFeedViewController class]]) {
		RYYArticleTableViewController *tableViewController = (RYYArticleTableViewController *)masterViewController.visibleViewController;
		[tableViewController.tableView reloadData];
	}
}

- (void)down
{
	if (self.article.next) {
		self.article = self.article.next;
	}

	RYYSplitViewController *splitViewController = (RYYSplitViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
	UINavigationController *masterViewController = [splitViewController performSelector:@selector(masterViewController)];
	if ([masterViewController.visibleViewController isKindOfClass:[RYYArticleTableViewController class]] || [masterViewController.visibleViewController isKindOfClass:[RYYFeedViewController class]]) {
		RYYArticleTableViewController *tableViewController = (RYYArticleTableViewController *)masterViewController.visibleViewController;
		[tableViewController.tableView reloadData];
	}
}

- (void)doubleUp
{
	self.article = self.article.parent.parent.previousFeed.data.items.lastObject;
	doubleUpButtonItem.enabled = (self.article.parent.parent.previousFeed != nil);
	doubleDownButtonItem.enabled = (self.article.parent.parent.nextFeed != nil);

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
		[(RYYArticleTableViewController *)self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2] up];
	}
	else {
		RYYSplitViewController *splitViewController = (RYYSplitViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
		UINavigationController *masterViewController = [splitViewController performSelector:@selector(masterViewController)];
		if ([masterViewController.visibleViewController isKindOfClass:[RYYArticleTableViewController class]] || [masterViewController.visibleViewController isKindOfClass:[RYYFeedViewController class]]) {
			RYYArticleTableViewController *tableViewController = (RYYArticleTableViewController *)masterViewController.visibleViewController;
			[tableViewController.tableView reloadData];
		}
	}
}

- (void)doubleDown
{
	self.article = self.article.parent.parent.nextFeed.data.items[0];
	doubleUpButtonItem.enabled = (self.article.parent.parent.previousFeed != nil);
	doubleDownButtonItem.enabled = (self.article.parent.parent.nextFeed != nil);
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
		[(RYYArticleTableViewController *)self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2] down];
	}
	else {
		RYYSplitViewController *splitViewController = (RYYSplitViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
		UINavigationController *masterViewController = [splitViewController performSelector:@selector(masterViewController)];
		if ([masterViewController.visibleViewController isKindOfClass:[RYYArticleTableViewController class]] || [masterViewController.visibleViewController isKindOfClass:[RYYFeedViewController class]]) {
			RYYArticleTableViewController *tableViewController = (RYYArticleTableViewController *)masterViewController.visibleViewController;
			[tableViewController.tableView reloadData];
		}
	}
}

- (void)loadHTML
{
	if (self.article) {
		NSString *htmlString = [NSString stringWithFormat:RYYArticleDescriptionHTMLFormat, self.article.title, self.article.parent.parent.title, self.article.link, self.article.title, self.article.author, self.article.category, self.article.body, self.article.link, [@(self.article.createdOn) stringValue]];
		[webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:self.article.link]];
	}
	else {
		NSString *htmlString = [NSString stringWithFormat:RYYArticleDescriptionHTMLFormat, @"", @"", @"", @"", @"", @"", @"", @"", [@(self.article.createdOn) stringValue]];
		[webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:self.article.link]];
	}
}

@end
