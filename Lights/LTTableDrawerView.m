//
//  LTTableDrawerView.m
//  Lights
//
//  Created by Evan Coleman on 11/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTTableDrawerView.h"

@interface LTTableDrawerView ()

@property (nonatomic) UIButton *onButton;
@property (nonatomic) UIButton *offButton;
@property (nonatomic) UIButton *dimButton;
@property (nonatomic) UIButton *brightButton;

@end

@implementation LTTableDrawerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _isLamp = NO;
        
        self.onButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.offButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.dimButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.brightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [self.onButton setTitle:@"On" forState:UIControlStateNormal];
        [self.offButton setTitle:@"Off" forState:UIControlStateNormal];
        [self.dimButton setTitle:@"Dim" forState:UIControlStateNormal];
        [self.brightButton setTitle:@"Bright" forState:UIControlStateNormal];
        
        [self.onButton addTarget:self action:@selector(on) forControlEvents:UIControlEventTouchUpInside];
        [self.offButton addTarget:self action:@selector(off) forControlEvents:UIControlEventTouchUpInside];
        [self.dimButton addTarget:self action:@selector(dim) forControlEvents:UIControlEventTouchUpInside];
        [self.brightButton addTarget:self action:@selector(bright) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.onButton];
        [self addSubview:self.offButton];
        [self addSubview:self.dimButton];
        [self addSubview:self.brightButton];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.frame) / (self.isLamp ? 4 : 2);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat x = 0.0f;
    
    self.onButton.frame = CGRectMake(x, 0, width, height);
    x += width;
    self.offButton.frame = CGRectMake(x, 0, width, height);
    x += width;
    self.dimButton.frame = CGRectMake(x, 0, width, height);
    x += width;
    self.brightButton.frame = CGRectMake(x, 0, width, height);
}

- (void)setIsLamp:(BOOL)isLamp {
    _isLamp = isLamp;
    
    [self setNeedsLayout];
}

- (void)on {
    self.onTapButton(self, LKX10CommandOn);
}

- (void)off {
    self.onTapButton(self, LKX10CommandOff);
}

- (void)dim {
    self.onTapButton(self, LKX10CommandDim);
}

- (void)bright {
    self.onTapButton(self, LKX10CommandBright);
}

@end
