//
//  LTRoomCell.m
//  Lights
//
//  Created by Evan Coleman on 12/27/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTRoomCell.h"

@implementation LTRoomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _onButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _offButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [_onButton setTitle:@"On" forState:UIControlStateNormal];
        [_offButton setTitle:@"Off" forState:UIControlStateNormal];
        
        [self.contentView addSubview:_onButton];
        [self.contentView addSubview:_offButton];
        
        self.textLabel.font = [UIFont systemFontOfSize:16];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.contentView.bounds) / 2.0;
    CGFloat height = 24.0;
    CGFloat y = CGRectGetMaxY(self.contentView.bounds) - height - 4;
    
    self.textLabel.frame = CGRectMake(14, 10, CGRectGetWidth(self.contentView.bounds), height);
    self.onButton.frame = CGRectMake(0, y, width, height);
    self.offButton.frame = CGRectMake(width, y, width, height);
}

@end
