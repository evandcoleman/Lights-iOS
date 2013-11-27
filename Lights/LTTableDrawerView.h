//
//  LTTableDrawerView.h
//  Lights
//
//  Created by Evan Coleman on 11/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTTableDrawerView : UIView

@property (nonatomic) BOOL isLamp;

@property (nonatomic, copy) void(^onTapButton)(id sender, LKX10Command command);
@property (nonatomic) LKX10Device *device;

@end
