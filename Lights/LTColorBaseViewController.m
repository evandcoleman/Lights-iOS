//
//  LTFirstViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/17/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTColorBaseViewController.h"
#import "LTAppDelegate.h"
#import "LTColorWheelViewController.h"
#import "LTColorAnimateViewController.h"
#import "LTColorSwatchesViewController.h"

@interface LTColorBaseViewController ()

@property (nonatomic) UISegmentedControl *segmentedControl;

@property (nonatomic, readonly) LKSession *session;

@property (nonatomic) UIViewController *currentViewController;
@property (nonatomic) LTColorWheelViewController *colorWheelViewController;
@property (nonatomic) LTColorAnimateViewController *colorAnimationViewController;
@property (nonatomic) LTColorSwatchesViewController *colorSwatchesViewController;

@end

@implementation LTColorBaseViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Colors", @"Colors");
        self.tabBarItem.image = [UIImage imageNamed:@"flower"];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Colors", @"Wheel", @"Animate"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    [self.segmentedControl addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = self.segmentedControl;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *serverString = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTServerKey"];
    if ([serverString rangeOfString:@"home"].location != NSNotFound) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.view.frame];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.text = @"Not Available";
        [self.view addSubview:label];
        self.view.userInteractionEnabled = NO;
    }
}

#pragma mark - Getters

- (LTColorWheelViewController *)colorWheelViewController {
    if (_colorWheelViewController == nil) {
        _colorWheelViewController = [[LTColorWheelViewController alloc] init];
    }
    return _colorWheelViewController;
}

- (LTColorAnimateViewController *)colorAnimationViewController {
    if (_colorAnimationViewController == nil) {
        _colorAnimationViewController = [[LTColorAnimateViewController alloc] init];
    }
    return _colorAnimationViewController;
}

- (LTColorSwatchesViewController *)colorSwatchesViewController {
    if (_colorSwatchesViewController == nil) {
        _colorSwatchesViewController = [[LTColorSwatchesViewController alloc] init];
    }
    return _colorSwatchesViewController;
}

#pragma mark - Child View Swapping

- (void)segmentSelected:(id)sender {
    UIViewController *toViewController = nil;
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            toViewController = self.colorSwatchesViewController;
            break;
        case 1:
            toViewController = self.colorWheelViewController;
            break;
        case 2:
            toViewController = self.colorAnimationViewController;
            break;
        default:
            break;
    }
    
    if (self.currentViewController == toViewController) {
        return;
    }
    
    [self cycleFromViewController:self.currentViewController toViewController:toViewController];
}

- (void)cycleFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
    [fromViewController willMoveToParentViewController:nil];
    [fromViewController.view removeFromSuperview];
    [fromViewController removeFromParentViewController];
    [self addChildViewController:toViewController];
    
    toViewController.view.frame = self.view.bounds;

    [self.view addSubview:toViewController.view];
    toViewController.view.userInteractionEnabled = YES;
    
    
    [toViewController didMoveToParentViewController:self];
    
    self.currentViewController = toViewController;
}

#pragma mark - Helpers

- (LKSession *)session {
    return [(LTAppDelegate *)[[UIApplication sharedApplication] delegate] session];
}

@end
