//
//  LDRArticle.m
//
//  Created by   on 8/19/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "LDRArticleData.h"
#import "LDRChannel.h"
#import "LDRArticleItem.h"
#import "LDRAds.h"


NSString *const kLDRArticleSubscribeId = @"subscribe_id";
NSString *const kLDRArticleChannel = @"channel";
NSString *const kLDRArticleItems = @"items";
NSString *const kLDRArticleAds = @"ads";
NSString *const kLDRArticleLastStoredOn = @"last_stored_on";


@interface LDRArticleData ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LDRArticleData

@synthesize subscribeIdentifier = _subscribeIdentifier;
@synthesize channel = _channel;
@synthesize items = _items;
@synthesize ads = _ads;
@synthesize lastStoredOn = _lastStoredOn;


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
            self.subscribeIdentifier = [self objectOrNilForKey:kLDRArticleSubscribeId fromDictionary:dict];
            self.channel = [LDRChannel modelObjectWithDictionary:[dict objectForKey:kLDRArticleChannel]];
    NSObject *receivedLDRItems = [dict objectForKey:kLDRArticleItems];
    NSMutableArray *parsedLDRItems = [NSMutableArray array];
    if ([receivedLDRItems isKindOfClass:[NSArray class]]) {
		__block LDRArticleItem *previousItem = nil;
		[(NSArray *)receivedLDRItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary *item = obj;
			if ([item isKindOfClass:[NSDictionary class]]) {
				LDRArticleItem *articleItem = [LDRArticleItem modelObjectWithDictionary:item];
				articleItem.index = idx;
				articleItem.previous = previousItem;
				articleItem.previous.next = articleItem;
				previousItem = articleItem;
				
				articleItem.parent = self;
				[parsedLDRItems addObject:articleItem];
			}
		}];
    } else if ([receivedLDRItems isKindOfClass:[NSDictionary class]]) {
		LDRArticleItem *articleItem = [LDRArticleItem modelObjectWithDictionary:(NSDictionary *)receivedLDRItems];
		articleItem.parent = self;
       [parsedLDRItems addObject:articleItem];
    }

    self.items = [NSArray arrayWithArray:parsedLDRItems];
    NSObject *receivedLDRAds = [dict objectForKey:kLDRArticleAds];
    NSMutableArray *parsedLDRAds = [NSMutableArray array];
    if ([receivedLDRAds isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedLDRAds) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedLDRAds addObject:[LDRAds modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedLDRAds isKindOfClass:[NSDictionary class]]) {
       [parsedLDRAds addObject:[LDRAds modelObjectWithDictionary:(NSDictionary *)receivedLDRAds]];
    }

    self.ads = [NSArray arrayWithArray:parsedLDRAds];
            self.lastStoredOn = [[self objectOrNilForKey:kLDRArticleLastStoredOn fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.subscribeIdentifier forKey:kLDRArticleSubscribeId];
    [mutableDict setValue:[self.channel dictionaryRepresentation] forKey:kLDRArticleChannel];
    NSMutableArray *tempArrayForItems = [NSMutableArray array];
    for (NSObject *subArrayObject in self.items) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForItems addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForItems addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForItems] forKey:kLDRArticleItems];
    NSMutableArray *tempArrayForAds = [NSMutableArray array];
    for (NSObject *subArrayObject in self.ads) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForAds addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForAds addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForAds] forKey:kLDRArticleAds];
    [mutableDict setValue:[NSNumber numberWithDouble:self.lastStoredOn] forKey:kLDRArticleLastStoredOn];

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

    self.subscribeIdentifier = [aDecoder decodeObjectForKey:kLDRArticleSubscribeId];
    self.channel = [aDecoder decodeObjectForKey:kLDRArticleChannel];
    self.items = [aDecoder decodeObjectForKey:kLDRArticleItems];
    self.ads = [aDecoder decodeObjectForKey:kLDRArticleAds];
    self.lastStoredOn = [aDecoder decodeDoubleForKey:kLDRArticleLastStoredOn];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_subscribeIdentifier forKey:kLDRArticleSubscribeId];
    [aCoder encodeObject:_channel forKey:kLDRArticleChannel];
    [aCoder encodeObject:_items forKey:kLDRArticleItems];
    [aCoder encodeObject:_ads forKey:kLDRArticleAds];
    [aCoder encodeDouble:_lastStoredOn forKey:kLDRArticleLastStoredOn];
}

- (id)copyWithZone:(NSZone *)zone
{
    LDRArticleData *copy = [[LDRArticleData alloc] init];
    
    if (copy) {

        copy.subscribeIdentifier = [self.subscribeIdentifier copyWithZone:zone];
        copy.channel = [self.channel copyWithZone:zone];
        copy.items = [self.items copyWithZone:zone];
        copy.ads = [self.ads copyWithZone:zone];
        copy.lastStoredOn = self.lastStoredOn;
    }
    
    return copy;
}


@end
