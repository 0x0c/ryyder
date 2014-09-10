//
//  LDRChannel.h
//
//  Created by   on 8/19/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface LDRChannel : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *subscribersCount;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *channelDescription;
@property (nonatomic, strong) NSString *feedlink;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, assign) double expires;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
