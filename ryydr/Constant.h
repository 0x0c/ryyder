//
//  Constant.h
//  ryyder
//
//  Created by Akira Matsuda on 8/19/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#ifndef ryyder_Constant_h
#define ryyder_Constant_h

static NSString *const ServiceIdentifier = @"ryyder";

static NSString *const UserInterfaceAlignmentKey = @"UserInterfaceAlignmentKey";
static NSString *const DirectAccessKey = @"DirectAccessKey";
static NSString *const ShowBadgeKey = @"ShowBadgeKey";
static NSString *const SyncAtLaunchKey = @"SyncAtLaunchKey";
static NSString *const MarkAsReadImmediatelyKey = @"MarkAsReadImmediatelyKey";
static NSString *const ShowTipsKey = @"ShowTipsKey";
static NSString *const MarkAsReadTipsAlreadyShowKey = @"MarkAsReadTipsAlreadyShowKey";
static NSString *const PinnedListTipsAlreadyShowKey = @"PinnedListTipsAlreadyShowKey";
static NSString *const ShowNotificationKey = @"ShowNotificationKey";

static NSString *const FirstLaunchKey = @"FirstLaunchKey";

//for Feedly Oauth2(sandbox)
static NSString *const kOauth2ClientAccountType = @"Feedly";
static NSString *const kOauth2ClientClientId = @"sandbox";
static NSString *const kOauth2ClientClientSecret = @"A0SXFX54S3K0OC9GNCXG";
static NSString *const kOauth2ClientRedirectUrl = @"http://localhost";
static NSString *const kOauth2ClientBaseUrl = @"https://sandbox.feedly.com";
static NSString *const kOauth2ClientAuthUrl = @"/v3/auth/auth";
static NSString *const kOauth2ClientTokenUrl = @"/v3/auth/token";
static NSString *const kOauth2ClientScopeUrl = @"https://cloud.feedly.com/subscriptions";

#endif
