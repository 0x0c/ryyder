//
//  RYYLoginViewController.m
//  ryyder
//
//  Created by Akira Matsuda on 8/19/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RYYSettingViewController.h"
#import "RYYFeedViewController.h"
#import "CTFeedbackViewController.h"
#import "TSMessage.h"
#import "SVProgressHUD.h"
#import "LDRGatekeeper.h"
#import "JVFloatLabeledTextField.h"
#import "RYYFeedlyAuthWebViewController.h"

@interface RYYSettingViewController () {
	IBOutlet UISwitch *directAccessSwitch;
	IBOutlet UISwitch *markAsReadImmediatelySwitch;
	IBOutlet UISwitch *showTipsSwitch;
	IBOutlet UISwitch *showBadgeSwitch;
	IBOutlet UISwitch *syncSwitch;
	IBOutlet UISwitch *notificationSwitch;

	IBOutlet UIButton *loginButton;
	IBOutlet JVFloatLabeledTextField *usernameTextField;
	IBOutlet JVFloatLabeledTextField *passwordTextField;
	IBOutlet UILabel *versionStringLabel;
	__weak IBOutlet UISegmentedControl *userInterfaceAlignmentSegmentedControl;

	UITextField *activeTextField;

	BOOL fixed;
}

@end

@implementation RYYSettingViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	if ([[NSUserDefaults standardUserDefaults] boolForKey:FirstLaunchKey]) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:FirstLaunchKey];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:ShowTipsKey];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:MarkAsReadTipsAlreadyShowKey];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:PinnedListTipsAlreadyShowKey];
	}

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	self.navigationItem.rightBarButtonItem = doneButton;

	directAccessSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:DirectAccessKey];
	showBadgeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:ShowBadgeKey];
	//	syncSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:SyncAtLaunchKey];
	showTipsSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:ShowTipsKey];
	markAsReadImmediatelySwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:MarkAsReadImmediatelyKey];
	//	notificationSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:ShowNotificationKey];

	[@[ directAccessSwitch, showBadgeSwitch, showTipsSwitch, markAsReadImmediatelySwitch ] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UISwitch *sw = obj;
		sw.tag = idx;
		[sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
	}];

	loginButton.layer.cornerRadius = 5;
	[loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];

	LDRGatekeeper *gatekeeper = [LDRGatekeeper sharedInstance];
	usernameTextField.tag = 1;
	usernameTextField.delegate = self;
	usernameTextField.text = gatekeeper.username;
	passwordTextField.tag = 2;
	passwordTextField.delegate = self;
	passwordTextField.text = gatekeeper.password;

	userInterfaceAlignmentSegmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:UserInterfaceAlignmentKey];

	NSString *versionNum = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
	NSString *buildNum = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
	versionStringLabel.text = [NSString stringWithFormat:@"Version %@(%@)", versionNum, buildNum];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	if (usernameTextField.text.length > 0) {
		[[LDRGatekeeper sharedInstance] setUsername:usernameTextField.text];
	}
	if (passwordTextField.text.length > 0) {
		[[LDRGatekeeper sharedInstance] setPassword:passwordTextField.text];
	}
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 5 && indexPath.row == 0) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		CTFeedbackViewController *feedbackViewController = [CTFeedbackViewController controllerWithTopics:CTFeedbackViewController.defaultTopics localizedTopics:CTFeedbackViewController.defaultLocalizedTopics];
		feedbackViewController.toRecipients = @[ @"akira.matsuda@me.com" ];
		feedbackViewController.useHTML = YES;
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
		[self presentViewController:navigationController animated:YES completion:^{
			
		}];
	}
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if (activeTextField) {
		[activeTextField resignFirstResponder];
	}
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	LDRGatekeeper *gatekeeper = [LDRGatekeeper sharedInstance];
	if (textField.tag == 1) {
		gatekeeper.username = textField.text;
	}
	else {
		gatekeeper.password = textField.text;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];

	return YES;
}

#pragma mark -

- (void)login
{
	fixed = YES;
	//	RYYFeedlyAuthWebViewController *viewController = [[RYYFeedlyAuthWebViewController alloc] init];
	//	viewController.successBlocks = ^(RYYFeedlyAuthWebViewController *webView, NXOAuth2Account *account) {
	//		[TSMessage showNotificationInViewController:self title:@"Login Success" subtitle:@"Application will automatically sync at launch." type:TSMessageNotificationTypeSuccess];
	//		[webView dismissViewControllerAnimated:YES completion:^{
	//		}];
	//	};
	//	viewController.failuerBlocks = ^(RYYFeedlyAuthWebViewController *webView) {
	//		[TSMessage showNotificationInViewController:self title:@"Login failed" subtitle:@"Please check your username or password." type:TSMessageNotificationTypeError];
	//		[webView dismissViewControllerAnimated:YES completion:^{
	//		}];
	//	};
	//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	//	[self presentViewController:navigationController animated:YES completion:^{
	//	}];

	[activeTextField resignFirstResponder];
	if (usernameTextField.text.length == 0 || passwordTextField.text.length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please input your account information.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
		[alert show];
		return;
	}
	[[LDRGatekeeper sharedInstance] initializeBlock:^(M2DAPIRequest *request, NSDictionary *params) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD show];
		});
	}];
	[[LDRGatekeeper sharedInstance] finalizeBlock:^(M2DAPIRequest *request) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[SVProgressHUD dismiss];
		});
	}];

	LDRGatekeeper *gatekeeper = [LDRGatekeeper sharedInstance];
	[gatekeeper logout];
	[gatekeeper loginWithUsername:usernameTextField.text password:passwordTextField.text competionHandler:^(NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error) {
				[TSMessage showNotificationInViewController:self title:NSLocalizedString(@"Login failed", nil) subtitle:NSLocalizedString(@"Please check your username or password.", nil) type:TSMessageNotificationTypeError];
			}
			else {
				[TSMessage showNotificationInViewController:self title:NSLocalizedString(@"Login succeeded", nil) subtitle:NSLocalizedString(@"Application will automatically sync at launch.", nil) type:TSMessageNotificationTypeSuccess];
			}
		});
	}];
}

- (void)done
{
	if (fixed == YES) {
		[[NSNotificationCenter defaultCenter] postNotificationName:RYYFeedViewControllerNeedToRefreshNotification object:nil];
	}
	[self dismissViewControllerAnimated:YES completion:^{
	}];
}

- (void)switchValueChanged:(id)sender
{
	UISwitch *sw = sender;

	NSArray *array = @[ DirectAccessKey, ShowBadgeKey, ShowTipsKey, MarkAsReadImmediatelyKey ];
	[[NSUserDefaults standardUserDefaults] setBool:sw.on forKey:(NSString *)array[sw.tag]];
	[[NSUserDefaults standardUserDefaults] synchronize];
	if (sw.tag == 1 && sw.on == NO) {
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	}
	else if (sw.tag == 2) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:MarkAsReadTipsAlreadyShowKey];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:PinnedListTipsAlreadyShowKey];
	}
}
- (IBAction)userInterfaceAlignmentSegmentedControlDidValueChanged:(id)sender
{
	UISegmentedControl *control = sender;
	[[NSUserDefaults standardUserDefaults] setInteger:control.selectedSegmentIndex forKey:UserInterfaceAlignmentKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
