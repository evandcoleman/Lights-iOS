//
//  LTScheduleCell.h
//  Lights
//
//  Created by Evan Coleman on 12/14/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTScheduleCell : UITableViewCell

@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UILabel *eventLabel;
@property (nonatomic) UISwitch *toggleSwitch;

- (void)setStyleForColor:(UIColor *)color;

@end
