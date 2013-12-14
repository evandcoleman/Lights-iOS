//
//  LTScheduleCell.m
//  Lights
//
//  Created by Evan Coleman on 12/14/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTScheduleCell.h"

@implementation LTScheduleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _eventLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.toggleSwitch.frame = CGRectMake(CGRectGetMaxX(self.contentView.bounds) - 51 - 14, (CGRectGetHeight(self.contentView.bounds) - 31) / 2, 51, 31);
    self.timeLabel.frame = CGRectMake(14, 12, CGRectGetMinX(self.toggleSwitch.frame) - 10, CGRectGetHeight(self.contentView.bounds) / 2);
    self.eventLabel.frame = CGRectMake(CGRectGetMinX(self.timeLabel.frame), CGRectGetMaxY(self.timeLabel.frame) + 4, CGRectGetWidth(self.timeLabel.frame), 14);
    
    self.timeLabel.font = [UIFont systemFontOfSize:36];
    self.eventLabel.font = [UIFont systemFontOfSize:12];
    
    [self.contentView addSubview:self.toggleSwitch];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.eventLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStyleForColor:(UIColor *)color {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    int threshold = 105;
    int bgDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));
    
    UIColor *textColor = (255 - bgDelta < threshold) ? [UIColor blackColor] : [UIColor whiteColor];
    self.timeLabel.textColor = textColor;
    self.eventLabel.textColor = textColor;
    self.backgroundColor = color;
}

@end
