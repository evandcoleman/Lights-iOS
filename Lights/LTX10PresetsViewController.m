//
//  LTX10PresetsViewController.m
//  Lights
//
//  Created by Evan Coleman on 12/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTX10PresetsViewController.h"
#import "LTAppDelegate.h"

@interface LTX10PresetsViewController ()

@property (nonatomic, readonly) LKSession *session;
@property (nonatomic) NSArray *presets;

@end

@implementation LTX10PresetsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
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
    [self.session queryPresetsWithBlock:^(NSArray *presets) {
        self.presets = presets;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [(UIRefreshControl *)sender endRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.presets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PresetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    LKPreset *preset = self.presets[indexPath.row];
    cell.textLabel.text = preset.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.session executePreset:self.presets[indexPath.row]];
}

#pragma mark - Helpers

- (LKSession *)session {
    return [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
}

@end
