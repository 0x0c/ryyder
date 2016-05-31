//
//  RYYWebViewController.h
//  ryyder
//
//  Created by Akira Matsuda on 8/20/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "M2DWebViewController.h"
#import "LDRGatekeeper.h"
#import <SafariServices/SafariServices.h>

@interface RYYWebViewController : SFSafariViewController

@property (nonatomic, strong) LDRArticleItem *article;

@end
