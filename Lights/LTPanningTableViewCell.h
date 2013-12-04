//
//  LTPanningTableViewCell.h
//  Lights
//
//  Created by Evan Coleman on 12/3/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTPanningTableViewCell : UITableViewCell

@property (nonatomic) UIView *drawerView;
@property (nonatomic) BOOL drawerRevealed;

- (void)setDrawerRevealed:(BOOL)flag animated:(BOOL)animates;

@end