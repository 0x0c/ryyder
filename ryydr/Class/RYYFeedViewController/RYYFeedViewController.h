//
//  RYYFeedViewController.h
//  ryyder
//
//  Created by Akira Matsuda on 8/19/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const RYYFeedViewControllerNeedToRefreshNotification = @"RYYFeedViewControllerNeedToRefreshNotification";

@interface RYYFeedViewController : UITableViewController

- (void)sync;

@end
