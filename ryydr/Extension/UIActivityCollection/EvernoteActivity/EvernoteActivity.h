//
//  EvernoteActivity.h
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/01.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EDAMNote;

@interface EvernoteActivity : UIActivity

- (id)initWithHost:(NSString *)host consumerKey:(NSString *)consumerKey secret:(NSString *)consumerSecret;
- (void)setCreateNoteHanderBlocks:(void (^)(BOOL completion, EDAMNote *note, NSError *error))createNoteBlocks;

@property (nonatomic, assign) id delegate;

@end
