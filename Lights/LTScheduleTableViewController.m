//
//  LTScheduleTableViewController.m
//  Lights
//
//  Created by Evan Coleman on 12/14/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTScheduleTableViewController.h"
#import "LTAppDelegate.h"
#import "LTScheduleCell.h"

@interface LTScheduleTableViewController ()

@property (nonatomic) NSMutableArray *scheduledEvents;
@property (nonatomic) NSArray *animations;

@end

@implementation LTScheduleTableViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = NSLocalizedString(@"Schedule", @"Schedule");
        self.tabBarItem.image = [UIImage imageNamed:@"schedule"];
        
        _scheduledEvents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    LKSession *session = [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
    [session queryAnimationsWithBlock:^(NSArray *animations) {
        self.animations = animations;
    }];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchScheduledEvents];
}

#pragma mark - Session methods

- (void)fetchScheduledEvents {
    LKSession *session = [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
    [session queryScheduleWithBlock:^(NSArray *events) {
        [self.scheduledEvents removeAllObjects];
        [self.scheduledEvents addObjectsFromArray:events];
        [self.tableView reloadData];
    }];
}

#pragma mark - Interface actions

- (void)toggleState:(UISwitch *)sender {
    LKSession *session = [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
    LKScheduledEvent *event = self.scheduledEvents[sender.tag];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.scheduledEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    LTScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[LTScheduleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell.toggleSwitch addTarget:self action:@selector(toggleState:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    LKScheduledEvent *event = self.scheduledEvents[indexPath.row];
    [cell setStyleForColor:[UIColor whiteColor]];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterNoStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    cell.timeLabel.text = [df stringFromDate:event.date];
    
    NSArray *days = @[@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat"];
    NSMutableString *str = [NSMutableString string];
    NSString *detail = nil;
    if([event.repeat isKindOfClass:[NSArray class]] && [event.repeat count] != 7) {
        for(NSNumber *a in event.repeat) {
            [str appendFormat:@"%@ ",[days objectAtIndex:[a intValue]]];
        }
        if([str length] > 0) {
            detail = [str substringToIndex:str.length - 1];
        }
    } else if ([event.repeat isKindOfClass:[NSArray class]] && [event.repeat count] == 7) {
        detail = @"Everyday";
    }
    
    NSString *eventString = nil;
    if (event.type == LKEventTypeSolid) {
        eventString = @"Solid";
        [cell setStyleForColor:[UIColor colorWithRed:event.color.red/255.0 green:event.color.green/255.0 blue:event.color.blue/255.0 alpha:1.0]];
    } else if (event.type == LKEventTypeX10Command) {
        NSString *commandString = @"";
        if (event.command == LKX10CommandOn) {
            commandString = @"On";
            [cell setStyleForColor:[UIColor whiteColor]];
        } else if (event.command == LKX10CommandOff) {
            commandString = @"Off";
            [cell setStyleForColor:[UIColor blackColor]];
        }
        eventString = [event.device.name stringByAppendingFormat:@" %@", commandString];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"animationId == %@", @(event.type)];
        NSArray *matches = [self.animations filteredArrayUsingPredicate:predicate];
        if ([matches count] > 0) {
            LKAnimation *anim = [matches firstObject];
            eventString = anim.name;
        }
    }
    
    cell.eventLabel.text = detail ? [eventString stringByAppendingFormat:@", %@", detail] : eventString;
    cell.toggleSwitch.on = event.state;
    cell.toggleSwitch.tag = indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76.0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
