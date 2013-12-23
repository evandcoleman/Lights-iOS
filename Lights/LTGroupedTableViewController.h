//
//  LTTableViewController.h
//  Lights
//
//  Created by Evan Coleman on 12/18/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLTGroupTableTitleKey @"LTGroupTableTitleKey"
#define kLTGroupTableSubtitleKey @"LTGroupTableSubtitleKey"
#define kLTGroupTableChildKey @"LTGroupTableChildKey"

@interface LTGroupedTableViewController : UITableViewController

@property (nonatomic) NSArray *tableHierarchyMap;

- (NSDictionary *)cellDictForIndexPath:(NSIndexPath *)indexPath;

@end
