//
//  LTDatePickerCell.m
//  Lights
//
//  Created by Evan Coleman on 12/19/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTDatePickerCell.h"

@implementation LTDatePickerCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 216)];
        _datePicker.datePickerMode = UIDatePickerModeTime;
        
        [self.contentView addSubview:_datePicker];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
