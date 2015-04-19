//
//  RYYAuthWebViewController.h
//  ryyder
//
//  Created by Akira Matsuda on 10/7/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYWebViewController.h"
#import "NXOAuth2.h"

@interface RYYFeedlyAuthWebViewController : RYYWebViewController

@property (nonatomic, copy) void (^successBlocks)(RYYFeedlyAuthWebViewController *webView, NXOAuth2Account *account);
@property (nonatomic, copy) void (^failuerBlocks)(RYYFeedlyAuthWebViewController *webView);

@end
