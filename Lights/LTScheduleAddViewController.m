//
//  LTScheduleAddViewController.m
//  Lights
//
//  Created by Evan Coleman on 12/18/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTScheduleAddViewController.h"
#import "LTDatePickerCell.h"
#import <BlocksKit/UIBarButtonItem+BlocksKit.h>

@interface LTScheduleAddViewController ()

@end

@implementation LTScheduleAddViewController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Schedule Event";
    
    __weak typeof(self) weakSelf = self;
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel handler:^(id sender) {
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
    }];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemDone handler:^(id sender) {
        // TODO: Post event to server
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
    }];
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;
	
    // I should have thought this through, this is kinda ridiculous...
    self.tableHierarchyMap = @[@{kLTGroupTableTitleKey: @"",
                                 kLTGroupTableChildKey: @[@{kLTGroupTableTitleKey: @"DATE_PICKER"}]},
                               @{kLTGroupTableTitleKey: @"",
                                 kLTGroupTableChildKey: @[@{kLTGroupTableTitleKey: @"Event"}]},
                               @{kLTGroupTableTitleKey: @"",
                                 kLTGroupTableChildKey: @[@{kLTGroupTableTitleKey: @"Repeat",
                                                            kLTGroupTableChildKey: @[@{kLTGroupTableChildKey: @[@{kLTGroupTableTitleKey: @"Every Sunday"},
                                                                                                                @{kLTGroupTableTitleKey: @"Every Monday"},
                                                                                                                @{kLTGroupTableTitleKey: @"Every Tuesday"},
                                                                                                                @{kLTGroupTableTitleKey: @"Every Wednesday"},
                                                                                                                @{kLTGroupTableTitleKey: @"Every Thursday"},
                                                                                                                @{kLTGroupTableTitleKey: @"Every Friday"},
                                                                                                                @{kLTGroupTableTitleKey: @"Every Saturday"}
                                                                                                                ]
                                                                                       }
                                                                                     ]
                                                            }
                                                          ]
                                 }
                               ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LTGroupedTableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellDict = [self cellDictForIndexPath:indexPath];
    
    if ([cellDict[kLTGroupTableTitleKey] isEqualToString:@"DATE_PICKER"]) {
        LTDatePickerCell *cell = [[LTDatePickerCell alloc] initWithReuseIdentifier:@"DateCellIdentifier"];
        return cell;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellDict = [self cellDictForIndexPath:indexPath];
    
    if ([cellDict[kLTGroupTableTitleKey] isEqualToString:@"DATE_PICKER"]) {
        return 216.0;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellDict = [self cellDictForIndexPath:indexPath];
    
    if ([cellDict[kLTGroupTableTitleKey] isEqualToString:@"Event"]) {
        
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
