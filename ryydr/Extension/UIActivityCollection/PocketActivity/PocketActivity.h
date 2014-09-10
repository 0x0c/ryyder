//
//  PocketActivity.h
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/02.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PocketAPI.h"

@interface PocketActivity : UIActivity

- (id)initWithScheme:(NSString *)urlScheme consumerKey:(NSString *)consumerKey;
- (void)setSaveURLHanderBlocks:(void (^)(BOOL completion, PocketAPI *api, NSURL *url, NSError *error))savedBlocks;
+ (BOOL)canPerformActivity;

@end
