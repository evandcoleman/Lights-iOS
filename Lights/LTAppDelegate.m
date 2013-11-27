//
//  LTAppDelegate.m
//  Lights
//
//  Created by Evan Coleman on 11/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTAppDelegate.h"
#import "LTLoadingViewController.h"
#import "LTX10ViewController.h"
#import "LTSettingsViewController.h"
#import "LTColorViewController.h"

@interface LTAppDelegate ()

@property (nonatomic) LTLoadingViewController *loadingViewController;

@end

@implementation LTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.tabBarController = [[UITabBarController alloc] init];
    UINavigationController *x10ViewController = [[UINavigationController alloc] initWithRootViewController:[[LTX10ViewController alloc] init]];
    UINavigationController *colorViewController = [[UINavigationController alloc] initWithRootViewController:[[LTColorViewController alloc] init]];
    colorViewController.title = @"Colors";
    colorViewController.tabBarItem.image = [UIImage imageNamed:@"flower"];
    UINavigationController *settingsViewController = [[UINavigationController alloc] initWithRootViewController:[[LTSettingsViewController alloc] init]];
    settingsViewController.title = @"Settings";
    settingsViewController.tabBarItem.image = [UIImage imageNamed:@"gear"];
    self.tabBarController.viewControllers = @[x10ViewController, colorViewController, settingsViewController];
    
    self.window.rootViewController = self.tabBarController;
    
    self.loadingViewController = [[LTLoadingViewController alloc] init];
    self.loadingViewController.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.window makeKeyAndVisible];
    
    [self.tabBarController presentViewController:self.loadingViewController animated:NO completion:NULL];
    
    NSString *serverString = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTServerKey"];
    if (!serverString) {
        serverString = @"ws://home.evancoleman.net:9000";
        [[NSUserDefaults standardUserDefaults] setObject:serverString forKey:@"LTServerKey"];
    }
    
    self.session = [[LKSession alloc] initWithServer:[NSURL URLWithString:serverString]];
    [self.session openSessionWithCompletion:^{
        [self.tabBarController dismissViewControllerAnimated:YES completion:NULL];
    }];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
