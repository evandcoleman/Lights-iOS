//
//  LTX10ViewController.m
//  Lights
//
//  Created by Evan Coleman on 11/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTX10DevicesViewController.h"
#import "LTTableDrawerView.h"
#import "LTPanningTableViewCell.h"

@interface LTX10DevicesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSArray *devices;
@property (nonatomic) LTPanningTableViewCell *openCell;

@end

@implementation LTX10DevicesViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *onButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *offButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 100, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 150);
    
    [onButton setTitle:@"All On" forState:UIControlStateNormal];
    [offButton setTitle:@"All Off" forState:UIControlStateNormal];
    [onButton addTarget:self action:@selector(allOn:) forControlEvents:UIControlEventTouchUpInside];
    [offButton addTarget:self action:@selector(allOff:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat width = CGRectGetWidth(self.view.frame) / 2;
    onButton.frame = CGRectMake(0, 74, width, 20);
    offButton.frame = CGRectMake(width, 74, width, 20);
    
    [self.view addSubview:onButton];
    [self.view addSubview:offButton];
    [self.view addSubview:self.tableView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [refreshControl beginRefreshing];
    [self refresh:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.openCell setDrawerRevealed:NO animated:NO];
    self.openCell = nil;
}

#pragma mark - Interface actions

- (void)refresh:(id)sender {
    [[LKSession activeSession] queryX10DevicesWithBlock:^(NSArray *devices) {
        self.devices = devices;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [(UIRefreshControl *)sender endRefreshing];
    }];
}

- (void)allOn:(id)sender {
    LKEventCollection *collection = [LKEventCollection collectionWithDevices:self.devices command:LKX10CommandOn];
    [[LKSession activeSession] sendEventCollection:collection];
}

- (void)allOff:(id)sender {
    LKEventCollection *collection = [LKEventCollection collectionWithDevices:self.devices command:LKX10CommandOff];
    [[LKSession activeSession] sendEventCollection:collection];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.openCell setDrawerRevealed:NO animated:YES];
    self.openCell = (LTPanningTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self.openCell setDrawerRevealed:YES animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.openCell setDrawerRevealed:NO animated:YES];
    self.openCell = nil;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"X10DeviceCell";
    
    LTPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[LTPanningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        LTTableDrawerView *drawerView = [[LTTableDrawerView alloc] initWithFrame:cell.frame];
        cell.drawerView = drawerView;
        
        drawerView.onTapButton = ^(LTTableDrawerView *sender, LKX10Command command) {
            [[LKSession activeSession] sendEvent:[LKEvent x10EventWithDevice:sender.device command:command]];
        };
    }
    
    LKX10Device *device = self.devices[indexPath.row];
    cell.textLabel.text = device.name;
    [(LTTableDrawerView *)cell.drawerView setIsLamp:(device.type == LKX10DeviceTypeLamp)];
    [(LTTableDrawerView *)cell.drawerView setDevice:self.devices[indexPath.row]];
    
    return cell;
}

@end
