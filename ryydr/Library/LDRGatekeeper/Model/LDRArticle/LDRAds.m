//
//  LDRAds.m
//
//  Created by   on 8/19/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "LDRAds.h"


NSString *const kLDRAdsUrl = @"url";
NSString *const kLDRAdsTitle = @"title";
NSString *const kLDRAdsDescription = @"description";


@interface LDRAds ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LDRAds

@synthesize url = _url;
@synthesize title = _title;
@synthesize adsDescription = _adsDescription;


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
            self.url = [self objectOrNilForKey:kLDRAdsUrl fromDictionary:dict];
            self.title = [self objectOrNilForKey:kLDRAdsTitle fromDictionary:dict];
            self.adsDescription = [self objectOrNilForKey:kLDRAdsDescription fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.url forKey:kLDRAdsUrl];
    [mutableDict setValue:self.title forKey:kLDRAdsTitle];
    [mutableDict setValue:self.adsDescription forKey:kLDRAdsDescription];

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

    self.url = [aDecoder decodeObjectForKey:kLDRAdsUrl];
    self.title = [aDecoder decodeObjectForKey:kLDRAdsTitle];
    self.adsDescription = [aDecoder decodeObjectForKey:kLDRAdsDescription];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_url forKey:kLDRAdsUrl];
    [aCoder encodeObject:_title forKey:kLDRAdsTitle];
    [aCoder encodeObject:_adsDescription forKey:kLDRAdsDescription];
}

- (id)copyWithZone:(NSZone *)zone
{
    LDRAds *copy = [[LDRAds alloc] init];
    
    if (copy) {

        copy.url = [self.url copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.adsDescription = [self.adsDescription copyWithZone:zone];
    }
    
    return copy;
}


@end
