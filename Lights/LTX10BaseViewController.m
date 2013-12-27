//
//  LTFirstViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/17/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTX10BaseViewController.h"
#import "LTAppDelegate.h"
#import "LTX10DevicesViewController.h"
#import "LTX10RoomsViewController.h"
#import "LTX10PresetsViewController.h"

@interface LTX10BaseViewController ()

@property (nonatomic) UISegmentedControl *segmentedControl;

@property (nonatomic, readonly) LKSession *session;

@property (nonatomic) UIViewController *currentViewController;
@property (nonatomic) LTX10DevicesViewController *devicesViewController;
@property (nonatomic) LTX10RoomsViewController *roomsViewController;
@property (nonatomic) LTX10PresetsViewController *presetsViewController;

@end

@implementation LTX10BaseViewController

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Home", @"Home");
        self.tabBarItem.image = [UIImage imageNamed:@"house"];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Rooms", @"Presets", @"Devices"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    [self.segmentedControl addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = self.segmentedControl;
    
    [self segmentSelected:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Getters

- (LTX10RoomsViewController *)roomsViewController {
    if (_roomsViewController == nil) {
        _roomsViewController = [[LTX10RoomsViewController alloc] init];
    }
    return _roomsViewController;
}

- (LTX10PresetsViewController *)presetsViewController {
    if (_presetsViewController == nil) {
        _presetsViewController = [[LTX10PresetsViewController alloc] init];
    }
    return _presetsViewController;
}

- (LTX10DevicesViewController *)devicesViewController {
    if (_devicesViewController == nil) {
        _devicesViewController = [[LTX10DevicesViewController alloc] init];
    }
    return _devicesViewController;
}

#pragma mark - Child View Swapping

- (void)segmentSelected:(id)sender {
    UIViewController *toViewController = nil;
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            toViewController = self.roomsViewController;
            break;
        case 1:
            toViewController = self.presetsViewController;
            break;
        case 2:
            toViewController = self.devicesViewController;
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
    
    toViewController.view.frame = self.view.bounds;//CGRectMake(0, 64, CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]) - 64);
    
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
