//
//  LDRItems.m
//
//  Created by   on 8/19/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "LDRArticleItem.h"
#import "LDRFeed.h"

NSString *const kLDRItemsCategory = @"category";
NSString *const kLDRItemsAuthor = @"author";
NSString *const kLDRItemsEnclosure = @"enclosure";
NSString *const kLDRItemsModifiedOn = @"modified_on";
NSString *const kLDRItemsEnclosureType = @"enclosure_type";
NSString *const kLDRItemsId = @"id";
NSString *const kLDRItemsTitle = @"title";
NSString *const kLDRItemsLink = @"link";
NSString *const kLDRItemsCreatedOn = @"created_on";
NSString *const kLDRItemsBody = @"body";


@interface LDRArticleItem ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LDRArticleItem

@synthesize category = _category;
@synthesize author = _author;
@synthesize enclosure = _enclosure;
@synthesize modifiedOn = _modifiedOn;
@synthesize enclosureType = _enclosureType;
@synthesize itemIdentifier = _itemIdentifier;
@synthesize title = _title;
@synthesize link = _link;
@synthesize createdOn = _createdOn;
@synthesize body = _body;


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
            self.category = [self objectOrNilForKey:kLDRItemsCategory fromDictionary:dict];
            self.author = [self objectOrNilForKey:kLDRItemsAuthor fromDictionary:dict];
            self.enclosure = [self objectOrNilForKey:kLDRItemsEnclosure fromDictionary:dict];
            self.modifiedOn = [[self objectOrNilForKey:kLDRItemsModifiedOn fromDictionary:dict] doubleValue];
            self.enclosureType = [self objectOrNilForKey:kLDRItemsEnclosureType fromDictionary:dict];
            self.itemIdentifier = [self objectOrNilForKey:kLDRItemsId fromDictionary:dict];
            self.title = [self objectOrNilForKey:kLDRItemsTitle fromDictionary:dict];
            self.link = [self objectOrNilForKey:kLDRItemsLink fromDictionary:dict];
            self.createdOn = [[self objectOrNilForKey:kLDRItemsCreatedOn fromDictionary:dict] doubleValue];
            self.body = [self objectOrNilForKey:kLDRItemsBody fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.category forKey:kLDRItemsCategory];
    [mutableDict setValue:self.author forKey:kLDRItemsAuthor];
    [mutableDict setValue:self.enclosure forKey:kLDRItemsEnclosure];
    [mutableDict setValue:[NSNumber numberWithDouble:self.modifiedOn] forKey:kLDRItemsModifiedOn];
    [mutableDict setValue:self.enclosureType forKey:kLDRItemsEnclosureType];
    [mutableDict setValue:self.itemIdentifier forKey:kLDRItemsId];
    [mutableDict setValue:self.title forKey:kLDRItemsTitle];
    [mutableDict setValue:self.link forKey:kLDRItemsLink];
    [mutableDict setValue:[NSNumber numberWithDouble:self.createdOn] forKey:kLDRItemsCreatedOn];
    [mutableDict setValue:self.body forKey:kLDRItemsBody];

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

    self.category = [aDecoder decodeObjectForKey:kLDRItemsCategory];
    self.author = [aDecoder decodeObjectForKey:kLDRItemsAuthor];
    self.enclosure = [aDecoder decodeObjectForKey:kLDRItemsEnclosure];
    self.modifiedOn = [aDecoder decodeDoubleForKey:kLDRItemsModifiedOn];
    self.enclosureType = [aDecoder decodeObjectForKey:kLDRItemsEnclosureType];
    self.itemIdentifier = [aDecoder decodeObjectForKey:kLDRItemsId];
    self.title = [aDecoder decodeObjectForKey:kLDRItemsTitle];
    self.link = [aDecoder decodeObjectForKey:kLDRItemsLink];
    self.createdOn = [aDecoder decodeDoubleForKey:kLDRItemsCreatedOn];
    self.body = [aDecoder decodeObjectForKey:kLDRItemsBody];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_category forKey:kLDRItemsCategory];
    [aCoder encodeObject:_author forKey:kLDRItemsAuthor];
    [aCoder encodeObject:_enclosure forKey:kLDRItemsEnclosure];
    [aCoder encodeDouble:_modifiedOn forKey:kLDRItemsModifiedOn];
    [aCoder encodeObject:_enclosureType forKey:kLDRItemsEnclosureType];
    [aCoder encodeObject:_itemIdentifier forKey:kLDRItemsId];
    [aCoder encodeObject:_title forKey:kLDRItemsTitle];
    [aCoder encodeObject:_link forKey:kLDRItemsLink];
    [aCoder encodeDouble:_createdOn forKey:kLDRItemsCreatedOn];
    [aCoder encodeObject:_body forKey:kLDRItemsBody];
}

- (id)copyWithZone:(NSZone *)zone
{
    LDRArticleItem *copy = [[LDRArticleItem alloc] init];
    
    if (copy) {

        copy.category = [self.category copyWithZone:zone];
        copy.author = [self.author copyWithZone:zone];
        copy.enclosure = [self.enclosure copyWithZone:zone];
        copy.modifiedOn = self.modifiedOn;
        copy.enclosureType = [self.enclosureType copyWithZone:zone];
        copy.itemIdentifier = [self.itemIdentifier copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.link = [self.link copyWithZone:zone];
        copy.createdOn = self.createdOn;
        copy.body = [self.body copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - 

- (void)setRead:(BOOL)read
{
	if (_read == NO && read == YES) {
		self.parent.parent.unreadCount--;
	}
	else if (_read == YES && read == NO){
		self.parent.parent.unreadCount++;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:read == YES ? LDRArticleItemReadFlagNotificationYES : LDRArticleItemReadFlagNotificationNO object:nil];
	_read = read;
}


@end
