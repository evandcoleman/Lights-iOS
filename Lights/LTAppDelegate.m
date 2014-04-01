//
//  LTAppDelegate.m
//  Lights
//
//  Created by Evan Coleman on 11/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTAppDelegate.h"
#import "LTX10BaseViewController.h"
#import "LTSettingsViewController.h"
#import "LTColorBaseViewController.h"
#import "LTScheduleTableViewController.h"
#import "LTBeaconManager.h"
#import "LTSunsetNotificationHelper.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <SSKeychain/SSKeychain.h>
#import <HockeySDK/HockeySDK.h>

#define kDefaultServerURL @""
#define kServiceName @""
#define kHockeyAppId @""

@interface LTAppDelegate () <LKSessionDelegate>

@property (nonatomic) NSDictionary *launchOptions;

@end

@implementation LTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kHockeyAppId];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    self.launchOptions = launchOptions;
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
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [deviceToken description];
    
    [self.session registerDeviceToken:token completion:NULL];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"Notification" message:notification.alertBody];
        [alertView bk_addButtonWithTitle:@"Dismiss" handler:^{
            [self handleLocalNotification:notification];
        }];
    } else {
        [self handleLocalNotification:notification];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        id message = userInfo[@"alert"];
        NSString *messageString = nil;
        if ([message isKindOfClass:[NSString class]]) {
            messageString = message;
        } else if ([message isKindOfClass:[NSDictionary class]]) {
            messageString = message[@"body"];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"Notification" message:messageString];
        [alertView bk_addButtonWithTitle:@"Dismiss" handler:^{
            [self handlePushNotification:userInfo fetchCompletionHandler:completionHandler];
        }];
    } else {
        [self handlePushNotification:userInfo fetchCompletionHandler:completionHandler];
    }
}

- (void)setupTabBarControllerWithColors:(BOOL)colors {
    NSMutableArray *vcs = [NSMutableArray array];
    
    UINavigationController *x10ViewController = [[UINavigationController alloc] initWithRootViewController:[[LTX10BaseViewController alloc] init]];
    x10ViewController.tabBarItem.image = [UIImage imageNamed:@"house"];
    x10ViewController.title = @"Home";
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
    self.session = [[LKSession alloc] initWithBaseURL:[NSURL URLWithString:[self serverURL]]];
    self.session.delegate = self;
    [self.session openSessionWithUsername:username password:password completion:^(NSDictionary *userDict){
        [self setupTabBarControllerWithColors:(userDict[@"color_zones"] != (id)[NSNull null])];
        [self.tabBarController dismissViewControllerAnimated:YES completion:NULL];
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
        
        if ([self beaconsOn]) {
            [[LTBeaconManager sharedManager] beginTracking];
        }
        
        UILocalNotification *launchNote = [self.launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (launchNote && [self beaconsOn]){
            [self handleLocalNotification:launchNote];
        }
    }];
}

#pragma mark - LKSessionDelegate

- (void)session:(LKSession *)session didFailWithError:(NSError *)error retryHandler:(void (^)())retryHandler {
    NSHTTPURLResponse *response = error.userInfo[@"AFNetworkingOperationFailingURLResponseErrorKey"];
    if (response.statusCode == 401) {
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTUsername"];
        NSString *password = [SSKeychain passwordForService:kServiceName account:username];
       // [self.tabBarController presentViewController:self.loadingViewController animated:NO completion:NULL];
        [self.session openSessionWithUsername:username password:password completion:^(NSDictionary *userDict) {
          //  [self.tabBarController dismissViewControllerAnimated:YES completion:NULL];
            
            retryHandler();
        }];
    }
}

#pragma mark - Helpers

- (void)handleLocalNotification:(UILocalNotification *)notification {
    NSString *eventString = notification.userInfo[@"event"];
    if ([eventString isEqualToString:@"trigger_room"] && [self beaconsOn]) {
        [[LTBeaconManager sharedManager] triggerActionWithNotification:notification];
    } else if ([eventString isEqualToString:@"fire_sunset"] && [self beaconsOn]) {
        [LTSunsetNotificationHelper sunsetNotificationDidFire];
    }
}

- (void)handlePushNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSString *eventString = userInfo[@"event"];
    if ([eventString isEqualToString:@"schedule_sunset"] && [self beaconsOn]) {
        [LTSunsetNotificationHelper scheduleSunsetNotificationWithCompletion:^{
            completionHandler(UIBackgroundFetchResultNewData);
        }];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (BOOL)beaconsOn {
    NSNumber *beaconsOn = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTBeacons"];
    return ([beaconsOn boolValue] || !beaconsOn);
}

@end
