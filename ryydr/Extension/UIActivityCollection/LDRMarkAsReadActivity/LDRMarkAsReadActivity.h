//
//  LDRMarkAsReadActivity.h
//  ryyder
//
//  Created by Akira Matsuda on 8/21/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDRGatekeeper.h"

@interface LDRMarkAsReadActivity : UIActivity

@property (nonatomic, strong) LDRArticleItem *article;
@property (nonatomic, strong) LDRGatekeeper *gatekeeper;
@property (nonatomic, copy) void (^completionHandler)(NSError *error);

@end
