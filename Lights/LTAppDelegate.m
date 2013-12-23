//
//  LTAppDelegate.m
//  Lights
//
//  Created by Evan Coleman on 11/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTAppDelegate.h"
#import "LTX10ViewController.h"
#import "LTSettingsViewController.h"
#import "LTColorBaseViewController.h"
#import "LTScheduleTableViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <SSKeychain/SSKeychain.h>

#define kDefaultServerURL @"http://example.com"
#define kServiceName @"lights-app"

@interface LTAppDelegate ()

@end

@implementation LTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [TestFlight takeOff:@"4d76814c-d4ac-4fe7-933b-f0ed44b4c787"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    self.window.rootViewController = self.tabBarController;
    
    self.loadingViewController = [[LTLoadingViewController alloc] init];
    self.loadingViewController.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.window makeKeyAndVisible];
    
    [self loginAndOpenSession];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.session suspendSession];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.tabBarController presentViewController:self.loadingViewController animated:NO completion:NULL];
    [self.session resumeSessionWithCompletion:^{
        [self.tabBarController dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupTabBarControllerWithColors:(BOOL)colors {
    NSMutableArray *vcs = [NSMutableArray array];
    
    UINavigationController *x10ViewController = [[UINavigationController alloc] initWithRootViewController:[[LTX10ViewController alloc] init]];
    [vcs addObject:x10ViewController];
    
    UINavigationController *colorViewController = [[UINavigationController alloc] initWithRootViewController:[[LTColorBaseViewController alloc] init]];
    colorViewController.title = @"Colors";
    colorViewController.tabBarItem.image = [UIImage imageNamed:@"flower"];
    if (colors) {
        [vcs addObject:colorViewController];
    }
    
//    UINavigationController *scheduleViewController = [[UINavigationController alloc] initWithRootViewController:[[LTScheduleTableViewController alloc] init]];
//    scheduleViewController.title = @"Schedule";
//    scheduleViewController.tabBarItem.image = [UIImage imageNamed:@"schedule"];
//    [vcs addObject:scheduleViewController];
    
    UINavigationController *settingsViewController = [[UINavigationController alloc] initWithRootViewController:[[LTSettingsViewController alloc] init]];
    settingsViewController.title = @"Settings";
    settingsViewController.tabBarItem.image = [UIImage imageNamed:@"gear"];
    [vcs addObject:settingsViewController];
    
    self.tabBarController.viewControllers = vcs;
}

#pragma mark - Server stuff

- (NSString *)serverURL {
    NSString *serverString = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTServerKey"];
    if (!serverString) {
        serverString = kDefaultServerURL;
        [[NSUserDefaults standardUserDefaults] setObject:serverString forKey:@"LTServerKey"];
    }
    return serverString;
}

- (void)loginAndOpenSession {
    [self.tabBarController presentViewController:self.loadingViewController animated:NO completion:NULL];
    // Check for username
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTUsername"];
    
    if (!username || username.length == 0) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Login" message:@"Please enter your username."];
        [alertView bk_addButtonWithTitle:@"OK" handler:^{
            [[NSUserDefaults standardUserDefaults] setObject:[alertView textFieldAtIndex:0].text forKey:@"LTUsername"];
            [self maybeSetPasswordWithUsername:[alertView textFieldAtIndex:0].text completion:^(NSString *password){
                [self openSessionWithUsername:[alertView textFieldAtIndex:0].text andPassword:password];
            }];
        }];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    } else {
        [self maybeSetPasswordWithUsername:username completion:^(NSString *password) {
            [self openSessionWithUsername:username andPassword:password];
        }];
    }
}

- (void)maybeSetPasswordWithUsername:(NSString *)username completion:(void(^)(NSString *password))completion {
    LKUserSession *userSession = [[LKUserSession alloc] initWithServer:[NSURL URLWithString:[self serverURL]]];
    [userSession usernameHasPassword:username completion:^(BOOL hasPassword) {
        if (hasPassword) {
            NSString *password = [SSKeychain passwordForService:kServiceName account:username];
            if (password && password.length > 0) {
                completion(password);
            } else {
                UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Login" message:@"Please enter your password"];
                alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
                [alertView bk_addButtonWithTitle:@"Login" handler:^{
                    [SSKeychain setPassword:[alertView textFieldAtIndex:0].text forService:kServiceName account:username];
                    completion([alertView textFieldAtIndex:0].text);
                }];
                [alertView show];
            }
        } else {
            UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Login" message:@"Please choose a password."];
            alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
            [alertView bk_addButtonWithTitle:@"Set Password" handler:^{
                [SSKeychain setPassword:[alertView textFieldAtIndex:0].text forService:kServiceName account:username];
                [userSession setPassword:[alertView textFieldAtIndex:0].text forUsername:username completion:^{
                    [self openSessionWithUsername:username andPassword:[alertView textFieldAtIndex:0].text];
                }];
            }];
            [alertView show];
        }
    }];
}

- (void)openSessionWithUsername:(NSString *)username andPassword:(NSString *)password {
    self.session = [[LKSession alloc] initWithServer:[NSURL URLWithString:[self serverURL]]];
    [self.session openSessionWithUsername:username password:password completion:^(NSDictionary *userDict){
        [self setupTabBarControllerWithColors:(userDict[@"color_zones"] != (id)[NSNull null])];
        [self.tabBarController dismissViewControllerAnimated:YES completion:NULL];
    }];
}

@end
