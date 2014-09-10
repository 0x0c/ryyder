//
//  LDRFeed.h
//
//  Created by   on 8/19/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDRArticleData.h"

static NSString *const LDFeedUnreadCountDidChangeNotification = @"LDFeedUnreadCountDidChangeNotification";

@interface LDRFeed : NSObject <NSCoding, NSCopying>

@property (nonatomic, weak) LDRFeed *previousFeed;
@property (nonatomic, weak) LDRFeed *nextFeed;
@property (nonatomic, strong) LDRArticleData *data;
@property (nonatomic, assign) BOOL fetched;
@property (nonatomic, strong) NSString *folder;
@property (nonatomic, assign) double modifiedOn;
@property (nonatomic, assign) NSUInteger subscribersCount;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *feedlink;
@property (nonatomic, assign) NSNumber *subscribeIdentifier;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, assign) double rate;
@property (nonatomic, assign) double publicProperty;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;
- (void)fetch:(void (^)(NSError *error))completionHandler;

@end
