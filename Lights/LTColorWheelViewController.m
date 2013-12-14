//
//  LTColorWheelViewController.m
//  Lights
//
//  Created by Evan Coleman on 12/11/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTColorWheelViewController.h"
#import "LTColorBaseViewController.h"
#import "KZColorPickerHSWheel.h"
#import "KZColorPickerBrightnessSlider.h"
#import "LTAppDelegate.h"

RGBType rgbWithUIColor(UIColor *color);

@interface LTColorWheelViewController ()

@property (nonatomic) KZColorPickerHSWheel *colorPickerView;
@property (nonatomic) KZColorPickerBrightnessSlider *brightnessSlider;

@property (nonatomic) UIColor *selectedColor;

@end

@implementation LTColorWheelViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _colorPickerView = [[KZColorPickerHSWheel alloc] initAtOrigin:CGPointMake(40, 105)];
        _brightnessSlider = [[KZColorPickerBrightnessSlider alloc] initWithFrame:CGRectMake(24, 367, 272, 38)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.colorPickerView addTarget:self action:@selector(colorChanged:) forControlEvents:UIControlEventValueChanged];
    [self.brightnessSlider addTarget:self action:@selector(colorChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.colorPickerView];
    [self.view addSubview:self.brightnessSlider];
    
    self.selectedColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    LKSession *session = [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
    [session queryStateWithBlock:^(LKEvent *event) {
        if (event.type == LKEventTypeSolid) {
            self.selectedColor = [UIColor colorWithRed:event.color.red/255.0 green:event.color.green/255.0 blue:event.color.blue/255.0 alpha:1.0];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    
    RGBType rgb = rgbWithUIColor(selectedColor);
	HSVType hsv = RGB_to_HSV(rgb);
	
	self.colorPickerView.currentHSV = hsv;
	self.brightnessSlider.value = hsv.v;
	
    UIColor *keyColor = [UIColor colorWithHue:hsv.h
                                   saturation:hsv.s
                                   brightness:1.0
                                        alpha:1.0];
	[self.brightnessSlider setKeyColor:keyColor];
}

- (void)sendColorEvent {
    RGBType rgb = rgbWithUIColor(self.selectedColor);
    LKSession *session = [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
    LKColor *color = [LKColor colorWithRGB:@[@(rgb.r*255.0), @(rgb.g*255.0), @(rgb.b*255.0)]];
    [session sendEvent:[LKEvent colorEventWithColor:color]];
}

#pragma mark - Interface actions

- (void)colorChanged:(id)sender {
    HSVType hsv = self.colorPickerView.currentHSV;
	self.selectedColor = [UIColor colorWithHue:hsv.h saturation:hsv.s brightness:self.brightnessSlider.value alpha:1.0];
    [self sendColorEvent];
}

@end
