//
//  M2DWebViewController.m
//  BoostMedia
//
//  Created by Akira Matsuda on 2013/01/11.
//  Copyright (c) 2013年 akira.matsuda. All rights reserved.
//

#import "M2DWebViewController.h"


@interface M2DWebViewController ()

@end

@implementation M2DWebViewController

@synthesize webView = webView_;

- (id)initWithURL:(NSURL *)url
{
	self = [super initWithNibName:@"M2DWebViewController" bundle:nil];
	if (self) {
		url_ = [url copy];
	}
	
	return self;
}

- (void)dealloc
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	webView_.delegate = self;
	[webView_ loadRequest:[NSURLRequest requestWithURL:url_]];
	
	goBackButton_ = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:[self getFilePath:@"M2DWebViewController_left.png"]] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
	goForwardButton_ = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:[self getFilePath:@"M2DWebViewController_right.png"]] style:UIBarButtonItemStylePlain target:self action:@selector(goForward:)];
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *fixedSpace19 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixedSpace19.width = 19;
	UIBarButtonItem *fixedSpace6 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixedSpace6.width = 6;
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	actionButton_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(doAction:)];
	NSArray *toolbarItems = @[fixedSpace6, goBackButton_, fixedSpace19, goForwardButton_, space, refreshButton, fixedSpace19, actionButton_, fixedSpace6];
	self.toolbarItems = toolbarItems;
	
	goForwardButton_.enabled = NO;
	goBackButton_.enabled = NO;
		
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)setSmoothScroll:(BOOL)smoothScroll
{
	if (smoothScroll) {
		webView_.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
	}
	else {
		webView_.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	}
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if ([webView_ canGoBack]) {
		goBackButton_.enabled = YES;
	}
	else {
		goBackButton_.enabled = NO;
	}
	
	if ([webView_ canGoForward]) {
		goForwardButton_.enabled = YES;
	}
	else {
		goForwardButton_.enabled = NO;
	}
	url_ = [webView.request.URL copy];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSMutableArray *items = [[self.navigationController.toolbar items] mutableCopy];
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	[items replaceObjectAtIndex:5 withObject:refreshButton];
	[self.navigationController.toolbar setItems:items];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	if ([webView_ canGoBack]) {
		goBackButton_.enabled = YES;
	}
	else {
		goBackButton_.enabled = NO;
	}
	
	if ([webView_ canGoForward]) {
		goForwardButton_.enabled = YES;
	}
	else {
		goForwardButton_.enabled = NO;
	}

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSMutableArray *items = [[self.navigationController.toolbar items] mutableCopy];
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)];
	[items replaceObjectAtIndex:5 withObject:refreshButton];
	[self.navigationController.toolbar setItems:items];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSMutableArray *items = [[self.navigationController.toolbar items] mutableCopy];
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	[items replaceObjectAtIndex:5 withObject:refreshButton];
	[self.navigationController.toolbar setItems:items];
}

#pragma mark -

- (void)goForward:(id)sender
{
	[webView_ goForward];
}

- (void)goBack:(id)sender
{
	[webView_ goBack];
}

- (void)refresh:(id)sender
{
	[webView_ reload];
}

- (void)stop:(id)sender
{
	[webView_ stopLoading];
}

- (IBAction)doAction:(id)sender
{
	if ([self.delegate respondsToSelector:@selector(webViewControllerActionButtonPressed:)]) {
		[self.delegate webViewControllerActionButtonPressed:self];
	}
}

- (void)loadURL:(NSURL *)url
{
	[webView_ loadRequest:[NSURLRequest requestWithURL:url]];
}

- (NSString *)getFilePath:(NSString *)filename
{
	return 	[NSString stringWithFormat:@"%@/%@.png", [[NSBundle mainBundle] pathForResource:@"M2DWebViewController" ofType:@"bundle"], filename];
}

@end
