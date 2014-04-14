//
//  LTSettingsViewController.m
//  Lights
//
//  Created by Evan Coleman on 11/27/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTSettingsViewController.h"
#import "LTAppDelegate.h"
#import "LTLoadingViewController.h"
#import "LTBeaconsViewController.h"
#import "LTNotificationsViewController.h"
#import "LTBeaconManager.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <SSKeychain/SSKeychain.h>
#import <RETableViewManager/RETableViewManager.h>

@interface LTSettingsViewController ()

@property (nonatomic) RETableViewManager *manager;

@end

@implementation LTSettingsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Settings";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    
    RETableViewSection *settingsSection = [RETableViewSection sectionWithHeaderTitle:@"Settings"];
    [settingsSection addItem:[RETextItem itemWithTitle:@"Server Address" value:[[NSUserDefaults standardUserDefaults] stringForKey:@"LTServerKey"]]];
    NSNumber *beaconsOn = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTBeacons"];
    [settingsSection addItem:[REBoolItem itemWithTitle:@"Beacon Monitoring" value:(beaconsOn ? [beaconsOn boolValue] : YES) switchValueChangeHandler:^(REBoolItem *item) {
        [[NSUserDefaults standardUserDefaults] setBool:item.value forKey:@"LTBeacons"];
        
        if (item.value) {
            [[LTBeaconManager sharedManager] beginTracking];
        } else {
            [[LTBeaconManager sharedManager] stopTracking];
        }
    }]];
    [self.manager addSection:settingsSection];
    
    RETableViewSection *actionsSection = [RETableViewSection section];
    [actionsSection addItem:[RETableViewItem itemWithTitle:@"Reconnect" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [[LKSession activeSession] suspendSession];
        [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] setSession:nil];
        
        // ugly h4x
        RETextItem *serverItem = [(RETableViewSection *)self.manager.sections[0] items][0];
        [[NSUserDefaults standardUserDefaults] setObject:serverItem.value forKey:@"LTServerKey"];
        
        [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] loginAndOpenSession];
    }]];
    [actionsSection addItem:[RETableViewItem itemWithTitle:@"Logout" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [SSKeychain deletePasswordForService:kServiceName account:[[NSUserDefaults standardUserDefaults] objectForKey:@"LTUsername"]];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"LTUsername"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        exit(0);
    }]];
    [self.manager addSection:actionsSection];
    
    RETableViewSection *debugSection = [RETableViewSection sectionWithHeaderTitle:@"Debugging"];
    [debugSection addItem:[RETableViewItem itemWithTitle:@"Beacons" accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        LTBeaconsViewController *vc = [[LTBeaconsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }]];
    [debugSection addItem:[RETableViewItem itemWithTitle:@"Notifications" accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        LTNotificationsViewController *vc = [[LTNotificationsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }]];
    
//    // Testing
//    [debugSection addItem:[RETableViewItem itemWithTitle:@"Test Sunset Notification" accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.userInfo = @{@"event": @"fire_sunset"};
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//        
//        NSLog(@"Firing sunset notification");
//    }]];
    [self.manager addSection:debugSection];
}

#pragma mark - Actions



@end
