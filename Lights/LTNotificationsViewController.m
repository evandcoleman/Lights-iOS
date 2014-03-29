//
//  LTNotificationsViewController.m
//  Lights
//
//  Created by Evan Coleman on 3/28/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "LTNotificationsViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>

@interface LTNotificationsViewController ()

@end

@implementation LTNotificationsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Notifications";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NotifcationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    UILocalNotification *note = [[UIApplication sharedApplication] scheduledLocalNotifications][indexPath.row];
    cell.textLabel.text = note.userInfo[@"event"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    df.timeStyle = NSDateFormatterMediumStyle;
    cell.detailTextLabel.text = [df stringFromDate:note.fireDate];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"Cancel?" message:@"Would you like to cancel this notification?"];
    [alertView addButtonWithTitle:@"No"];
    [alertView bk_addButtonWithTitle:@"Yes" handler:^{
        UILocalNotification *note = [[UIApplication sharedApplication] scheduledLocalNotifications][indexPath.row];
        [[UIApplication sharedApplication] cancelLocalNotification:note];
        [self.tableView reloadData];
    }];
    [alertView show];
}

@end
