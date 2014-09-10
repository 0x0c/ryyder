//
//  M2DWebViewController.h
//  BoostMedia
//
//  Created by Akira Matsuda on 2013/01/11.
//  Copyright (c) 2013年 akira.matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class M2DWebViewController;

@protocol M2DWebViewControllerDelegate <NSObject>
@optional
- (void)webViewControllerActionButtonPressed:(M2DWebViewController *)webViewController;

@end

@interface M2DWebViewController : UIViewController <UIWebViewDelegate>
{
	NSURL *url_;
	UIWebView *webView_;
	UIBarButtonItem *goForwardButton_;
	UIBarButtonItem *goBackButton_;
	UIBarButtonItem *actionButton_;
}

@property (assign, nonatomic) id <M2DWebViewControllerDelegate>delegate;
@property (assign, nonatomic) BOOL smoothScroll;
@property (nonatomic, readonly) UIWebView *webView;

- (instancetype)initWithURL:(NSURL *)url;
- (void)goForward:(id)sender;
- (void)goBack:(id)sender;
- (void)refresh:(id)sender;
- (void)doAction:(id)sender;
- (void)loadURL:(NSURL *)url;
- (void)setSmoothScroll:(BOOL)smoothScroll;

@end
