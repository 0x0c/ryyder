//
//  AppDelegate.h
//  ryydr
//
//  Created by Akira Matsuda on 8/19/14.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)updateBadgeNumber:(void (^)(NSInteger count))completionHandler;

@end
