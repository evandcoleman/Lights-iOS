//
//  LTX10RoomsViewController.m
//  Lights
//
//  Created by Evan Coleman on 12/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTX10RoomsViewController.h"
#import "LTAppDelegate.h"
#import "LTRoomCell.h"

@interface LTX10RoomsViewController ()

@property (nonatomic, readonly) LKSession *session;
@property (nonatomic) NSArray *rooms;

@end

@implementation LTX10RoomsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];

    [refreshControl beginRefreshing];
    [self refresh:refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Interface actions

- (void)refresh:(id)sender {
    [self.session queryRoomsWithBlock:^(NSArray *rooms) {
        self.rooms = rooms;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [(UIRefreshControl *)sender endRefreshing];
    }];
}

- (void)roomOn:(UIControl *)sender {
    LKRoom *room = self.rooms[sender.tag];
    [self.session sendEventCollection:[LKEventCollection collectionWithRoom:room command:LKX10CommandOn]];
}

- (void)roomOff:(UIControl *)sender {
    LKRoom *room = self.rooms[sender.tag];
    [self.session sendEventCollection:[LKEventCollection collectionWithRoom:room command:LKX10CommandOff]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.rooms count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RoomCell";
    LTRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[LTRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.onButton addTarget:self action:@selector(roomOn:) forControlEvents:UIControlEventTouchUpInside];
        [cell.offButton addTarget:self action:@selector(roomOff:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    LKRoom *room = self.rooms[indexPath.row];
    cell.textLabel.text = room.name;
    cell.onButton.tag = indexPath.row;
    cell.offButton.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.session sendEventCollection:[LKEventCollection collectionWithRoom:self.rooms[indexPath.row] command:LKX10CommandOff]];
}

#pragma mark - Helpers

- (LKSession *)session {
    return [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
}

@end
