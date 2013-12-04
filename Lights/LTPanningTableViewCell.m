//
//  LTPanningTableViewCell.m
//  Lights
//
//  Created by Evan Coleman on 12/3/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTPanningTableViewCell.h"
#import "LTInnerShadowView.h"

@interface LTPanningTableViewCell ()

@property (nonatomic) LTInnerShadowView *shadowView;

@end

@implementation LTPanningTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _drawerRevealed = NO;
        _shadowView = [[LTInnerShadowView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDrawerRevealed:(BOOL)drawerRevealed {
    _drawerRevealed = drawerRevealed;
    [self setDrawerRevealed:drawerRevealed animated:NO];
}

- (void)setDrawerRevealed:(BOOL)flag animated:(BOOL)animates {
    if (_drawerRevealed == flag) {
        return;
    }
    _drawerRevealed = flag;
    
    if (_drawerRevealed) {
        [self installViews];
    }
    
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect r = self.frame;
        if (_drawerRevealed) {
            [self installViews];
            r.origin.x -= r.size.width;
        } else {
            r.origin.x += r.size.width;
        }
        self.frame = r;
    } completion:^(BOOL finished) {
        if (!_drawerRevealed) {
            [self.drawerView removeFromSuperview];
            [self.shadowView removeFromSuperview];
        }
    }];
}

#pragma mark - Private methods

- (void)installViews {
    self.drawerView.bounds = self.bounds;
    self.drawerView.center = self.center;
    
    self.shadowView.bounds = self.bounds;
    self.shadowView.center = self.center;
    
    [self.superview insertSubview:self.shadowView belowSubview:self];
    [self.superview insertSubview:self.drawerView belowSubview:self.shadowView];
}

@end
