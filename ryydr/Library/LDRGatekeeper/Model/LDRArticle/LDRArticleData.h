//
//  LDRArticle.h
//
//  Created by   on 8/19/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LDRFeed;
@class LDRChannel;

@interface LDRArticleData : NSObject <NSCoding, NSCopying>

@property (nonatomic, weak) LDRFeed *parent;
@property (nonatomic, strong) NSString *subscribeIdentifier;
@property (nonatomic, strong) LDRChannel *channel;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *ads;
@property (nonatomic, assign) double lastStoredOn;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
