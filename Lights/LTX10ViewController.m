//
//  LTX10ViewController.m
//  Lights
//
//  Created by Evan Coleman on 11/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTX10ViewController.h"
#import "LTAppDelegate.h"
#import "LTTableDrawerView.h"
#import <HHPanningTableViewCell/HHPanningTableViewCell.h>

@interface LTX10ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;

@property (nonatomic, readonly) LKSession *session;
@property (nonatomic) NSArray *devices;

@end

@implementation LTX10ViewController

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
    self.navigationController.tabBarItem.image = [UIImage imageNamed:@"house"];
    self.title = @"Home";
    
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
    onButton.frame = CGRectMake(0, 76, width, 20);
    offButton.frame = CGRectMake(width, 76, width, 20);
    
    [self.view addSubview:onButton];
    [self.view addSubview:offButton];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.session queryX10DevicesWithBlock:^(LKResponse *response) {
        self.devices = response.objects;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

#pragma mark - Interface actions

- (void)allOn:(id)sender {
    LKEventCollection *collection = [LKEventCollection collectionWithDevices:self.devices command:LKX10CommandOn];
    [self.session sendEventCollection:collection];
}

- (void)allOff:(id)sender {
    LKEventCollection *collection = [LKEventCollection collectionWithDevices:self.devices command:LKX10CommandOff];
    [self.session sendEventCollection:collection];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [(HHPanningTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] setDrawerRevealed:YES animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(HHPanningTableViewCell *)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]] setDrawerRevealed:NO animated:YES];
    
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
    
    HHPanningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[HHPanningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        LTTableDrawerView *drawerView = [[LTTableDrawerView alloc] initWithFrame:cell.frame];
        cell.drawerView = drawerView;
        cell.directionMask = HHPanningTableViewCellDirectionLeft;
        
        drawerView.onTapButton = ^(LTTableDrawerView *sender, LKX10Command command) {
            [self.session sendEvent:[LKEvent x10EventWithDevice:sender.device command:command]];
        };
    }
    
    LKX10Device *device = self.devices[indexPath.row];
    cell.textLabel.text = device.name;
    [(LTTableDrawerView *)cell.drawerView setIsLamp:(device.type == LKX10DeviceTypeLamp)];
    [(LTTableDrawerView *)cell.drawerView setDevice:self.devices[indexPath.row]];
    
    return cell;
}

#pragma mark - Helpers

- (LKSession *)session {
    return [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
}

@end
