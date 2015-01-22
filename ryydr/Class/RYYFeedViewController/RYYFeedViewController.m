//
//  RYYFeedViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 8/19/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYFeedViewController.h"
#import "AppDelegate.h"
#import "TSMessage.h"
#import "RYYArticleDescriptionViewController.h"
#import "RYYArticleTableViewController.h"
#import "RYYSettingViewController.h"
#import "FAKFontAwesome.h"
#import "LDRGatekeeper.h"
#import "LKBadgeView.h"
#import "CMPopTipView.h"
#import "GLDTween.h"

@interface RYYFeedViewController () {
	NSArray *feeds;
	IBOutlet UIBarButtonItem *settingButtonItem;
	IBOutlet UIBarButtonItem *pinButtonItem;
	IBOutlet UIBarButtonItem *refreshButtonItem;
}

@end

@implementation RYYFeedViewController

static CGFloat kIconButtonSize = 27;

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.navigationController setToolbarHidden:NO animated:NO];
	settingButtonItem.image = [[FAKFontAwesome gearIconWithSize:kIconButtonSize] imageWithSize:CGSizeMake(25, 25)];
	pinButtonItem.image = [[FAKFontAwesome dotCircleOIconWithSize:kIconButtonSize] imageWithSize:CGSizeMake(25, 25)];

	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(sync) forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refreshControl;

	if ([LDRGatekeeper sharedInstance].username.length == 0 && [LDRGatekeeper sharedInstance].password.length == 0) {
		UINavigationController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RYYSettingViewControllerModal"];
		[self presentViewController:viewController animated:YES completion:^{
		}];
	}
	else {
		[[LDRGatekeeper sharedInstance] loginWithCompetionHandler:^(NSError *error) {
			if (error) {
				[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
				[TSMessage showNotificationWithTitle:@"Error" subtitle:error.localizedDescription type:TSMessageNotificationTypeError];
			}
			else {
				[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
				static dispatch_once_t onceToken;
				dispatch_once(&onceToken, ^{
					if ([[NSUserDefaults standardUserDefaults] boolForKey:SyncAtLaunchKey]) {
						[self sync];
					}
				});
			}
		}];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sync) name:RYYFeedViewControllerNeedToRefreshNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

	if ([[NSUserDefaults standardUserDefaults] boolForKey:ShowTipsKey] == YES && [[NSUserDefaults standardUserDefaults] boolForKey:PinnedListTipsAlreadyShowKey] == NO) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:PinnedListTipsAlreadyShowKey];
		[[NSUserDefaults standardUserDefaults] setBool:!(YES && [[NSUserDefaults standardUserDefaults] boolForKey:MarkAsReadTipsAlreadyShowKey])forKey:ShowTipsKey];

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			CMPopTipView *pop = [[CMPopTipView alloc] initWithMessage:@"Pinned list"];
			pop.hasShadow = NO;
			pop.hasGradientBackground = NO;
			pop.has3DStyle = NO;
			pop.borderColor = self.view.tintColor;
			pop.backgroundColor = self.view.tintColor;
			[pop autoDismissAnimated:YES atTimeInterval:2];
			[pop presentPointingAtBarButtonItem:pinButtonItem animated:YES];
		});
	}

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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.textLabel.numberOfLines = 2;
		cell.textLabel.font = [UIFont systemFontOfSize:15];
		cell.detailTextLabel.textColor = self.view.tintColor;

		LKBadgeView *badgeView = [[LKBadgeView alloc] initWithFrame:CGRectMake(0, 0, 35, 20)];
		badgeView.tag = 1;
		badgeView.font = [UIFont systemFontOfSize:12];
		badgeView.badgeColor = self.view.tintColor;

		UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(38, 0, 10, 20)];
		FAKFontAwesome *font = [FAKFontAwesome chevronRightIconWithSize:10];
		[font addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
		[arrowImageView setImage:[font imageWithSize:CGSizeMake(10, 20)]];
		UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(badgeView.frame) + CGRectGetWidth(arrowImageView.frame), 20)];
		[baseView addSubview:badgeView];
		[baseView addSubview:arrowImageView];
		cell.accessoryView = baseView;

		//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadCountDidChange:) name:LDFeedUnreadCountDidChangeNotification object:nil];
	}

	cell.tag = indexPath.row;

	LKBadgeView *badgeView = (LKBadgeView *)[cell.accessoryView viewWithTag:1];
	LDRFeed *feed = feeds[indexPath.row];
	if (feed.fetched == NO) {
		cell.textLabel.textColor = [UIColor lightGrayColor];
		badgeView.alpha = 0;

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[GLDTween addTween:badgeView withParams:@{@"duration":@0,
													  @"x":@25}];
			[GLDTween addTween:badgeView withParams:@{@"duration":@0.5,
													  @"delay":@0.2,
													  @"easing":GLDEasingOutQuint,
													  @"x":@0}];
			[GLDTween addTween:badgeView withParams:@{@"duration":@0.4,
													  @"delay":@0.2,
													  @"alpha":@1.0}];
		});
	}
	else {
		cell.textLabel.textColor = [UIColor blackColor];
	}

	cell.textLabel.text = feed.title;

	UIColor *cellBackgroundColor = self.view.tintColor;
	if (feed.unreadCount == 0) {
		cellBackgroundColor = [UIColor lightGrayColor];
	}

	badgeView.badgeColor = cellBackgroundColor;
	badgeView.text = [@(feed.unreadCount) stringValue];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	LDRFeed *feed = feeds[indexPath.row];
	if (feed.fetched) {
		RYYArticleTableViewController *viewController = [[RYYArticleTableViewController alloc] initWithStyle:UITableViewStylePlain];
		viewController.feed = feed;
		viewController.title = feed.title;
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return feeds.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	__weak typeof(self) bself = self;
	NSOperationQueue *q = [[NSOperationQueue alloc] init];
	[q setMaxConcurrentOperationCount:3];
	LDRFeed *f = feeds[indexPath.row];
	[q addOperationWithBlock:^{
		[f fetch:^(NSError *error) {
			if (error == nil) {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[bself.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
				});
			}
		}];
	}];

	return 50;
}

#pragma mark -

- (void)restore
{
}

- (void)save
{
}

- (void)sync
{
	refreshButtonItem.enabled = NO;
	[self.refreshControl beginRefreshing];
	__weak typeof(self) bself = self;
	LDRGatekeeper *sharedGatekeeper = [LDRGatekeeper sharedInstance];
	LDRGatekeeper *gatekeeper = [LDRGatekeeper new];
	gatekeeper.preparedSubscribeIdentifier = sharedGatekeeper.preparedSubscribeIdentifier;
	[[gatekeeper parseBlock:sharedGatekeeper.parseBlock] resultConditionBlock:sharedGatekeeper.resultConditionBlock];

	NSOperationQueue *o = [NSOperationQueue currentQueue];
	[o setMaxConcurrentOperationCount:1];
	[o addOperationWithBlock:^{
		[gatekeeper touchPreparedFeed];
	}];
	[o addOperationWithBlock:^{
		[sharedGatekeeper getFeedsWithUnreadArticle:YES completionHandler:^(id result, NSError *error) {
			[bself.refreshControl endRefreshing];
			if (error) {
				[[LDRGatekeeper sharedInstance] loginWithCompetionHandler:^(NSError *error) {
					dispatch_async(dispatch_get_main_queue(), ^{
						if (error) {
							[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
							[TSMessage showNotificationWithTitle:@"Error" subtitle:error.localizedDescription type:TSMessageNotificationTypeError];
						}
						else {
							[self sync];
						}
					});
				}];
			}
			else {
				feeds = [result copy];
				if ([feeds count] == 0) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[TSMessage showNotificationWithTitle:@"No results" subtitle:@"There are no new updates." type:TSMessageNotificationTypeMessage];
					});
				}
				[bself.tableView reloadData];
				refreshButtonItem.enabled = YES;
			}
		}];
	}];
	[o addOperationWithBlock:^{
		[(AppDelegate *)[UIApplication sharedApplication].delegate updateBadgeNumber:^(NSInteger count) {
//			if (count > 0) {
//				self.title = [NSString stringWithFormat:@"ryyder(%ld)", (long)count];
//			}
//			else {
//				self.title = [NSString stringWithFormat:@"ryyder"];
//			}
		}];
	}];

	UIApplication *application = [UIApplication sharedApplication];
	UISplitViewController *splitViewController = (UISplitViewController *)[application.delegate window].rootViewController;
	[[[splitViewController.viewControllers lastObject] topViewController].navigationController popToRootViewControllerAnimated:NO];
	id viewController = [[splitViewController.viewControllers lastObject] topViewController];
	if ([viewController isKindOfClass:[RYYArticleDescriptionViewController class]]) {
		RYYArticleDescriptionViewController *articleDescriptionViewController = (RYYArticleDescriptionViewController *)[[splitViewController.viewControllers lastObject] topViewController];
		articleDescriptionViewController.article = nil;
	}
}

- (IBAction)refreshButtonPressed:(id)sender
{
	[self sync];
}

- (void)unreadCountDidChange:(NSNotification *)notification
{
	NSDictionary *info = notification.object;
	__block NSInteger index = 0;
	[feeds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		LDRFeed *feed = obj;
		if ([[feed.subscribeIdentifier stringValue] isEqualToString:info[@"subscribeIdentifier"]]) {
			index = idx;
			*stop = YES;
		}
	}];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

	LKBadgeView *badgeView = (LKBadgeView *)[cell.accessoryView viewWithTag:1];
	NSInteger count = [info[@"count"] integerValue];
	if (count == 0) {
		badgeView.badgeColor = [UIColor lightGrayColor];
	}
	badgeView.text = [info[@"count"] stringValue];
}

@end
