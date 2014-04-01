//
//  LTColorSwatchesViewController.m
//  Lights
//
//  Created by Evan Coleman on 12/13/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTColorSwatchesViewController.h"
#import "KZColorPickerSwatchView.h"
#import "KZColorPickerHSWheel.h"
#import "KZColorPickerBrightnessSlider.h"

RGBType rgbWithUIColor(UIColor *color);

@interface LTColorSwatchesViewController ()

@property (nonatomic) UIColor *selectedColor;
@property (nonatomic) NSMutableArray *swatches;

@property (nonatomic) KZColorPickerBrightnessSlider *brightnessSlider;

@end

@implementation LTColorSwatchesViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _brightnessSlider = [[KZColorPickerBrightnessSlider alloc] initWithFrame:CGRectMake(24, 447, 272, 38)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    [self.brightnessSlider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.brightnessSlider];
    
    self.selectedColor = [UIColor whiteColor];
    
    NSMutableArray *colors = [NSMutableArray array];
    for(float angle = 0; angle < 360; angle += 10) {
        CGFloat h = 0;
        h = (M_PI / 180.0 * angle) / (2 * M_PI);
        [colors addObject:[UIColor colorWithHue:h  saturation:1.0 brightness:1.0 alpha:1.0]];
    }
    
    KZColorPickerSwatchView *swatch = nil;
    self.swatches = [NSMutableArray array];
    for (UIColor *color in colors) {
        swatch = [[KZColorPickerSwatchView alloc] initWithFrame:CGRectZero];
        swatch.color = color;
        [swatch addTarget:self action:@selector(swatchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:swatch];
        [self.swatches addObject:swatch];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat totalWidth = self.view.bounds.size.width - 40.0;
    CGFloat swatchCellWidth = totalWidth / 6.0;
    
    int sx = 20;
    int sy = 130;
    for (KZColorPickerSwatchView *swatch in self.swatches) {
        swatch.frame = CGRectMake(sx + swatchCellWidth * 0.5 - 18.0, sy, 36.0, 36.0);
        sx += swatchCellWidth;
        if (sx >= totalWidth) {
            sx = 20;
            sy += 46;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[LKSession activeSession] queryStateWithBlock:^(LKEvent *event) {
        if (event.type == LKEventTypeSolid) {
            self.selectedColor = [UIColor colorWithRed:event.color.red/255.0 green:event.color.green/255.0 blue:event.color.blue/255.0 alpha:1.0];
        }
    }];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    
    RGBType rgb = rgbWithUIColor(selectedColor);
	HSVType hsv = RGB_to_HSV(rgb);
	
	self.brightnessSlider.value = hsv.v;
	
    UIColor *keyColor = [UIColor colorWithHue:hsv.h
                                   saturation:hsv.s
                                   brightness:1.0
                                        alpha:1.0];
	[self.brightnessSlider setKeyColor:keyColor];
}

- (void)sendColorEvent {
    RGBType rgb = rgbWithUIColor(self.selectedColor);
    LKColor *color = [LKColor colorWithRGB:@[@(rgb.r*255.0), @(rgb.g*255.0), @(rgb.b*255.0)]];
    [[LKSession activeSession] sendEvent:[LKEvent colorEventWithColor:color]];
}

#pragma mark - Interface actions

- (void)brightnessChanged:(id)sender {
    RGBType rgb = rgbWithUIColor(self.selectedColor);
	HSVType hsv = RGB_to_HSV(rgb);
    self.selectedColor = [UIColor colorWithHue:hsv.h saturation:hsv.s brightness:self.brightnessSlider.value alpha:1.0];
    [self sendColorEvent];
}

- (void)swatchAction:(KZColorPickerSwatchView *)sender {
    self.selectedColor = sender.color;
    [self sendColorEvent];
}

@end
