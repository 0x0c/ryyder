//
//  LDRFeed.m
//
//  Created by   on 8/19/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "LDRFeed.h"
#import "LDRGatekeeper.h"

NSString *const kLDRFeedFolder = @"folder";
NSString *const kLDRFeedModifiedOn = @"modified_on";
NSString *const kLDRFeedSubscribersCount = @"subscribers_count";
NSString *const kLDRFeedLink = @"link";
NSString *const kLDRFeedTags = @"tags";
NSString *const kLDRFeedUnreadCount = @"unread_count";
NSString *const kLDRFeedTitle = @"title";
NSString *const kLDRFeedFeedlink = @"feedlink";
NSString *const kLDRFeedSubscribeId = @"subscribe_id";
NSString *const kLDRFeedIcon = @"icon";
NSString *const kLDRFeedRate = @"rate";
NSString *const kLDRFeedPublic = @"public";


@interface LDRFeed ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@interface LDRFeed()
{
	BOOL fetching;
}

@end

@implementation LDRFeed

@synthesize folder = _folder;
@synthesize modifiedOn = _modifiedOn;
@synthesize subscribersCount = _subscribersCount;
@synthesize link = _link;
@synthesize tags = _tags;
@synthesize unreadCount = _unreadCount;
@synthesize title = _title;
@synthesize feedlink = _feedlink;
@synthesize subscribeIdentifier = _subscribeIdentifier;
@synthesize icon = _icon;
@synthesize rate = _rate;
@synthesize publicProperty = _publicProperty;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.folder = [self objectOrNilForKey:kLDRFeedFolder fromDictionary:dict];
            self.modifiedOn = [[self objectOrNilForKey:kLDRFeedModifiedOn fromDictionary:dict] doubleValue];
            self.subscribersCount = [[self objectOrNilForKey:kLDRFeedSubscribersCount fromDictionary:dict] integerValue];
            self.link = [self objectOrNilForKey:kLDRFeedLink fromDictionary:dict];
            self.tags = [self objectOrNilForKey:kLDRFeedTags fromDictionary:dict];
            self.unreadCount = [[self objectOrNilForKey:kLDRFeedUnreadCount fromDictionary:dict] integerValue];
            self.title = [self objectOrNilForKey:kLDRFeedTitle fromDictionary:dict];
            self.feedlink = [self objectOrNilForKey:kLDRFeedFeedlink fromDictionary:dict];
            self.subscribeIdentifier = [NSNumber numberWithInteger:[[self objectOrNilForKey:kLDRFeedSubscribeId fromDictionary:dict] integerValue]];
            self.icon = [self objectOrNilForKey:kLDRFeedIcon fromDictionary:dict];
            self.rate = [[self objectOrNilForKey:kLDRFeedRate fromDictionary:dict] doubleValue];
            self.publicProperty = [[self objectOrNilForKey:kLDRFeedPublic fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.folder forKey:kLDRFeedFolder];
    [mutableDict setValue:[NSNumber numberWithDouble:self.modifiedOn] forKey:kLDRFeedModifiedOn];
    [mutableDict setValue:[NSNumber numberWithDouble:self.subscribersCount] forKey:kLDRFeedSubscribersCount];
    [mutableDict setValue:self.link forKey:kLDRFeedLink];
    NSMutableArray *tempArrayForTags = [NSMutableArray array];
    for (NSObject *subArrayObject in self.tags) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForTags addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForTags addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForTags] forKey:kLDRFeedTags];
    [mutableDict setValue:[NSNumber numberWithDouble:self.unreadCount] forKey:kLDRFeedUnreadCount];
    [mutableDict setValue:self.title forKey:kLDRFeedTitle];
    [mutableDict setValue:self.feedlink forKey:kLDRFeedFeedlink];
    [mutableDict setValue:self.subscribeIdentifier forKey:kLDRFeedSubscribeId];
    [mutableDict setValue:self.icon forKey:kLDRFeedIcon];
    [mutableDict setValue:[NSNumber numberWithDouble:self.rate] forKey:kLDRFeedRate];
    [mutableDict setValue:[NSNumber numberWithDouble:self.publicProperty] forKey:kLDRFeedPublic];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.folder = [aDecoder decodeObjectForKey:kLDRFeedFolder];
    self.modifiedOn = [aDecoder decodeDoubleForKey:kLDRFeedModifiedOn];
    self.subscribersCount = [aDecoder decodeDoubleForKey:kLDRFeedSubscribersCount];
    self.link = [aDecoder decodeObjectForKey:kLDRFeedLink];
    self.tags = [aDecoder decodeObjectForKey:kLDRFeedTags];
    self.unreadCount = [aDecoder decodeDoubleForKey:kLDRFeedUnreadCount];
    self.title = [aDecoder decodeObjectForKey:kLDRFeedTitle];
    self.feedlink = [aDecoder decodeObjectForKey:kLDRFeedFeedlink];
    self.subscribeIdentifier = [aDecoder decodeObjectForKey:kLDRFeedSubscribeId];
    self.icon = [aDecoder decodeObjectForKey:kLDRFeedIcon];
    self.rate = [aDecoder decodeDoubleForKey:kLDRFeedRate];
    self.publicProperty = [aDecoder decodeDoubleForKey:kLDRFeedPublic];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_folder forKey:kLDRFeedFolder];
    [aCoder encodeDouble:_modifiedOn forKey:kLDRFeedModifiedOn];
    [aCoder encodeDouble:_subscribersCount forKey:kLDRFeedSubscribersCount];
    [aCoder encodeObject:_link forKey:kLDRFeedLink];
    [aCoder encodeObject:_tags forKey:kLDRFeedTags];
    [aCoder encodeDouble:_unreadCount forKey:kLDRFeedUnreadCount];
    [aCoder encodeObject:_title forKey:kLDRFeedTitle];
    [aCoder encodeObject:_feedlink forKey:kLDRFeedFeedlink];
    [aCoder encodeObject:_subscribeIdentifier forKey:kLDRFeedSubscribeId];
    [aCoder encodeObject:_icon forKey:kLDRFeedIcon];
    [aCoder encodeDouble:_rate forKey:kLDRFeedRate];
    [aCoder encodeDouble:_publicProperty forKey:kLDRFeedPublic];
}

- (id)copyWithZone:(NSZone *)zone
{
    LDRFeed *copy = [[LDRFeed alloc] init];
    
    if (copy) {

        copy.folder = [self.folder copyWithZone:zone];
        copy.modifiedOn = self.modifiedOn;
        copy.subscribersCount = self.subscribersCount;
        copy.link = [self.link copyWithZone:zone];
        copy.tags = [self.tags copyWithZone:zone];
        copy.unreadCount = self.unreadCount;
        copy.title = [self.title copyWithZone:zone];
        copy.feedlink = [self.feedlink copyWithZone:zone];
        copy.subscribeIdentifier = self.subscribeIdentifier;
        copy.icon = [self.icon copyWithZone:zone];
        copy.rate = self.rate;
        copy.publicProperty = self.publicProperty;
    }
    
    return copy;
}

- (void)fetch:(void (^)(NSError *error))completionHandler
{
	@synchronized(self) {
		if (fetching == NO) {
			fetching = YES;
			LDRGatekeeper *sharedGatekeeper = [LDRGatekeeper sharedInstance];
			LDRGatekeeper *gatekeeper = [LDRGatekeeper new];
#ifdef DEBUG
			gatekeeper.debugMode = YES;
#endif
			[gatekeeper resultConditionBlock:sharedGatekeeper.resultConditionBlock];
			[gatekeeper parseBlock:sharedGatekeeper.parseBlock];
//			[gatekeeper setBaseParameter:sharedGatekeeper.baseParameter];
			[gatekeeper getUnreadArticlesWithSubsucribeId:[self.subscribeIdentifier stringValue] completionHandler:^(id result, NSError *error) {
				self.data = result;
				self.data.parent = self;
				self.fetched = error == nil ? YES : NO;
				completionHandler(error);
			}];
		}
	}
}

- (void)setUnreadCount:(NSInteger)unreadCount
{
	_unreadCount = MAX(unreadCount, 0);
	[[NSNotificationCenter defaultCenter] postNotificationName:LDFeedUnreadCountDidChangeNotification object:@{@"count":@(_unreadCount), @"subscribeIdentifier":self.subscribeIdentifier?:[NSNull null]}];
	if (_unreadCount == 0) {
		[[LDRGatekeeper sharedInstance] addPreparedSubscribeIdentifier:[self.subscribeIdentifier stringValue]];
	}
}

@end
