//
//  LDRChannel.m
//
//  Created by   on 8/19/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "LDRChannel.h"


NSString *const kLDRChannelTitle = @"title";
NSString *const kLDRChannelImage = @"image";
NSString *const kLDRChannelSubscribersCount = @"subscribers_count";
NSString *const kLDRChannelLink = @"link";
NSString *const kLDRChannelDescription = @"description";
NSString *const kLDRChannelFeedlink = @"feedlink";
NSString *const kLDRChannelIcon = @"icon";
NSString *const kLDRChannelExpires = @"expires";


@interface LDRChannel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LDRChannel

@synthesize title = _title;
@synthesize image = _image;
@synthesize subscribersCount = _subscribersCount;
@synthesize link = _link;
@synthesize channelDescription = _channelDescription;
@synthesize feedlink = _feedlink;
@synthesize icon = _icon;
@synthesize expires = _expires;


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
            self.title = [self objectOrNilForKey:kLDRChannelTitle fromDictionary:dict];
            self.image = [self objectOrNilForKey:kLDRChannelImage fromDictionary:dict];
            self.subscribersCount = [self objectOrNilForKey:kLDRChannelSubscribersCount fromDictionary:dict];
            self.link = [self objectOrNilForKey:kLDRChannelLink fromDictionary:dict];
            self.channelDescription = [self objectOrNilForKey:kLDRChannelDescription fromDictionary:dict];
            self.feedlink = [self objectOrNilForKey:kLDRChannelFeedlink fromDictionary:dict];
            self.icon = [self objectOrNilForKey:kLDRChannelIcon fromDictionary:dict];
            self.expires = [[self objectOrNilForKey:kLDRChannelExpires fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.title forKey:kLDRChannelTitle];
    [mutableDict setValue:self.image forKey:kLDRChannelImage];
    [mutableDict setValue:self.subscribersCount forKey:kLDRChannelSubscribersCount];
    [mutableDict setValue:self.link forKey:kLDRChannelLink];
    [mutableDict setValue:self.channelDescription forKey:kLDRChannelDescription];
    [mutableDict setValue:self.feedlink forKey:kLDRChannelFeedlink];
    [mutableDict setValue:self.icon forKey:kLDRChannelIcon];
    [mutableDict setValue:[NSNumber numberWithDouble:self.expires] forKey:kLDRChannelExpires];

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

    self.title = [aDecoder decodeObjectForKey:kLDRChannelTitle];
    self.image = [aDecoder decodeObjectForKey:kLDRChannelImage];
    self.subscribersCount = [aDecoder decodeObjectForKey:kLDRChannelSubscribersCount];
    self.link = [aDecoder decodeObjectForKey:kLDRChannelLink];
    self.channelDescription = [aDecoder decodeObjectForKey:kLDRChannelDescription];
    self.feedlink = [aDecoder decodeObjectForKey:kLDRChannelFeedlink];
    self.icon = [aDecoder decodeObjectForKey:kLDRChannelIcon];
    self.expires = [aDecoder decodeDoubleForKey:kLDRChannelExpires];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_title forKey:kLDRChannelTitle];
    [aCoder encodeObject:_image forKey:kLDRChannelImage];
    [aCoder encodeObject:_subscribersCount forKey:kLDRChannelSubscribersCount];
    [aCoder encodeObject:_link forKey:kLDRChannelLink];
    [aCoder encodeObject:_channelDescription forKey:kLDRChannelDescription];
    [aCoder encodeObject:_feedlink forKey:kLDRChannelFeedlink];
    [aCoder encodeObject:_icon forKey:kLDRChannelIcon];
    [aCoder encodeDouble:_expires forKey:kLDRChannelExpires];
}

- (id)copyWithZone:(NSZone *)zone
{
    LDRChannel *copy = [[LDRChannel alloc] init];
    
    if (copy) {

        copy.title = [self.title copyWithZone:zone];
        copy.image = [self.image copyWithZone:zone];
        copy.subscribersCount = [self.subscribersCount copyWithZone:zone];
        copy.link = [self.link copyWithZone:zone];
        copy.channelDescription = [self.channelDescription copyWithZone:zone];
        copy.feedlink = [self.feedlink copyWithZone:zone];
        copy.icon = [self.icon copyWithZone:zone];
        copy.expires = self.expires;
    }
    
    return copy;
}


@end
