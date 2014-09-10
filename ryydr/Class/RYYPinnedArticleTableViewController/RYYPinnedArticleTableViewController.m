//
//  RYYPinnedArticleTableViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 8/20/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYPinnedArticleTableViewController.h"
#import "RYYWebViewController.h"
#import "TSMessage.h"
#import "FAKFontAwesome.h"
#import "LDRGatekeeper.h"

@interface RYYPinnedArticleTableViewController ()
{
	NSMutableArray *items;
}
@end

@implementation RYYPinnedArticleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = doneButton;
	
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(sync) forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refreshControl;
	
	[self sync];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	self.title = [NSString stringWithFormat:@"Pinned (%lu / 100)", (unsigned long)items.count];
	
    return items.count;
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
		
		UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 10, 20)];
		FAKFontAwesome *font = [FAKFontAwesome chevronRightIconWithSize:10];
		[font addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
		[arrowImageView setImage:[font imageWithSize:CGSizeMake(10, 20)]];
		
		UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(arrowImageView.frame), 20)];
		[baseView addSubview:arrowImageView];
		cell.accessoryView = baseView;
	}
	
	cell.tag = indexPath.row;
	
	LDRPinnedArticle *article = items[indexPath.row];
	cell.textLabel.text = article.title;
	cell.detailTextLabel.text = article.link;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	LDRPinnedArticle *item = items[indexPath.row];
	RYYWebViewController *viewController = [[RYYWebViewController alloc] initWithURL:[NSURL URLWithString:item.link]];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	__weak typeof(tableView) btableView = tableView;
	LDRPinnedArticle *article = items[indexPath.row];
	[[LDRGatekeeper sharedInstance] deletePinnedArticle:article completionHandler:^(NSError *error) {
		if (error) {
			[TSMessage showNotificationWithTitle:@"Error" subtitle:[NSString stringWithFormat:@"Could not delete pinned article.(%@)", error.localizedDescription] type:TSMessageNotificationTypeError];
		}
		else {
			[items removeObjectAtIndex:indexPath.row];
			[btableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		}
	}];
}

#pragma mark -

- (void)sync
{
	[self.refreshControl beginRefreshing];
	__weak typeof(self) bself = self;
	[[LDRGatekeeper sharedInstance] getPinnedArticlesWithCompletionHandler:^(id result, NSError *error) {
		items = [result mutableCopy];
		[bself.tableView reloadData];
		[bself.refreshControl endRefreshing];
	}];
}

- (void)done
{
	[self dismissViewControllerAnimated:YES completion:^{
	}];
}

@end
