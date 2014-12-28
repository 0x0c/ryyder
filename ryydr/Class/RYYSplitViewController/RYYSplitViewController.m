//
//  RYYSplitViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 12/29/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYSplitViewController.h"
#import "RYYWebViewController.h"
#import "RYYArticleTableViewController.h"
#import "RYYArticleDescriptionViewController.h"
#import "RYYFeedViewController.h"

@interface RYYSplitViewController () <UISplitViewControllerDelegate>

@end

@implementation RYYSplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
	BOOL result = YES;
	id secondaryVisibleViewController = ((UINavigationController *)secondaryViewController).visibleViewController;
	id primaryVisibleViewController = ((UINavigationController *)primaryViewController).visibleViewController;
	if ([secondaryVisibleViewController isKindOfClass:[RYYWebViewController class]]) {
		result = NO;
	}
	if ([secondaryVisibleViewController isKindOfClass:[RYYArticleDescriptionViewController class]]) {
		result = ((RYYArticleDescriptionViewController *)secondaryVisibleViewController).article == nil;
	}
	if ([primaryVisibleViewController isKindOfClass:[RYYFeedViewController class]]) {
		result = YES;
	}
	
	return result;
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
	UIViewController *viewController = [[splitViewController.viewControllers lastObject] topViewController];
	id primaryVisibleViewController = ((UINavigationController *)primaryViewController).visibleViewController;
	if ([primaryVisibleViewController isKindOfClass:[RYYFeedViewController class]]) {
		RYYArticleDescriptionViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RYYArticleDescriptionViewController"];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
		viewController = navigationController;
	}
	
	return viewController;
}

@end
