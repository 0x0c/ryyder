//
//  RYYArticleTableViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 8/19/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYArticleTableViewController.h"
#import "RYYWebViewController.h"
#import "RYYArticleDescriptionViewController.h"
#import "LKBadgeView.h"
#import "FAKFontAwesome.h"
#import "LDRGatekeeper.h"
#import "CMPopTipView.h"

@interface RYYArticleTableViewController ()
{
	UIBarButtonItem *upButtonItem;
	UIBarButtonItem *downButtonItem;
}

@end

@implementation RYYArticleTableViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	FAKFontAwesome *up = [FAKFontAwesome angleUpIconWithSize:25];
	FAKFontAwesome *down = [FAKFontAwesome angleDownIconWithSize:25];
	upButtonItem = [[UIBarButtonItem alloc] initWithImage:[up imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[up imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(up)];
	downButtonItem = [[UIBarButtonItem alloc] initWithImage:[down imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[down imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(down)];
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	FAKFontAwesome *mark = [FAKFontAwesome circleThinIconWithSize:20];
	UIBarButtonItem *markAsRead = [[UIBarButtonItem alloc] initWithImage:[mark imageWithSize:CGSizeMake(30, 30)] landscapeImagePhone:[mark imageWithSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(markAsRead)];
	[self setToolbarItems:@[markAsRead, flexibleSpace, upButtonItem, downButtonItem] animated:animated];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:ShowTipsKey] == YES && [[NSUserDefaults standardUserDefaults] boolForKey:MarkAsReadTipsAlreadyShowKey] == NO) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:MarkAsReadTipsAlreadyShowKey];
		[[NSUserDefaults standardUserDefaults] setBool:!(YES && [[NSUserDefaults standardUserDefaults] boolForKey:PinnedListTipsAlreadyShowKey]) forKey:ShowTipsKey];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			CMPopTipView *pop = [[CMPopTipView alloc] initWithMessage:@"Mark all as read"];
			pop.hasShadow = NO;
			pop.hasGradientBackground = NO;
			pop.has3DStyle = NO;
			pop.borderColor = self.view.tintColor;
			pop.backgroundColor = self.view.tintColor;
			[pop autoDismissAnimated:YES atTimeInterval:2];
			[pop presentPointingAtBarButtonItem:markAsRead animated:YES];
		});
	}

	upButtonItem.enabled = (self.feed.previousFeed != nil);
	downButtonItem.enabled = (self.feed.nextFeed != nil);
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.tableView reloadData];
}

- (void)setFeed:(LDRFeed *)feed
{
	_feed = feed;
	
	upButtonItem.enabled = (feed.previousFeed != nil);
	downButtonItem.enabled = (feed.nextFeed != nil);
	if (feed.fetched == NO) {
		__weak typeof(self) bself = self;
		__weak typeof(_feed) bfeed = _feed;
		[feed fetch:^(NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				bself.title = bfeed.title;
				[bself.tableView reloadData];
			});
		}];
	}
	else {
		self.title = feed.title;
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _feed.data.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.textLabel.numberOfLines = 2;
		cell.textLabel.font = [UIFont systemFontOfSize:15];
		cell.detailTextLabel.textColor = self.view.tintColor;
		
		UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(38, 0, 10, 20)];
		FAKFontAwesome *font = [FAKFontAwesome chevronRightIconWithSize:10];
		[font addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
		[arrowImageView setImage:[font imageWithSize:CGSizeMake(10, 20)]];
		cell.accessoryView = arrowImageView;
		
		UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(directAccess:)];
		[cell.contentView addGestureRecognizer:gesture];
	}
    
	cell.contentView.tag = indexPath.row;
	
	LDRArticleItem *item = _feed.data.items[indexPath.row];
	cell.textLabel.text = item.title;
	cell.detailTextLabel.text = item.category;
	
	if (item.read == YES) {
		cell.textLabel.textColor = [UIColor lightGrayColor];
	}
	else {
		cell.textLabel.textColor = [UIColor blackColor];
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	id viewController = nil;
	LDRArticleItem *item = _feed.data.items[indexPath.row];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:MarkAsReadImmediatelyKey]) {
		item.read = YES;
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:DirectAccessKey]) {
		RYYWebViewController *vc = [[RYYWebViewController alloc] initWithURL:[NSURL URLWithString:item.link]];
		vc.article = item;
		viewController = vc;
	}
	else {
		RYYArticleDescriptionViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RYYArticleDescriptionViewController"];
		vc.article = item;
		viewController = vc;
	}
	
	[self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

#pragma -

- (void)up
{
	if (self.feed.previousFeed) {
		self.feed = self.feed.previousFeed;
	}
}

- (void)down
{
	if (self.feed.nextFeed) {
		self.feed = self.feed.nextFeed;
	}
}

- (void)markAsRead
{
	[_feed.data.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		LDRArticleItem *item = obj;
		item.read = YES;
	}];
	[self.tableView reloadData];
}

- (void)directAccess:(id)sender
{
	UIGestureRecognizer *gesture = sender;
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan: {
			UIView *view = gesture.view;
			LDRArticleItem *item = _feed.data.items[view.tag];
			RYYWebViewController *viewController = [[RYYWebViewController alloc] initWithURL:[NSURL URLWithString:item.link]];
			viewController.article = item;
			if ([[NSUserDefaults standardUserDefaults] boolForKey:MarkAsReadImmediatelyKey]) {
				item.read = YES;
			}
			[self.navigationController pushViewController:viewController animated:YES];
		}
			break;
		default:
			break;
	}
}

@end
