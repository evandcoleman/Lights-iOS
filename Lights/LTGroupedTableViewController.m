//
//  LTTableViewController.m
//  Lights
//
//  Created by Evan Coleman on 12/18/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTGroupedTableViewController.h"

@interface LTGroupedTableViewController ()

@property (nonatomic) NSMutableArray *selectedRowIndexes;

@end

@implementation LTGroupedTableViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _selectedRowIndexes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)cellDictForIndexPath:(NSIndexPath *)indexPath {
    return self.tableHierarchyMap[indexPath.section][kLTGroupTableChildKey][indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.tableHierarchyMap count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSDictionary *sectionDict = self.tableHierarchyMap[section];
    return [sectionDict[kLTGroupTableChildKey] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionDict = self.tableHierarchyMap[section];
    return sectionDict[kLTGroupTableTitleKey];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *childDict = [self cellDictForIndexPath:indexPath];
    cell.textLabel.text = childDict[kLTGroupTableTitleKey];
    cell.detailTextLabel.text = childDict[kLTGroupTableSubtitleKey];
    
    if ([self.selectedRowIndexes containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (childDict[kLTGroupTableChildKey]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *childDict = [self cellDictForIndexPath:indexPath];
    
    if (childDict[kLTGroupTableChildKey]) {
        LTGroupedTableViewController *subTableViewController = [[LTGroupedTableViewController alloc] init];
        subTableViewController.tableHierarchyMap = childDict[kLTGroupTableChildKey];
        subTableViewController.title = childDict[kLTGroupTableTitleKey];
        [self.navigationController pushViewController:subTableViewController animated:YES];
    } else {
        if ([self.selectedRowIndexes containsObject:indexPath]) {
            [self.selectedRowIndexes removeObject:indexPath];
        } else {
            [self.selectedRowIndexes addObject:indexPath];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
