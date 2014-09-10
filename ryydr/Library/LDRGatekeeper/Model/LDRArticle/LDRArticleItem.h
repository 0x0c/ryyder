//
//  LDRItems.h
//
//  Created by   on 8/19/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDRArticleData.h"

static NSString *const LDRArticleItemReadFlagNotificationYES = @"LDRArticleItemReadFlagNotificationYES";
static NSString *const LDRArticleItemReadFlagNotificationNO = @"LDRArticleItemReadFlagNotificationNO";


@interface LDRArticleItem : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) LDRArticleItem *next;
@property (nonatomic, assign) LDRArticleItem *previous;
@property (nonatomic, weak) LDRArticleData *parent;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *enclosure;
@property (nonatomic, assign) double modifiedOn;
@property (nonatomic, strong) NSString *enclosureType;
@property (nonatomic, strong) NSString *itemIdentifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, assign) double createdOn;
@property (nonatomic, strong) NSString *body;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
