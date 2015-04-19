//
//  LDRPinnedArticle.m
//
//  Created by   on 8/21/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "LDRPinnedArticle.h"


NSString *const kLDRPinnedArticleLink = @"link";
NSString *const kLDRPinnedArticleTitle = @"title";
NSString *const kLDRPinnedArticleCreatedOn = @"created_on";


@interface LDRPinnedArticle ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LDRPinnedArticle

@synthesize link = _link;
@synthesize title = _title;
@synthesize createdOn = _createdOn;


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
            self.link = [self objectOrNilForKey:kLDRPinnedArticleLink fromDictionary:dict];
            self.title = [self objectOrNilForKey:kLDRPinnedArticleTitle fromDictionary:dict];
            self.createdOn = [[self objectOrNilForKey:kLDRPinnedArticleCreatedOn fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.link forKey:kLDRPinnedArticleLink];
    [mutableDict setValue:self.title forKey:kLDRPinnedArticleTitle];
    [mutableDict setValue:[NSNumber numberWithDouble:self.createdOn] forKey:kLDRPinnedArticleCreatedOn];

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

    self.link = [aDecoder decodeObjectForKey:kLDRPinnedArticleLink];
    self.title = [aDecoder decodeObjectForKey:kLDRPinnedArticleTitle];
    self.createdOn = [aDecoder decodeDoubleForKey:kLDRPinnedArticleCreatedOn];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_link forKey:kLDRPinnedArticleLink];
    [aCoder encodeObject:_title forKey:kLDRPinnedArticleTitle];
    [aCoder encodeDouble:_createdOn forKey:kLDRPinnedArticleCreatedOn];
}

- (id)copyWithZone:(NSZone *)zone
{
    LDRPinnedArticle *copy = [[LDRPinnedArticle alloc] init];
    
    if (copy) {

        copy.link = [self.link copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.createdOn = self.createdOn;
    }
    
    return copy;
}


@end
