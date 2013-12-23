//
//  LTAppDelegate.h
//  Lights
//
//  Created by Evan Coleman on 11/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow *window;
@property (nonatomic) LKSession *session;
@property (nonatomic) UITabBarController *tabBarController;

- (void)loginAndOpenSession;

@end
