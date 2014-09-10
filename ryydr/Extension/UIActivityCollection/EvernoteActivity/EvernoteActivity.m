//
//  EvernoteActivity.m
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/01.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import "EvernoteActivity.h"
#import "EvernoteSDK.h"

@interface EvernoteActivity ()
{
	NSArray *activityItems_;
	void (^createNoteBlocks_)(BOOL completion, EDAMNote *note, NSError *error);
}

@end

@implementation EvernoteActivity

- (id)initWithHost:(NSString *)host consumerKey:(NSString *)consumerKey secret:(NSString *)consumerSecret
{
	self = [super init];
	if (self) {
		[EvernoteSession setSharedSessionHost:host consumerKey:consumerKey consumerSecret:consumerSecret];
	}
	
	return self;
}

- (void)setCreateNoteHanderBlocks:(void (^)(BOOL completion, EDAMNote *note, NSError *error))createNoteBlocks
{
	createNoteBlocks_ = [createNoteBlocks copy];
}

- (NSString *)activityType
{
    return @"com.uiactivity.evernote";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"EvernoteActivity.png"];
}

- (NSString *)activityTitle
{
    return @"Evernote";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	[super prepareWithActivityItems:activityItems];
	
    EvernoteSession *session = [EvernoteSession sharedSession];	
	if (!session.isAuthenticated) {
		[session authenticateWithViewController:self.delegate completionHandler:^(NSError *error) {
			if (error || !session.isAuthenticated) {
				NSLog(@"Error: Could not authenticate.%@", error.localizedDescription);
			} else {
				NSLog(@"Authenticated!");
				[self performActivity];
			}
		}];
	}
	activityItems_ = [activityItems copy];
}

- (UIViewController *)activityViewController
{
	return nil;
}

- (void)performActivity
{
	EvernoteSession *session = [EvernoteSession sharedSession];
	if (session.isAuthenticated) {
		EDAMNote *note = [[EDAMNote alloc] init];
		NSString *title = nil;
		NSString *url = nil;
		for (id obj in activityItems_) {
			if ([obj isKindOfClass:[NSString class]]) {
				title = obj;
			}
			else if ([obj isKindOfClass:[NSURL class	]]) {
				url = [(NSURL *)obj absoluteString];
			}
		}
		note.title = title;
		note.content = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note>%@</en-note>", url];
		EDAMNoteAttributes *attributes = [[EDAMNoteAttributes alloc] init];
		attributes.sourceURL = url;
		note.attributes = attributes;
		
		createNoteBlocks_(NO, note, nil);
		[[EvernoteNoteStore noteStore] createNote:note success:^(EDAMNote *note) {
			createNoteBlocks_(YES, note, nil);
		} failure:^(NSError *error) {
			createNoteBlocks_(YES, note, error);
		}];
	}
	[super activityDidFinish:YES];
}

- (void)activityDidFinish:(BOOL)completed
{
	[super activityDidFinish:completed];
}

@end
